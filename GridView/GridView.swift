//
//  GridView.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/10/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

class Benchmark {
    var startTime: Date!
    
    func start() {
        print("start")
        startTime = Date()
    }
    
    func finish() {
        let elapsed = Date().timeIntervalSince(startTime) as Double
        let string = String(format: "%.8f", elapsed)
        print(string)
    }
}

let benchmark = Benchmark()

@objc public protocol GridViewDataSource: class {
    func gridView(_ gridView: GridView, numberOfRowsInSection section: Int) -> Int
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell
    
    @objc optional func numberOfSections(in gridView: GridView) -> Int
}

@objc public protocol GridViewDelegate: UIScrollViewDelegate {
    @objc optional func gridView(_ gridView: GridView, willDisplay cell: GridViewCell, forRowAt indexPath: IndexPath)
    @objc optional func gridView(_ gridView: GridView, didEndDisplaying cell: GridViewCell, forRowAt indexPath: IndexPath)
    
    @objc optional func gridView(_ gridView: GridView, didSelectRowAt indexPath: IndexPath)
    
    // default is view bounds height
    @objc optional func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
//    /// called when setContentOffset/scrollToSectionRowAtIndexPath:animated: beginning. not called if not animating
//    @objc optional func gridViewWillBeginScrollingAnimation(_ gridView: GridView)
//    @objc optional func gridViewDidEndScrollingAnimation(_ gridView: GridView)
}

open class GridView: UIScrollView {
    fileprivate enum NeedsLayout: Equatable {
        case none, reload, layout(rotating: Bool)
        
        static func == (lhs: NeedsLayout, rhs: NeedsLayout) -> Bool {
            switch (lhs, rhs) {
            case (none, none), (reload, reload), (layout(_), layout(_)):
                return true
            default:
                return false
            }
        }
    }
    
    fileprivate typealias Cell = GridViewCell
    
    override open class var layerClass : AnyClass {
        return AnimatedLayer.self
    }
    
    open var infinite = true
    open var contentWidth: CGFloat?
    open var contentPosition: CGFloat?
    open weak var dataSource: GridViewDataSource?
    
    private var lastViewBounds: CGRect = .zero
    private var lastContentOffset: CGPoint = .zero
    private var animatedLayer: AnimatedLayer {
        return layer as! AnimatedLayer
    }
    
    fileprivate private(set) var sectionRow: [Int: Int] = [:]
    fileprivate private(set) var currentMatrix = ViewMatrix()
    
    fileprivate var needsLayout: NeedsLayout = .reload
    fileprivate var lazyRemoveRows: [Int: [Int]] = [:]
    fileprivate var currentInfo = ViewVisibleInfo<Cell>()
    fileprivate var reuseQueue = ReuseQueue<Cell>()
    fileprivate var bundle = ViewBundle<Cell>()
    fileprivate var gridViewDelegate: GridViewDelegate? {
        return delegate as? GridViewDelegate
    }
    
    fileprivate func absoluteSection(_ section: Int) -> Int {
        return sectionRow.abs(section)
    }
    
    fileprivate func sectionCount() -> Int {
        if sectionRow.count > 0 {
            return sectionRow.count
        } else {
            return dataSource?.numberOfSections?(in: self) ?? 1
        }
    }
    
    fileprivate func rowCount(in section: Int) -> Int {
        if let rowCount = sectionRow[section] {
            return rowCount
        } else {
            let rowCount = dataSource?.gridView(self, numberOfRowsInSection: section) ?? 0
            sectionRow[section] = rowCount
            return rowCount
        }
    }
    
    fileprivate func forEachIndexPath(section: Int, rows: [Int], body: (IndexPath, Threshold) -> Void) {
        let absSection: Int
        let threshold: Threshold
        
        if infinite {
            absSection = absoluteSection(section)
            threshold = sectionRow.threshold(with: section)
        } else {
            absSection = section
            threshold = .in
        }
        
        for row in rows {
            let indexPath = IndexPath(row: row, section: absSection)
            body(indexPath, threshold)
        }
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return CGRect(origin: .zero, size: contentSize).contains(point)
    }
    
