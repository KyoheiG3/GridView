//
//  InfiniteView.swift
//  InfiniteView
//
//  Created by Kyohei Ito on 2016/10/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

let benchmark = Benchmark()

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

@objc protocol InfiniteViewDataSource: class {
    func infiniteView(_ infiniteView: InfiniteView, numberOfRowsInSection section: Int) -> Int
    func infiniteView(_ infiniteView: InfiniteView, cellForRowAt indexPath: IndexPath) -> InfiniteViewCell
    
    @objc optional func numberOfSections(in infiniteView: InfiniteView) -> Int
}

@objc protocol InfiniteViewDelegate: UIScrollViewDelegate {
    @objc optional func infiniteView(_ infiniteView: InfiniteView, willDisplay cell: InfiniteViewCell, forRowAt indexPath: IndexPath)
    @objc optional func infiniteView(_ infiniteView: InfiniteView, didEndDisplaying cell: InfiniteViewCell, forRowAt indexPath: IndexPath)
    
    @objc optional func infiniteView(_ infiniteView: InfiniteView, didSelectRowAt indexPath: IndexPath)
    
    // default is view bounds height
    @objc optional func infiniteView(_ infiniteView: InfiniteView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
//    /// called when setContentOffset/scrollToSectionRowAtIndexPath:animated: beginning. not called if not animating
//    @objc optional func infiniteViewWillBeginScrollingAnimation(_ infiniteView: InfiniteView)
//    @objc optional func infiniteViewDidEndScrollingAnimation(_ infiniteView: InfiniteView)
}

struct CellMatrix {
    private var matrix: [[CGRect]]
    private var viewSize: CGSize
    private var superviewSize: CGSize?
    private(set) var contentSize: CGSize
    
    init(_ matrix: [[CGRect]] = [], viewSize: CGSize = .zero, contentSize: CGSize = .zero, superviewSize: CGSize? = nil) {
        self.matrix = matrix
        self.viewSize = viewSize
        self.superviewSize = superviewSize
        self.contentSize = contentSize
    }
    
    func sectionCount() -> Int {
        return matrix.count
    }
    
    func rowCount(in section: Int) -> Int {
        return rowRects(in: section).count
    }
    
    func rowRects(in section: Int) -> [CGRect] {
        if section < 0 || section >= matrix.count {
            return []
        }
        return matrix[section]
    }
    
    func rowRect(at row: Int, in section: Int) -> CGRect {
        return rowRects(in: section)[row]
    }
    
    func rowRect(at indexPath: IndexPath) -> CGRect {
        return rowRect(at: indexPath.row, in: indexPath.section)
    }
    
    mutating func removeAll() {
        matrix = []
        viewSize = .zero
        contentSize = .zero
        superviewSize = nil
    }
    
    func indexPath(for location: CGPoint) -> IndexPath {
        let section = self.section(for: location.x)
        let row = rowIndex(for: location.y, in: section)
        return IndexPath(row: row, section: section)
    }
    
    func section(for x: CGFloat) -> Int {
        return Int(floor(x / viewSize.width))
    }
    
    func rowIndex(for y: CGFloat, in section: Int) -> Int {
        let step = 100
        let rects = rowRects(in: section)
        
        for index in stride(from: 0, to: rects.count, by: step) {
            let next = index + step
            guard rects.count <= next || rects[next].maxY > y else {
                continue
            }
            
            for offset in (index..<rects.count) {
                guard rects[offset].maxY > y else {
                    continue
                }
                
                return offset
            }
            
            return index
        }
        
        return 0
    }
    
    func visibleSection(for offset: CGPoint) -> [Int] {
        var sections: [Int] = []
        guard let visibleSize = superviewSize else {
            return sections
        }
        
        let visibleRect = CGRect(origin: CGPoint(x: offset.x, y: 0), size: visibleSize)
        let index = section(for: visibleRect.origin.x)
        let count = sectionCount()
        
        var frame = CGRect(origin: .zero, size: viewSize)
        for offset in (0..<count) {
            let section = offset + index
            frame.origin.x = viewSize.width * CGFloat(section)
            
            if visibleRect.intersects(frame) {
                sections.append((section + count) % count)
            } else {
                break
            }
        }
        
        return sections
    }
    
