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

struct AroundInsets {
    struct Inset {
        static let zero = Inset(scale: 0, width: 0)
        
        let scale: CGFloat
        let width: CGFloat
        
        init(scale: CGFloat, width: CGFloat) {
            self.scale = scale
            self.width = width
        }
    }
    
    static let zero = AroundInsets(parentSize: .zero, frame: .zero)
    var left: Inset
    var right: Inset
    
    init(parentSize: CGSize, frame: CGRect) {
        if frame.width > 0 {
            let leftScale = ceil(frame.minX / frame.width)
            let rightScale = ceil((parentSize.width - frame.maxX) / frame.width)
            
            left = Inset(scale: leftScale, width: frame.width * leftScale)
            right = Inset(scale: rightScale, width: frame.width * rightScale)
        } else {
            left = .zero
            right = .zero
        }
    }
}

struct ViewMatrix: Countable {
    private let infinite: Bool
    private let rects: [[CGRect]]
    private let visibleSize: CGSize?
    private let viewFrame: CGRect
    private(set) var contentSize: CGSize
    private(set) var originalContentSize: CGSize
    private(set) var validityContentRect: CGRect
    let edgeInset: UIEdgeInsets
    let aroundInsets: AroundInsets
    
    var count: Int {
        return rects.count
    }
    
    init(_ rects: [[CGRect]] = [], viewFrame: CGRect = .zero, contentSize: CGSize = .zero, superviewSize: CGSize? = nil, infinite: Bool = false) {
        self.rects = rects
        self.viewFrame = viewFrame
        self.visibleSize = superviewSize
        self.originalContentSize = contentSize
        self.infinite = infinite
        
        let parentSize = superviewSize ?? .zero
        if infinite {
            let insets = AroundInsets(parentSize: parentSize, frame: viewFrame)
            self.aroundInsets = insets
            
            let allWidth = insets.left.width + insets.right.width + viewFrame.width
            self.validityContentRect = CGRect(origin: CGPoint(x: insets.left.width - viewFrame.minX, y: 0), size: contentSize)
            self.contentSize = CGSize(width: contentSize.width + allWidth, height: contentSize.height)
            self.edgeInset = UIEdgeInsets(top: -viewFrame.minY, left: -insets.left.width, bottom: -parentSize.height + viewFrame.maxY, right: -insets.right.width)
        } else {
            self.aroundInsets = .zero
            self.validityContentRect = CGRect(origin: .zero, size: contentSize)
            self.contentSize = contentSize
            self.edgeInset = UIEdgeInsets(top: -viewFrame.minY, left: -viewFrame.minX, bottom: -parentSize.height + viewFrame.maxY, right: -parentSize.width + viewFrame.maxX)
        }
    }
    
    private subscript(section: Int) -> [CGRect] {
        if section < 0 || section >= rects.count {
            return []
        }
        return rects[section]
    }
    
    private subscript(section: Int, row: Int) -> CGRect {
        let rects = self[section]
        if row < 0 || row >= rects.count {
            return .zero
        }
        return rects[row]
    }
    
    private subscript(indexPath: IndexPath) -> CGRect {
        return self[indexPath.section, indexPath.row]
    }
    
    private func rowCount(in section: Int) -> Int {
        return self[section].count
    }
    
    func rowRect(at indexPath: IndexPath, threshold: Threshold = .in) -> CGRect {
        var frame = self[indexPath]
        frame.origin.x += aroundInsets.left.width
        
        switch threshold {
        case .below:
            frame.origin.x -= originalContentSize.width
        case .above:
            frame.origin.x += originalContentSize.width
        default:
            break
        }
        return frame
    }
    
    func indexPath(for location: CGPoint) -> IndexPath {
        let section = self.section(for: location)
        let row = rowIndex(for: location, in: section)
        return IndexPath(row: row, section: section)
    }
    
    func section(for location: CGPoint) -> Int {
        return Int(floor(location.x / viewFrame.width))
    }
    