    override open func display(_ layer: CALayer) {
        if animatedLayer.isAnimatedFinish {
            lazyRemoveRows.forEach { section, rows in
                removeCells(of: rows, in: section)
            }
            lazyRemoveRows = [:]
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let indexPath = currentMatrix.indexPathForRow(at: location)
            selectRow(at: indexPath)
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let contentWidth = self.contentWidth ?? lastViewBounds.width
        if contentWidth != bounds.width {
            stopScroll()
            if let width = self.contentWidth {
                bounds.size.width = width
            }
            lastViewBounds = bounds
            
            if let x = contentPosition {
                frame.origin.x = x
            }
            
            if let superview = superview {
                let inset = UIEdgeInsets(top: -frame.minY, left: -frame.minX, bottom: -superview.bounds.height + frame.maxY, right: -superview.bounds.width + frame.maxX)
                scrollIndicatorInsets = inset
            }
            
            if needsLayout == .none {
                needsLayout = .layout(rotating: true)
            }
        }
        
        benchmark.start()
        switch needsLayout {
        case .reload:
            stopScroll()
            
            sectionRow.removeAll()
            currentInfo = ViewVisibleInfo()
            currentMatrix = makeMatrix()
            
            contentSize = currentMatrix.contentSize
            contentInset = currentMatrix.contentInset
            
            infiniteIfNeeded()
            layoutedToRemoveCells()
            
        case .layout(let rotating):
            stopScroll()
            
            let oldMatrix = currentMatrix
            currentMatrix = makeMatrix(rotating ? oldMatrix : nil)
            
            contentSize = currentMatrix.contentSize
            contentOffset.x = currentMatrix.convert(lastContentOffset.x, from: oldMatrix)
            contentInset = currentMatrix.contentInset
            
            layoutedToLazyRemoveCells(with: oldMatrix)
            
        case .none:
            if infiniteIfNeeded() {
                layoutedCells()
            } else {
                layoutedToRemoveCells()
            }
            
        }
        benchmark.finish()
        
        needsLayout = .none
        lastContentOffset = contentOffset
    }
    
    @discardableResult
    private func infiniteIfNeeded() -> Bool {
        guard infinite else {
            return false
        }
        
        let matrix = currentMatrix
        if validityContentOffset.x < matrix.validityContentRect.minX {
            contentOffset.x += matrix.validityContentRect.width
        } else if validityContentOffset.x > matrix.validityContentRect.maxX {
            contentOffset.x -= matrix.validityContentRect.width
        } else {
            return false
        }
        
        return true
    }
    
}

// MARK: - View Information
extension GridView {
    public func visibleCells() -> [GridViewCell] {
        return visibleCells()
    }
    
    public func visibleCells<T>() -> [T] {
        return currentInfo.visibleObject().values.flatMap { $0.view as? T }
    }
    
    public func cellForRow(at indexPath: IndexPath) -> GridViewCell? {
        return currentInfo.object(at: indexPath)
    }
    
    public func rectForRow(at indexPath: IndexPath) -> CGRect {
        return currentMatrix.rectForRow(at: indexPath)
    }
    
    public func indexPathsForSelectedRows() -> [IndexPath] {
        return currentInfo.indexPathsForSelected()
    }
}

// MARK: - View Operation
extension GridView {
    public func reloadData() {
        needsLayout = .reload
        setNeedsLayout()
    }
    
    public func invalidateLayout() {
        needsLayout = .layout(rotating: false)
        setNeedsLayout()
    }
    
    fileprivate func selectRow(at indexPath: IndexPath) {
        let cell = currentInfo.selected(at: indexPath)
        cell?.isSelected = true
        cell?.setSelected(true)
        gridViewDelegate?.gridView?(self, didSelectRowAt: indexPath)
    }
    
    public func deselectRow(at indexPath: IndexPath) {
        let cell = currentInfo.deselected(at: indexPath)
        cell?.isSelected = false
        cell?.setSelected(false)
    }
    