    func visibleRow(for offset: CGPoint, in section: Int) -> [Int] {
        var rows: [Int] = []
        guard let visibleSize = superviewSize else {
            return rows
        }
        
        let visibleRect = CGRect(origin: CGPoint(x: 0, y: offset.y), size: visibleSize)
        let index = rowIndex(for: visibleRect.origin.y, in: section)
        let rects = rowRects(in: section)
        
        for row in (index..<rects.count) {
            var frame = rects[row]
            frame.origin.x = 0
            
            if visibleRect.intersects(frame) {
                rows.append(row)
            } else {
                break
            }
        }
        
        return rows
    }
}

class InfiniteView: UIScrollView {
    fileprivate typealias Cell = InfiniteViewCell
    
    override class var layerClass : AnyClass {
        return AnimatedLayer.self
    }
    
    var contentWidth: CGFloat?
    weak var dataSource: InfiniteViewDataSource?
    
    private var lastViewBounds: CGRect = .zero
    private var lastContentOffset: CGPoint = .zero
    private var lazyRemoveRows: [Int: [Int]] = [:]
    private var cellMatrix = CellMatrix()
    private var animatedLayer: AnimatedLayer {
        return layer as! AnimatedLayer
    }
    
    fileprivate var visibleInfo = ViewVisibleInfo<Cell>()
    fileprivate var reuseQueue = ReuseQueue<Cell>()
    fileprivate var bundle = ViewBundle<Cell>()
    fileprivate var isNeedInvalidateLayout = false
    fileprivate var isNeedReloadData = true
    fileprivate var infiniteViewDelegate: InfiniteViewDelegate? {
        return delegate as? InfiniteViewDelegate
    }
    
    fileprivate func sectionCount() -> Int {
        if cellMatrix.sectionCount() > 0 {
            return cellMatrix.sectionCount()
        } else {
            return dataSource?.numberOfSections?(in: self) ?? 1
        }
    }
    