    func rowIndex(for location: CGPoint, in section: Int) -> Int {
        let step = 100
        let rects = self[section]
        
        for index in stride(from: 0, to: rects.count, by: step) {
            let next = index + step
            guard rects.count <= next || rects[next].maxY > location.y else {
                continue
            }
            
            for offset in (index..<rects.count) {
                guard rects[offset].maxY > location.y else {
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
        guard let visibleSize = visibleSize else {
            return sections
        }
        
        let visibleRect = CGRect(origin: CGPoint(x: offset.x - aroundInsets.left.width, y: 0), size: visibleSize)
        let index = section(for: visibleRect.origin)
        
        var frame = CGRect(origin: .zero, size: viewFrame.size)
        for offset in (0..<count) {
            let section = offset + index
            frame.origin.x = viewFrame.width * CGFloat(section)
            
            if visibleRect.intersects(frame) {
                sections.append(section)
            } else {
                break
            }
        }
        
        return sections
    }
    
    func visibleRow(for offset: CGPoint, in section: Int) -> [Int] {
        var rows: [Int] = []
        guard let visibleSize = visibleSize else {
            return rows
        }
        
        let visibleRect = CGRect(origin: CGPoint(x: 0, y: offset.y), size: visibleSize)
        let absSection: Int
        if infinite {
            absSection = abs(section)
        } else {
            absSection = section
        }
        
        let index = rowIndex(for: visibleRect.origin, in: absSection)
        let rects = self[absSection]
        
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
    
    var infinite = true
    var contentWidth: CGFloat?
    weak var dataSource: InfiniteViewDataSource?
    
    private var lastViewBounds: CGRect = .zero
    private var lastContentOffset: CGPoint = .zero
    private var currentMatrix = ViewMatrix()
    private var animatedLayer: AnimatedLayer {
        return layer as! AnimatedLayer
    }
    
    fileprivate var sectionRow: [Int: Int] = [:]
    fileprivate var lazyRemoveRows: [Int: [Int]] = [:]
    fileprivate var isNeedReloadData = true
    fileprivate var isNeedInvalidateLayout = false
    fileprivate var currentInfo = ViewVisibleInfo<Cell>()
    fileprivate var reuseQueue = ReuseQueue<Cell>()
    fileprivate var bundle = ViewBundle<Cell>()
    fileprivate var infiniteViewDelegate: InfiniteViewDelegate? {
        return delegate as? InfiniteViewDelegate
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
            let rowCount = dataSource?.infiniteView(self, numberOfRowsInSection: section) ?? 0
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
            let indexPath = currentMatrix.indexPath(for: location)
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
            frame.origin.x = 0
            
            if let superview = superview {
                let inset = UIEdgeInsets(top: -frame.minY, left: -frame.minX, bottom: -superview.bounds.height + frame.maxY, right: -superview.bounds.width + frame.maxX)
                scrollIndicatorInsets = inset
            }
            
            if isNeedReloadData == false {
                isNeedInvalidateLayout = true
            }
        }
        
        if isNeedReloadData {
            isNeedInvalidateLayout = false
            sectionRow.removeAll()
            currentInfo = ViewVisibleInfo()
            
            currentMatrix = makeMatrix()
            contentSize = currentMatrix.contentSize
            contentInset = currentMatrix.edgeInset
        }
        
        if isNeedInvalidateLayout {
            let oldMatrix = currentMatrix
            
            currentMatrix = makeMatrix()
            contentSize = currentMatrix.contentSize
            // ->>
            let diffScale = currentMatrix.aroundInsets.left.scale - oldMatrix.aroundInsets.left.scale
            let oldAllScale = oldMatrix.aroundInsets.left.scale + oldMatrix.aroundInsets.right.scale + 1
            let newWidth = currentMatrix.originalContentSize.width + bounds.width * oldAllScale
            let oldWidth = oldMatrix.contentSize.width
            contentOffset.x = newWidth * lastContentOffset.x / oldWidth + bounds.width * diffScale
            // <<-
            
            contentInset = currentMatrix.edgeInset
            
            layoutedToLazyRemoveCells(with: oldMatrix, newMatrix: currentMatrix)
        } else {
            if infiniteIfNeeded(with: currentMatrix) && isNeedReloadData == false {
                layoutedCells(with: currentMatrix)
            } else {
                layoutedToRemoveCells(with: currentMatrix)
            }
        }
        
        isNeedInvalidateLayout = false
        isNeedReloadData = false
        lastContentOffset = contentOffset
        
    }
    
    private func infiniteIfNeeded(with matrix: ViewMatrix) -> Bool {
        guard infinite else {
            return false
        }
        
        if validityContentOffset.x < matrix.validityContentRect.origin.x {
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
extension InfiniteView {
    public func visibleCells() -> [InfiniteViewCell] {
        return visibleCells()
    }
    
    public func visibleCells<T>() -> [T] {
        return currentInfo.visibleObject().values.flatMap { $0.view as? T }
    }
    
    public func cellForRow(at indexPath: IndexPath) -> InfiniteViewCell? {
        return currentInfo.object(at: indexPath)
    }
    
    public func indexPathsForSelectedRows() -> [IndexPath] {
        return currentInfo.indexPathsForSelected()
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
        let cell = currentInfo.selected(at: indexPath)
        cell?.isSelected = true
        cell?.setSelected(true)
        infiniteViewDelegate?.infiniteView?(self, didSelectRowAt: indexPath)
    }
    
    public func deselectRow(at indexPath: IndexPath) {
        let cell = currentInfo.deselected(at: indexPath)
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
private extension InfiniteView {
    private func makeCell(at indexPath: IndexPath, matrix: ViewMatrix, threshold: Threshold) -> Cell? {
        var cell: Cell?
        
        UIView.performWithoutAnimation {
            cell = dataSource?.infiniteView(self, cellForRowAt: indexPath)
            cell?.frame = matrix.rowRect(at: indexPath, threshold: threshold)
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
                infiniteViewDelegate?.infiniteView?(self, willDisplay: cell, forRowAt: indexPath)
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
                infiniteViewDelegate?.infiniteView?(self, didEndDisplaying: cell, forRowAt: indexPath)
            }
        }
    }
}

// MARK: - Cell Layout
private extension InfiniteView {
    private func replaceCellForRow(in oldSection: Int, oldInfo: ViewVisibleInfo<Cell>, newInfo: ViewVisibleInfo<Cell>, absSection: Int? = nil, newSection: Int? = nil, matrix: ViewMatrix) {
        let absSection = absSection ?? oldSection
        let newSection = newSection ?? oldSection
        
        let oldRows = oldInfo.rows(in: oldSection).subtracting(newInfo.rows(in: newSection))
        removeCells(of: oldRows, in: absSection)
        
        let newRows = newInfo.rows(in: newSection).subtracting(oldInfo.rows(in: oldSection))
        appendCells(at: newRows, in: absSection, matrix: matrix)
    }
    
    private func replaceCell(for oldSections: [Int], with newSections: [Int], sameSections: [Int], newInfo: ViewVisibleInfo<Cell>, matrix: ViewMatrix) {
        if sameSections.count != newSections.count {
            let newSections = newSections.subtracting(oldSections)
            newSections.forEach { section in
                appendCells(at: newInfo.rows(in: section), in: section, matrix: matrix)
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
    
    private func setViewFrame<T: UIView>(for sectionRows: [Int: [Int]], at visibleInfo: ViewVisibleInfo<T>, matrix: ViewMatrix) {
        for (section, rows) in sectionRows {
            forEachIndexPath(section: section, rows: rows) { indexPath, threshold in
                visibleInfo.object(at: indexPath)?.frame = matrix.rowRect(at: indexPath, threshold: threshold)
            }
        }
    }
    
    func layoutedCells(with matrix: ViewMatrix) {
        let newInfo = makeVisibleInfo(matrix: matrix)
        
        for section in currentInfo.sections() {
            let absSection = absoluteSection(section)
            
            for newSection in newInfo.sections() {
                guard absSection == absoluteSection(newSection) else {
                    continue
                }
                
                replaceCellForRow(in: section, oldInfo: currentInfo, newInfo: newInfo, absSection: absSection, newSection: newSection, matrix: matrix)
            }
        }
        
        let newSections = newInfo.sections().map(absoluteSection)
        let currentSections = currentInfo.sections().map(absoluteSection)
        let sameSections = newSections.intersection(currentSections)
        
        replaceCell(for: currentSections, with: newSections, sameSections: sameSections, newInfo: newInfo, matrix: matrix)
        replaceCurrentVisibleInfo(newInfo)
        setViewFrame(for: currentInfo.rows(), at: currentInfo, matrix: matrix)
    }
    
    func layoutedToRemoveCells(with matrix: ViewMatrix) {
        let newInfo = makeVisibleInfo(matrix: matrix)
        
        let newSections = newInfo.sections()
        let currentSections = currentInfo.sections()
        let sameSections = newSections.intersection(currentSections)
        
        sameSections.forEach { section in
            replaceCellForRow(in: section, oldInfo: currentInfo, newInfo: newInfo, matrix: matrix)
        }
        
        replaceCell(for: currentSections, with: newSections, sameSections: sameSections, newInfo: newInfo, matrix: matrix)
        replaceCurrentVisibleInfo(newInfo)
    }
    
    func layoutedToLazyRemoveCells(with oldMatrix: ViewMatrix, newMatrix: ViewMatrix) {
        let newInfo = makeVisibleInfo(matrix: newMatrix)
        
        var layoutInfo = ViewVisibleInfo<Cell>()
        layoutInfo.replaceSection(newInfo.sections().union(currentInfo.sections()))
        
        let offset = validityContentOffset
        layoutInfo.replaceRows {
            newMatrix.visibleRow(for: offset, in: $0).union(oldMatrix.visibleRow(for: offset, in: $0))
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
        
        setViewFrame(for: currentInfo.rows(), at: currentInfo, matrix: newMatrix)
        setViewFrame(for: lazyRemoveRows, at: currentInfo, matrix: newMatrix)
    }
}

// MARK: - Cell Matrix
private extension InfiniteView {
    private func rects(in section: Int, defaultRect: CGRect) -> [CGRect] {
        var contentHeight: CGFloat = 0
        return (0..<rowCount(in: section)).map { row -> CGRect in
            let indexPath = IndexPath(row: section, section: row)
            let height = infiniteViewDelegate?.infiniteView?(self, heightForRowAt: indexPath) ?? defaultRect.size.height
            defer {
                contentHeight += height
            }
            
            return CGRect(x: defaultRect.origin.x, y: contentHeight, width: defaultRect.size.width, height: height)
        }
    }
    
    func makeMatrix() -> ViewMatrix {
        var size: CGSize = .zero
        var sectionRowRects: [[CGRect]] = []
        var rect = CGRect(origin: .zero, size: bounds.size)
        
        (0..<sectionCount()).forEach { section in
            rect.origin.x = size.width
            let sectionRects = rects(in: section, defaultRect: rect)
            sectionRowRects.append(sectionRects)
            
            size.width += rect.width
            if let rect = sectionRects.last, size.height < rect.maxY {
                size.height = rect.maxY
            }
        }
        
        return ViewMatrix(sectionRowRects, viewFrame: frame, contentSize: size, superviewSize: superview?.bounds.size, infinite: infinite)
    }
}

// MARK: - Visible Info
private extension InfiniteView {
    func makeVisibleInfo(matrix: ViewMatrix) -> ViewVisibleInfo<Cell> {
        let offset = validityContentOffset
        var currentInfo = ViewVisibleInfo<Cell>()
        currentInfo.replaceSection(matrix.visibleSection(for: offset))
        currentInfo.replaceRows {
            matrix.visibleRow(for: offset, in: $0)
        }
        
        return currentInfo
    }
}