    public func scrollToRow(at indexPath: IndexPath, at scrollPosition: GridViewScrollPosition, animated: Bool) {
        let currentOffset = validityContentOffset
        let threshold = currentMatrix.validityContentRect.width / 2
        let rect = currentMatrix.rectForRow(at: indexPath)
        
        let absRect: CGRect
        if currentOffset.x + threshold < rect.minX {
            absRect = currentMatrix.rectForRow(at: indexPath, threshold: .below)
        } else if currentOffset.x - threshold >= rect.minX {
            absRect = currentMatrix.rectForRow(at: indexPath, threshold: .above)
        } else {
            absRect = rect
        }
        
        let offsetY = scrollVerticallyOffset(at: absRect, at: scrollPosition)
        let offsetX = scrollHorizontallyOffset(at: absRect, at: scrollPosition)
        
        let offset = CGPoint(x: absRect.minX + offsetX, y: absRect.minY + offsetY)
        setContentOffset(offset, animated: animated)
    }
    
    private func scrollVerticallyOffset(at rect: CGRect, at position: GridViewScrollPosition) -> CGFloat {
        let currentOffset = validityContentOffset
        let superviewFrame = superview?.bounds ?? .zero
        
        let anyVertically: [GridViewScrollPosition] = [.top, .centeredVertically, .bottom]
        let offsetY: CGFloat
        switch position {
        case let p where p.contains(.top),
             let p where p.contains(anyVertically) == false && rect.minY < currentOffset.y:
            offsetY = frame.minY
            
        case let p where p.contains(.centeredVertically):
            offsetY = frame.minY - (superviewFrame.midY - rect.height / 2)
            
        case let p where p.contains(.bottom),
             let p where p.contains(anyVertically) == false && rect.maxY > currentOffset.y + superviewFrame.maxY:
            offsetY = frame.minY - (superviewFrame.maxY - rect.height)
            
        default:
            offsetY = frame.minY + currentOffset.y - rect.minY
        }
        
        return offsetY
    }
    
    private func scrollHorizontallyOffset(at rect: CGRect, at position: GridViewScrollPosition) -> CGFloat {
        let currentOffset = validityContentOffset
        let superviewFrame = superview?.bounds ?? .zero
        
        let anyHorizontally: [GridViewScrollPosition] = [.fit, .left, .centeredHorizontally, .right]
        let offsetX: CGFloat
        switch position {
        case let p where p.contains(.fit):
            offsetX = 0
            
        case let p where p.contains(.left),
             let p where p.contains(anyHorizontally) == false && rect.minX < currentOffset.x:
            offsetX = frame.minX
            
        case let p where p.contains(.centeredHorizontally):
            offsetX = frame.minX - (superviewFrame.midX - rect.width / 2)
            
        case let p where p.contains(.right),
             let p where p.contains(anyHorizontally) == false && rect.maxX > currentOffset.x + superviewFrame.maxX:
            offsetX = frame.minX - (superviewFrame.maxX - rect.width)
            
        default:
            offsetX = frame.minX + currentOffset.x - rect.minX
        }
        
        return offsetX
    }
    
}

// MARK: - Cell Registration
extension GridView {
    /// For each reuse identifier that the grid view will use, register either a class or a nib from which to instantiate a cell.
    /// If a nib is registered, it must contain exactly 1 top level object which is a GridViewCell.
    /// If a class is registered, it will be instantiated via alloc/initWithFrame:
    public func register(_ nib: UINib, forCellWithReuseIdentifier identifier: String) {
        bundle.register(ofNib: nib, for: identifier)
    }
    
