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
    private(set) var contentSize: CGSize
    
    init(_ matrix: [[CGRect]] = [], viewSize: CGSize = .zero, contentSize: CGSize = .zero) {
        self.matrix = matrix
        self.contentSize = contentSize
        self.viewSize = viewSize
    }
    
    func sectionCount() -> Int {
        return matrix.count
    }
    
    func rowCount(in section: Int) -> Int {
        return rects(in: section).count
    }
    
    func rects(in section: Int) -> [CGRect] {
        if section < 0 || section >= matrix.count {
            return []
        }
        return matrix[section]
    }
    
    func rect(at row: Int, in section: Int) -> CGRect {
        return rects(in: section)[row]
    }
    
    func rect(at indexPath: IndexPath) -> CGRect {
        return rect(at: indexPath.row, in: indexPath.section)
    }
    
    mutating func removeAll() {
        matrix = []
        viewSize = .zero
        contentSize = .zero
    }
    
    func indexPath(for location: CGPoint) -> IndexPath {
        let section = self.section(for: location.x)
        let row = rowIndex(for: location.y, in: section)
        return IndexPath(row: row, section: section)
    }
    
    func section(for x: CGFloat) -> Int {
        return Int(x / viewSize.width)
    }
    
    func rowIndex(for y: CGFloat, in section: Int) -> Int {
        let step = 100
        let rects = self.rects(in: section)
        
        for index in stride(from: 0, to: rects.count, by: step) {
            let next = index + step
            guard rects.count <= next || rects[next].maxY >= y else {
                continue
            }
            
            for offset in (index..<rects.count) {
                guard rects[offset].maxY >= y else {
                    continue
                }
                
                return offset
            }
            
            return index
        }
        
        return 0
    }
}

struct VisibleInfo<T: View> {
    private var section = [Int]()
    private var row: [Int: [Int]] = [:]
    private var object: [IndexPath: WeakView<T>] = [:]
    private var selectedIndexPath = Set<IndexPath>()
    
    mutating func replaceSection(_ section: [Int]) {
        self.section = section
    }
    
    mutating func replaceRows(_ rows: (Int) -> [Int]) {
        for section in self.section {
            self.row[section] = rows(section)
        }
    }
    
    mutating func replaceObject(with info: VisibleInfo) {
        self.object = info.object
    }
    
    mutating func replaceSelectedIndexPath(with info: VisibleInfo) {
        self.selectedIndexPath = info.selectedIndexPath
    }
    
    func subtractingSections(with visibleInfo: VisibleInfo<T>) -> [Int] {
        return sections().subtracting(visibleInfo.sections())
    }
    
    func subtractingRows(with visibleInfo: VisibleInfo<T>, in section: Int) -> [Int] {
        return rows(in: section).subtracting(visibleInfo.rows(in: section))
    }
    
    func sections() -> [Int] {
        return section
    }
    
    func rows(in section: Int) -> [Int] {
        return row[section] ?? []
    }
    
    func visibleObject() -> [IndexPath: WeakView<T>] {
        return object
    }
    
    func isSelected(_ indexPath: IndexPath) -> Bool {
        return selectedIndexPath.contains(indexPath)
    }
    
    func object(at indexPath: IndexPath) -> T? {
        return self.object[indexPath]?.view
    }
    
    func indexPathsForSelected() -> [IndexPath] {
        return selectedIndexPath.sorted()
    }
    
    mutating func selected(at indexPath: IndexPath) -> T? {
        selectedIndexPath.insert(indexPath)
        return object[indexPath]?.view
    }
    
    mutating func deselected(at indexPath: IndexPath) -> T? {
        selectedIndexPath.remove(indexPath)
        return object[indexPath]?.view
    }
    
    mutating func append(_ object: T, at indexPath: IndexPath) {
        self.object[indexPath] = WeakView(object)
    }
    
    mutating func removedObject(at indexPath: IndexPath) -> T? {
        let object = self.object[indexPath]
        self.object[indexPath] = nil
        return object?.view
    }
}

class InfiniteView: UIScrollView {
    fileprivate typealias Cell = InfiniteViewCell
    
    override class var layerClass : AnyClass {
        return AnimatedLayer.self
    }
    