    fileprivate func rowCount(in section: Int) -> Int {
        if cellMatrix.sectionCount() > section {
            return cellMatrix.rowCount(in: section)
        } else {
            return dataSource?.infiniteView(self, numberOfRowsInSection: section) ?? 0
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return CGRect(origin: .zero, size: contentSize).contains(point)
    }
    
    override func display(_ layer: CALayer) {
        if animatedLayer.isAnimatedFinish {
            lazyRemoveRows.forEach { section, rows in
                removeCells(of: rows, in: section)
            }
            lazyRemoveRows = [:]
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let indexPath = cellMatrix.indexPath(for: location)
            selectRow(at: indexPath)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentWidth = self.contentWidth ?? lastViewBounds.width
        if contentWidth != bounds.width {
            if let width = self.contentWidth {
                bounds.size.width = width
            }
            lastViewBounds = bounds
//            frame.origin.x = 0
            
            if let superview = superview {
                let inset = UIEdgeInsets(top: -frame.minY, left: -frame.minX, bottom: -superview.bounds.height + frame.maxY, right: -superview.bounds.width + frame.maxX)
                contentInset = inset
                scrollIndicatorInsets = inset
            }
            
            if isNeedReloadData == false {
                isNeedInvalidateLayout = true
            }
        }
        
        if isNeedReloadData {
            cellMatrix.removeAll()
            visibleInfo = ViewVisibleInfo()
            
            cellMatrix = makeMatrix()
            contentSize = cellMatrix.contentSize
        }
        
        var currentInfo: ViewVisibleInfo<Cell>
        if isNeedInvalidateLayout {
            let oldMatrix = cellMatrix
            let oldContentSize = contentSize
            
            cellMatrix = makeMatrix()
            contentSize = cellMatrix.contentSize
            
            contentOffset.x = contentSize.width * lastContentOffset.x / oldContentSize.width
            currentInfo = makeVisibleInfo(matrix: cellMatrix)
            
            let offset = validityContentOffset
            var layoutInfo = ViewVisibleInfo<Cell>()
            layoutInfo.replaceSection(currentInfo.sections().union(visibleInfo.sections()))
            layoutInfo.replaceRows {
                cellMatrix.visibleRow(for: offset, in: $0).union(oldMatrix.visibleRow(for: offset, in: $0))
            }
            
            layoutInfo.sections().forEach { section in
                if currentInfo.rows(in: section).count <= 0 {
                    lazyRemoveRows[section] = layoutInfo.rows(in: section)
                } else {
                    let diffRows = layoutInfo.subtractingRows(with: currentInfo, in: section)
                    if diffRows.count > 0 {
                        lazyRemoveRows[section] = diffRows
                    }
                }
                
                let newRows = layoutInfo.subtractingRows(with: visibleInfo, in: section)
                appendCells(at: newRows, in: section, matrix: oldMatrix)
            }
        } else {
            benchmark.start()
            currentInfo = makeVisibleInfo(matrix: cellMatrix)
            
            let sameSections = currentInfo.sections().intersection(visibleInfo.sections())
            sameSections.forEach { section in
                let oldRows = visibleInfo.subtractingRows(with: currentInfo, in: section)
                removeCells(of: oldRows, in: section)
                
                let newRows = currentInfo.subtractingRows(with: visibleInfo, in: section)
                appendCells(at: newRows, in: section, matrix: cellMatrix)
            }
            
            if sameSections.count != currentInfo.sections().count {
                let newSections = currentInfo.subtractingSections(with: visibleInfo)
                newSections.forEach { section in
                    appendCells(at: currentInfo.rows(in: section), in: section, matrix: cellMatrix)
                }
            }
            
            if sameSections.count != visibleInfo.sections().count {
                let oldSections = visibleInfo.subtractingSections(with: currentInfo)
                removeCells(of: oldSections)
            }
            benchmark.finish()
        }
        
        currentInfo.replaceObject(with: visibleInfo)
        currentInfo.replaceSelectedIndexPath(with: visibleInfo)
        visibleInfo = currentInfo
        
        if isNeedInvalidateLayout {
            visibleInfo.visibleObject().forEach { indexPath, cell in
                cell.view?.frame = cellMatrix.rowRect(at: indexPath)
            }
        }
        
        isNeedInvalidateLayout = false
        isNeedReloadData = false
        lastContentOffset = contentOffset
    }
}

// MARK: - View Information
extension InfiniteView {
    public func visibleCells() -> [InfiniteViewCell] {
        return visibleCells()
    }
    
    public func visibleCells<T>() -> [T] {
        return visibleInfo.visibleObject().values.flatMap { $0.view as? T }
    }
    
    public func cellForRow(at indexPath: IndexPath) -> InfiniteViewCell? {
        return visibleInfo.object(at: indexPath)
    }
    
    public func indexPathsForSelectedRows() -> [IndexPath] {
        return visibleInfo.indexPathsForSelected()
    }
}

// MARK: - View Operation
extension InfiniteView {
    public func reloadData() {
        isNeedReloadData = true
        setNeedsLayout()
    }
    
    public func invalidateLayout() {
        isNeedInvalidateLayout = true
        setNeedsLayout()
        stopScroll()
    }
    
    fileprivate func selectRow(at indexPath: IndexPath) {
        let cell = visibleInfo.selected(at: indexPath)
        cell?.isSelected = true
        cell?.setSelected(true)
        infiniteViewDelegate?.infiniteView?(self, didSelectRowAt: indexPath)
    }
    
    public func deselectRow(at indexPath: IndexPath) {
        let cell = visibleInfo.deselected(at: indexPath)
        cell?.isSelected = false
        cell?.setSelected(false)
    }
}

// MARK: - Cell Registration
extension InfiniteView {
    /// For each reuse identifier that the infinite view will use, register either a class or a nib from which to instantiate a cell.
    /// If a nib is registered, it must contain exactly 1 top level object which is a InfiniteViewCell.
    /// If a class is registered, it will be instantiated via alloc/initWithFrame:
    public func register(_ nib: UINib, forCellWithReuseIdentifier identifier: String) {
        bundle.register(ofNib: nib, for: identifier)
    }
    
    public func register<T: InfiniteViewCell>(_ cellClass: T.Type, forCellWithReuseIdentifier identifier: String) {
        bundle.register(ofClass: cellClass, for: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> InfiniteViewCell {
        func prepare(for cell: InfiniteViewCell) {
            cell.reuseIdentifier = identifier
            cell.indexPath = indexPath
            cell.isSelected = visibleInfo.isSelected(indexPath)
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
private extension InfiniteView {
    private func makeCell(at indexPath: IndexPath, matrix: CellMatrix) -> Cell? {
        var cell: Cell?
        
        UIView.performWithoutAnimation {
            cell = dataSource?.infiniteView(self, cellForRowAt: indexPath)
            cell?.frame = matrix.rowRect(at: indexPath)
            cell?.layoutIfNeeded()
        }
        
        if let cell = cell {
            insertSubview(cell, at: 0)
        }
        
        return cell
    }
    
    func appendCells(at rows: [Int], in section: Int, matrix: CellMatrix) {
        rows.forEach { row in
            let indexPath = IndexPath(row: row, section: section)
            if let cell = makeCell(at: indexPath, matrix: matrix) {
                infiniteViewDelegate?.infiniteView?(self, willDisplay: cell, forRowAt: indexPath)
                visibleInfo.append(cell, at: indexPath)
            }
        }
    }
    
    func removeCells(of sections: [Int]) {
        sections.forEach { section in
            removeCells(of: visibleInfo.rows(in: section), in: section)
        }
    }
    
    func removeCells(of rows: [Int], in section: Int) {
        rows.forEach { row in
            let indexPath = IndexPath(row: row, section: section)
            if let cell = visibleInfo.removedObject(at: indexPath) {
                infiniteViewDelegate?.infiniteView?(self, didEndDisplaying: cell, forRowAt: indexPath)
            }
        }
    }
}

// MARK: - Cell Matrix
private extension InfiniteView {
    private func rowRects(in section: Int, defaultRect rect: CGRect) -> [CGRect] {
        var contentHeight: CGFloat = 0
        return (0..<rowCount(in: section)).map { row -> CGRect in
            let indexPath = IndexPath(row: section, section: row)
            let height = infiniteViewDelegate?.infiniteView?(self, heightForRowAt: indexPath) ?? rect.size.height
            defer {
                contentHeight += height
            }
            
            return CGRect(x: rect.origin.x, y: contentHeight, width: rect.size.width, height: height)
        }
    }
    
    func makeMatrix() -> CellMatrix {
        var size: CGSize = .zero
        var matrix: [[CGRect]] = []
        var rect = CGRect(origin: .zero, size: bounds.size)
        
        (0..<sectionCount()).forEach { section in
            rect.origin.x = size.width
            let rects = rowRects(in: section, defaultRect: rect)
            matrix.append(rects)
            
            size.width += rect.width
            if let rect = rects.last, size.height < rect.maxY {
                size.height = rect.maxY
            }
        }
        
        return CellMatrix(matrix, viewSize: bounds.size, contentSize: size, superviewSize: superview?.bounds.size)
    }
}

// MARK: - Visible Info
private extension InfiniteView {
    func makeVisibleInfo<T>(matrix: CellMatrix) -> ViewVisibleInfo<T> {
        let offset = validityContentOffset
        var currentInfo = ViewVisibleInfo<T>()
        currentInfo.replaceSection(matrix.visibleSection(for: offset))
        currentInfo.replaceRows {
            matrix.visibleRow(for: offset, in: $0)
        }
        
        return currentInfo
    }
}