    public func register<T: GridViewCell>(_ cellClass: T.Type, forCellWithReuseIdentifier identifier: String) {
        bundle.register(ofClass: cellClass, for: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> GridViewCell {
        func prepare(for cell: GridViewCell) {
            cell.indexPath = indexPath
            cell.isSelected = currentInfo.isSelected(indexPath)
        }
        
        if let cell = reuseQueue.dequeue(with: identifier) {
            prepare(for: cell)
            cell.prepareForReuse()
            return cell
        }
        
        let cell = bundle.instantiate(with: identifier)
        prepare(for: cell)
        reuseQueue.append(cell, for: identifier)
        
        return cell
    }
}

// MARK: - Cell Operation
private extension GridView {
    private func makeCell(at indexPath: IndexPath, matrix: ViewMatrix, threshold: Threshold) -> Cell? {
        var cell: Cell?
        
        UIView.performWithoutAnimation {
            cell = dataSource?.gridView(self, cellForRowAt: indexPath)
            cell?.frame = matrix.rectForRow(at: indexPath, threshold: threshold)
            cell?.layoutIfNeeded()
        }
        
        if let cell = cell {
            insertSubview(cell, at: 0)
        }
        
        return cell
    }
    
    func appendCells(at rows: [Int], in section: Int, matrix: ViewMatrix) {
        forEachIndexPath(section: section, rows: rows) { indexPath, threshold in
            if let cell = makeCell(at: indexPath, matrix: matrix, threshold: threshold) {
                gridViewDelegate?.gridView?(self, willDisplay: cell, forRowAt: indexPath)
                currentInfo.append(cell, at: indexPath)
            }
        }
    }
    
    func removeCells(of sections: [Int]) {
        sections.forEach { section in
            removeCells(of: currentInfo.rows(in: section), in: section)
        }
    }
    
    func removeCells(of rows: [Int], in section: Int) {
        forEachIndexPath(section: section, rows: rows) { indexPath, _ in
            if let cell = currentInfo.removedObject(at: indexPath) {
                gridViewDelegate?.gridView?(self, didEndDisplaying: cell, forRowAt: indexPath)
            }
        }
    }
}

// MARK: - Cell Layout
private extension GridView {
    private func replaceCellForRow(in oldSection: Int, oldInfo: ViewVisibleInfo<Cell>, newInfo: ViewVisibleInfo<Cell>, absSection: Int? = nil, newSection: Int? = nil) {
        let absSection = absSection ?? oldSection
        let newSection = newSection ?? oldSection
        
        let oldRows = oldInfo.rows(in: oldSection).subtracting(newInfo.rows(in: newSection))
        removeCells(of: oldRows, in: absSection)
        
        let newRows = newInfo.rows(in: newSection).subtracting(oldInfo.rows(in: oldSection))
        appendCells(at: newRows, in: absSection, matrix: currentMatrix)
    }
    
    private func replaceCell(for oldSections: [Int], with newSections: [Int], sameSections: [Int], newInfo: ViewVisibleInfo<Cell>) {
        if sameSections.count != newSections.count {
            let newSections = newSections.subtracting(oldSections)
            newSections.forEach { section in
                appendCells(at: newInfo.rows(in: section), in: section, matrix: currentMatrix)
            }
        }
        
        if sameSections.count != oldSections.count {
            let oldSections = oldSections.subtracting(newSections)
            removeCells(of: oldSections)
        }
    }
    
    private func replaceCurrentVisibleInfo(_ info: ViewVisibleInfo<Cell>) {
        var newInfo = info
        newInfo.replaceObject(with: currentInfo)
        newInfo.replaceSelectedIndexPath(with: currentInfo)
        currentInfo = newInfo
    }
    
    private func setViewFrame<T: UIView>(for sectionRows: [Int: [Int]], atVisibleInfo visibleInfo: ViewVisibleInfo<T>) {
        for (section, rows) in sectionRows {
            forEachIndexPath(section: section, rows: rows) { indexPath, threshold in
                visibleInfo.object(at: indexPath)?.frame = currentMatrix.rectForRow(at: indexPath, threshold: threshold)
            }
        }
    }
    
    func layoutedCells() {
        let newInfo = makeVisibleInfo()
        
        for section in currentInfo.sections() {
            let absSection = absoluteSection(section)
            
            for newSection in newInfo.sections() {
                guard absSection == absoluteSection(newSection) else {
                    continue
                }
                
                replaceCellForRow(in: section, oldInfo: currentInfo, newInfo: newInfo, absSection: absSection, newSection: newSection)
            }
        }
        
        let newSections = newInfo.sections().map(absoluteSection)
        let currentSections = currentInfo.sections().map(absoluteSection)
        let sameSections = newSections.intersection(currentSections)
        
        replaceCell(for: currentSections, with: newSections, sameSections: sameSections, newInfo: newInfo)
        replaceCurrentVisibleInfo(newInfo)
        setViewFrame(for: currentInfo.rows(), atVisibleInfo: currentInfo)
    }
    
    func layoutedToRemoveCells() {
        let newInfo = makeVisibleInfo()
        
        let newSections = newInfo.sections()
        let currentSections = currentInfo.sections()
        let sameSections = newSections.intersection(currentSections)
        
        sameSections.forEach { section in
            replaceCellForRow(in: section, oldInfo: currentInfo, newInfo: newInfo)
        }
        
        replaceCell(for: currentSections, with: newSections, sameSections: sameSections, newInfo: newInfo)
        replaceCurrentVisibleInfo(newInfo)
    }
    
    func layoutedToLazyRemoveCells(with oldMatrix: ViewMatrix) {
        let newInfo = makeVisibleInfo()
        
        var layoutInfo = ViewVisibleInfo<Cell>()
        layoutInfo.replaceSection(newInfo.sections().union(currentInfo.sections()))
        
        let offset = validityContentOffset
        layoutInfo.replaceRows {
            currentMatrix.indexesForVisibleRow(at: offset, in: $0).union(oldMatrix.indexesForVisibleRow(at: offset, in: $0))
        }
        
        layoutInfo.sections().forEach { section in
            if newInfo.rows(in: section).count <= 0 {
                lazyRemoveRows[section] = layoutInfo.rows(in: section)
            } else {
                let diffRows = layoutInfo.rows(in: section).subtracting(newInfo.rows(in: section))
                if diffRows.count > 0 {
                    lazyRemoveRows[section] = diffRows
                }
            }
            
            let newRows = layoutInfo.rows(in: section).subtracting(currentInfo.rows(in: section))
            appendCells(at: newRows, in: section, matrix: oldMatrix)
        }
        
        replaceCurrentVisibleInfo(newInfo)
        
        setViewFrame(for: currentInfo.rows(), atVisibleInfo: currentInfo)
        setViewFrame(for: lazyRemoveRows, atVisibleInfo: currentInfo)
    }
}

// MARK: - Matrix
private extension GridView {
    private func heightsForRow(in section: Int, defaultHeight: CGFloat) -> [CGHeight] {
        var contentHeight: CGFloat = 0
        return (0..<rowCount(in: section)).map { row -> CGHeight in
            let indexPath = IndexPath(row: section, section: row)
            let height = gridViewDelegate?.gridView?(self, heightForRowAt: indexPath) ?? defaultHeight
            defer {
                contentHeight += height
            }
            
            return CGHeight(y: contentHeight, height: height)
        }
    }
    
    func makeMatrix(_ matrix: ViewMatrix? = nil) -> ViewMatrix {
        let count = sectionCount()
        var size: CGSize = .zero
        size.width = bounds.width * CGFloat(count)
        
        if let matrix = matrix {
            size.height = matrix.validityContentRect.height
            return ViewMatrix(matrix: matrix, viewFrame: frame, contentSize: size, superviewSize: superview?.bounds.size)
        }
        
        var sectionRowHeights: [[CGHeight]] = []
        let height = bounds.height
        
        (0..<count).forEach { section in
            let sectionHeights = heightsForRow(in: section, defaultHeight: height)
            sectionRowHeights.append(sectionHeights)
            
            if let height = sectionHeights.last, size.height < height.maxY {
                size.height = height.maxY
            }
        }
        
        return ViewMatrix(heights: sectionRowHeights, viewFrame: frame, contentSize: size, superviewSize: superview?.bounds.size, infinite: infinite)
    }
}

// MARK: - VisibleInfo
private extension GridView {
    func makeVisibleInfo() -> ViewVisibleInfo<Cell> {
        let matrix = currentMatrix
        let offset = validityContentOffset
        var currentInfo = ViewVisibleInfo<Cell>()
        currentInfo.replaceSection(matrix.indexesForVisibleSection(at: offset))
        currentInfo.replaceRows {
            matrix.indexesForVisibleRow(at: offset, in: $0)
        }
        
        return currentInfo
    }
}