    var contentWidth: CGFloat?
    weak var dataSource: InfiniteViewDataSource?
    
    private var lastContentOffset: CGPoint = .zero
    private var lazyRemoveRows: [Int: [Int]] = [:]
    private var cellMatrix = CellMatrix()
    private var animatedLayer: AnimatedLayer {
        return layer as! AnimatedLayer
    }
    
    fileprivate var visibleInfo = VisibleInfo<Cell>()
    fileprivate var reuseQueue = ReuseQueue<Cell>()
    fileprivate var cellRegistration = RegisterCell()
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
    
    fileprivate func didSelectRow(at indexPath: IndexPath) {
        let cell = visibleInfo.selected(at: indexPath)
        cell?.isSelected = true
        cell?.setSelected(true)
        infiniteViewDelegate?.infiniteView?(self, didSelectRowAt: indexPath)
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
            didSelectRow(at: indexPath)
        }
    }
    
    func necessaryCountOfAround() -> Int {
        guard let superview = superview else {
            return 0
        }
        
        var ratio = (superview.bounds.width - bounds.width) / bounds.width
        if ratio.truncatingRemainder(dividingBy: 1) == 0 { ratio += 1 }
        return Int(ceil(ratio))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentInset = contentInset
        let currentContentSize = contentSize
        
        if let width = self.contentWidth, width != bounds.width {
            bounds.size.width = width
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
            visibleInfo = VisibleInfo()
            
            cellMatrix = makeMatrix()
            contentSize = cellMatrix.contentSize
        }
        
        var currentInfo: VisibleInfo<Cell>
        if isNeedInvalidateLayout {
            let newMatrix = makeMatrix()
            contentSize = newMatrix.contentSize
            
            if currentContentSize != contentSize, let superview = superview {
                let currentSuperviewBounds = superview.layer.presentation()?.bounds ?? superview.layer.bounds
                let ratio = lastContentOffset.x / (currentContentSize.width - (currentSuperviewBounds.width + currentInset.left + currentInset.right))
                contentOffset.x = (contentSize.width - (superview.bounds.width + contentInset.left + contentInset.right)) * ratio
            }
            currentInfo = makeVisibleInfo(matrix: newMatrix)
            
            var layoutInfo = VisibleInfo<Cell>()
            layoutInfo.replaceSection(currentInfo.sections().union(visibleInfo.sections()))
            layoutInfo.replaceRows {
                visibleRow(in: $0, matrix: newMatrix).union(visibleRow(in: $0, matrix: cellMatrix))
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
                appendCells(at: newRows, in: section)
            }
            
            cellMatrix = newMatrix
        } else {
            benchmark.start()
            currentInfo = makeVisibleInfo(matrix: cellMatrix)
            
            let sameSections = currentInfo.sections().intersection(visibleInfo.sections())
            sameSections.forEach { section in
                let oldRows = visibleInfo.subtractingRows(with: currentInfo, in: section)
                removeCells(of: oldRows, in: section)
                
                let newRows = currentInfo.subtractingRows(with: visibleInfo, in: section)
                appendCells(at: newRows, in: section)
            }
            
            if sameSections.count != currentInfo.sections().count {
                let newSections = currentInfo.subtractingSections(with: visibleInfo)
                newSections.forEach { section in
                    appendCells(at: currentInfo.rows(in: section), in: section)
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
                cell.view?.frame = cellMatrix.rect(at: indexPath)
            }
        }
        
        isNeedInvalidateLayout = false
        isNeedReloadData = false
        lastContentOffset = contentOffset
    }
    
    private func makeCell(at indexPath: IndexPath, matrix: CellMatrix) -> Cell? {
        var cell: Cell?
        
        UIView.performWithoutAnimation {
            cell = dataSource?.infiniteView(self, cellForRowAt: indexPath)
            cell?.frame = matrix.rect(at: indexPath)
            cell?.layoutIfNeeded()
        }
        
        if let cell = cell {
            insertSubview(cell, at: 0)
        }
        
        return cell
    }
    
    private func appendCells(at rows: [Int], in section: Int) {
        rows.forEach { row in
            let indexPath = IndexPath(row: row, section: section)
            if let cell = makeCell(at: indexPath, matrix: cellMatrix) {
                infiniteViewDelegate?.infiniteView?(self, willDisplay: cell, forRowAt: indexPath)
                visibleInfo.append(cell, at: indexPath)
            }
        }
    }
    
    private func removeCells(of sections: [Int]) {
        sections.forEach { section in
            removeCells(of: visibleInfo.rows(in: section), in: section)
        }
    }
    
    private func removeCells(of rows: [Int], in section: Int) {
        rows.forEach { row in
            let indexPath = IndexPath(row: row, section: section)
            if let cell = visibleInfo.removedObject(at: indexPath) {
                infiniteViewDelegate?.infiniteView?(self, didEndDisplaying: cell, forRowAt: indexPath)
            }
        }
    }
}

