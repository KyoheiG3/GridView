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
        static func +(lhs: Inset, rhs: Inset) -> Inset {
            return Inset(scale: lhs.scale + rhs.scale, width: (lhs.width + rhs.width) / 2)
        }
        
        let scale: CGFloat
        let width: CGFloat
        let contentWidth: CGFloat
        
        init(scale: CGFloat, width: CGFloat) {
            self.scale = scale
            self.width = width
            self.contentWidth = width * scale
        }
    }
    
    static let zero = AroundInsets(parentSize: .zero, frame: .zero)
    var left: Inset = .zero
    var right: Inset = .zero
    var all: Inset {
        return left + right
    }
    
    init(parentSize: CGSize, frame: CGRect) {
        let viewHalfWidth = parentSize.width / 2
        if viewHalfWidth > 0 && frame.width > 0 {
            let aroundCount = ceil(viewHalfWidth / frame.width)
            
            left = Inset(scale: aroundCount, width: frame.width)
            right = Inset(scale: aroundCount, width: frame.width)
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
    let insets: AroundInsets
    
    var count: Int {
        return rects.count
    }
    
    init(_ rects: [[CGRect]] = [], viewFrame: CGRect = .zero, contentSize: CGSize = .zero, superviewSize: CGSize? = nil, infinite: Bool = false) {
        self.rects = rects
        self.viewFrame = viewFrame
        self.visibleSize = superviewSize
        self.originalContentSize = contentSize
        self.infinite = infinite
        
        if infinite {
            let parentSize = superviewSize ?? .zero
            let viewHalfWidth = parentSize.width / 2
            
            let insets = AroundInsets(parentSize: parentSize, frame: viewFrame)
            
            self.validityContentRect = CGRect(origin: CGPoint(x: insets.left.contentWidth - viewHalfWidth, y: 0), size: contentSize)
            self.contentSize = CGSize(width: contentSize.width + insets.all.contentWidth, height: contentSize.height)
            self.insets = insets
        } else {
            self.validityContentRect = CGRect(origin: .zero, size: contentSize)
            self.contentSize = contentSize
            self.insets = .zero
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
        frame.origin.x += insets.left.contentWidth
        
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
        
        let visibleRect = CGRect(origin: CGPoint(x: offset.x - insets.left.contentWidth, y: 0), size: visibleSize)
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
    
    var infinite = false
    var contentWidth: CGFloat?
    weak var dataSource: InfiniteViewDataSource?
    
    private var sectionRows: [Int: Int] = [:]
    private var lastViewBounds: CGRect = .zero
    private var lastContentOffset: CGPoint = .zero
    private var lazyRemoveRows: [Int: [Int]] = [:]
    private var currentMatrix = ViewMatrix()
    private var animatedLayer: AnimatedLayer {
        return layer as! AnimatedLayer
    }
    
    fileprivate var isNeedReloadData = true
    fileprivate var isNeedInvalidateLayout = false
    fileprivate var currentInfo = ViewVisibleInfo<Cell>()
    fileprivate var reuseQueue = ReuseQueue<Cell>()
    fileprivate var bundle = ViewBundle<Cell>()
    fileprivate var infiniteViewDelegate: InfiniteViewDelegate? {
        return delegate as? InfiniteViewDelegate
    }
    
    fileprivate func sectionCount() -> Int {
        if sectionRows.count > 0 {
            return sectionRows.count
        } else {
            return dataSource?.numberOfSections?(in: self) ?? 1
        }
    }
    
    fileprivate func rowCount(in section: Int) -> Int {
        if let rows = sectionRows[section] {
            return rows
        } else {
            let rowCount = dataSource?.infiniteView(self, numberOfRowsInSection: section) ?? 0
            sectionRows[section] = rowCount
            return rowCount
        }
    }
    
    fileprivate func forEachIndexPath(section: Int, rows: [Int], body: (IndexPath, Threshold) -> Void) {
        let absSection: Int
        let threshold: Threshold
        
        if infinite {
            absSection = sectionRows.abs(section)
            threshold = sectionRows.threshold(with: section)
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
                contentInset = inset
                scrollIndicatorInsets = inset
            }
            
            if isNeedReloadData == false {
                isNeedInvalidateLayout = true
            }
        }
        
        if isNeedReloadData {
            isNeedInvalidateLayout = false
            sectionRows.removeAll()
            currentInfo = ViewVisibleInfo()
            
            currentMatrix = makeMatrix()
            contentSize = currentMatrix.contentSize
        }
        
        if isNeedInvalidateLayout {
            let oldMatrix = currentMatrix
            
            currentMatrix = makeMatrix()
            contentSize = currentMatrix.contentSize
            // ->>
            let count = currentMatrix.insets.left.scale - oldMatrix.insets.left.scale
            let newWidth = currentMatrix.originalContentSize.width + currentMatrix.insets.all.width * oldMatrix.insets.all.scale
            let oldWidth = oldMatrix.contentSize.width
            contentOffset.x = newWidth * lastContentOffset.x / oldWidth + currentMatrix.insets.all.width * CGFloat(count)
            // <<-
            
            layoutedToLazyRemoveCells(oldMatrix: oldMatrix)
        } else {
            if infiniteIfNeeded(with: currentMatrix) && isNeedReloadData == false {
                layoutedCells()
            } else {
                layoutedToRemoveCells()
            }
        }
        
        isNeedInvalidateLayout = false
        isNeedReloadData = false
        lastContentOffset = contentOffset
        
    }
    
    private func layoutedCells() {
        let nextInfo = makeVisibleInfo(matrix: currentMatrix)
        
        replaceCurrentVisibleInfo(nextInfo)
        setFrame(for: currentInfo.rows(), at: currentInfo, matrix: currentMatrix)
    }
    
    private func layoutedToRemoveCells() {
        let nextInfo = makeVisibleInfo(matrix: currentMatrix)
        
        let sameSections = nextInfo.sections().intersection(currentInfo.sections())
        sameSections.forEach { section in
            let oldRows = currentInfo.subtractingRows(with: nextInfo, in: section)
            removeCells(of: oldRows, in: section)
            
            let newRows = nextInfo.subtractingRows(with: currentInfo, in: section)
            appendCells(at: newRows, in: section, matrix: currentMatrix)
        }
        
        if sameSections.count != nextInfo.sections().count {
            let newSections = nextInfo.subtractingSections(with: currentInfo)
            newSections.forEach { section in
                appendCells(at: nextInfo.rows(in: section), in: section, matrix: currentMatrix)
            }
        }
        
        if sameSections.count != currentInfo.sections().count {
            let oldSections = currentInfo.subtractingSections(with: nextInfo)
            removeCells(of: oldSections)
        }
        
        replaceCurrentVisibleInfo(nextInfo)
    }
    
    private func layoutedToLazyRemoveCells(oldMatrix: ViewMatrix) {
        let nextInfo = makeVisibleInfo(matrix: currentMatrix)
        
        var layoutInfo = ViewVisibleInfo<Cell>()
        layoutInfo.replaceSection(nextInfo.sections().union(currentInfo.sections()))
        
        let offset = validityContentOffset
        layoutInfo.replaceRows {
            currentMatrix.visibleRow(for: offset, in: $0).union(oldMatrix.visibleRow(for: offset, in: $0))
        }
        
        layoutInfo.sections().forEach { section in
            if nextInfo.rows(in: section).count <= 0 {
                lazyRemoveRows[section] = layoutInfo.rows(in: section)
            } else {
                let diffRows = layoutInfo.subtractingRows(with: nextInfo, in: section)
                if diffRows.count > 0 {
                    lazyRemoveRows[section] = diffRows
                }
            }
            
            let newRows = layoutInfo.subtractingRows(with: currentInfo, in: section)
            appendCells(at: newRows, in: section, matrix: oldMatrix)
        }
        
        replaceCurrentVisibleInfo(nextInfo)
        
        setFrame(for: currentInfo.rows(), at: currentInfo, matrix: currentMatrix)
        setFrame(for: lazyRemoveRows, at: currentInfo, matrix: currentMatrix)
    }
    
    private func replaceCurrentVisibleInfo(_ info: ViewVisibleInfo<Cell>) {
        var nextInfo = info
        nextInfo.replaceObject(with: currentInfo)
        nextInfo.replaceSelectedIndexPath(with: currentInfo)
        currentInfo = nextInfo
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
    
    private func setFrame<T: UIView>(for sectionRows: [Int: [Int]], at visibleInfo: ViewVisibleInfo<T>, matrix: ViewMatrix) {
        for (section, rows) in sectionRows {
            forEachIndexPath(section: section, rows: rows) { indexPath, threshold in
                visibleInfo.object(at: indexPath)?.frame = matrix.rowRect(at: indexPath, threshold: threshold)
            }
        }
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