extension InfiniteView {
    func visibleCells() -> [InfiniteViewCell] {
        return visibleCells()
    }
    
    func visibleCells<T>() -> [T] {
        return visibleInfo.visibleObject().values.flatMap { $0.view as? T }
    }
    
    func cellForRow(at indexPath: IndexPath) -> InfiniteViewCell? {
        return visibleInfo.object(at: indexPath)
    }
    
    func indexPathsForSelectedRows() -> [IndexPath] {
        return visibleInfo.indexPathsForSelected()
    }
    
    func deselectRow(at indexPath: IndexPath) {
        let cell = visibleInfo.deselected(at: indexPath)
        cell?.isSelected = false
        cell?.setSelected(false)
    }
}

// MARK: Reload
extension InfiniteView {
    func reloadData() {
        isNeedReloadData = true
        setNeedsLayout()
    }
    
    func invalidateLayout() {
        isNeedInvalidateLayout = true
        setNeedsLayout()
        setContentOffset(contentOffset, animated: false)
    }
}

// MARK: Cell Registration
extension InfiniteView {
    /// For each reuse identifier that the infinite view will use, register either a class or a nib from which to instantiate a cell.
    /// If a nib is registered, it must contain exactly 1 top level object which is a InfiniteViewCell.
    /// If a class is registered, it will be instantiated via alloc/initWithFrame:
    public func register(_ nib: UINib, forCellWithReuseIdentifier identifier: String) {
        cellRegistration.register(of: nib, for: identifier)
    }
    
    public func register<T: InfiniteViewCell>(_ cellClass: T.Type, forCellWithReuseIdentifier identifier: String) {
        cellRegistration.register(of: cellClass, for: identifier)
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
        
        let cell = cellRegistration.instantiate(with: identifier)
        prepare(for: cell)
        reuseQueue.append(cell, for: identifier)
        
        return cell
    }
}

// MARK: Cell Matrix
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
        
        return CellMatrix(matrix, viewSize: bounds.size, contentSize: size)
    }
}

// MARK: Visible Info
private extension InfiniteView {
    func visibleSection(matrix: CellMatrix) -> [Int] {
        var sections: [Int] = []
        guard let superview = superview else {
            return sections
        }
        
        let leftEdge = contentOffset.x - frame.origin.x
        let lower = matrix.section(for: leftEdge)
        let upper = matrix.section(for: leftEdge + superview.bounds.width)
        
        (lower...upper).forEach { i in
            sections.append(i)
        }
        return sections
    }
    
    func visibleRow(in section: Int, matrix: CellMatrix) -> [Int] {
        var rows: [Int] = []
        guard let superview = superview else {
            return rows
        }
        
        let topEdge = contentOffset.y - frame.origin.y
        let bottomEdge = topEdge + superview.bounds.height
        
        let index = matrix.rowIndex(for: topEdge, in: section)
        let rects = matrix.rects(in: section)
        
        for offset in (index..<rects.count) {
            if rects[offset].origin.y <= bottomEdge {
                rows.append(offset)
            } else {
                return rows
            }
        }
        
        return rows
    }
    
    func makeVisibleInfo<T>(matrix: CellMatrix) -> VisibleInfo<T> {
        var currentInfo = VisibleInfo<T>()
        currentInfo.replaceSection(visibleSection(matrix: matrix))
        currentInfo.replaceRows {
            visibleRow(in: $0, matrix: matrix)
        }
        
        return currentInfo
    }
}
