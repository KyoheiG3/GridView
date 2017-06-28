//
//  GridView.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/10/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

// MARK: -
@objc public protocol GridViewDataSource: class {
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell
    
    @objc optional func numberOfColumns(in gridView: GridView) -> Int
}

// MARK: -
@objc public protocol GridViewDelegate: UIScrollViewDelegate {
    @objc optional func gridView(_ gridView: GridView, willDisplay cell: GridViewCell, forRowAt indexPath: IndexPath)
    @objc optional func gridView(_ gridView: GridView, didEndDisplaying cell: GridViewCell, forRowAt indexPath: IndexPath)
    
    @objc optional func gridView(_ gridView: GridView, didHighlightRowAt indexPath: IndexPath)
    @objc optional func gridView(_ gridView: GridView, didUnhighlightRowAt indexPath: IndexPath)
    
    @objc optional func gridView(_ gridView: GridView, didSelectRowAt indexPath: IndexPath)
    
    /// Default is same with view height.
    @objc optional func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat
    /// Default is same with view width.
    @objc optional func gridView(_ gridView: GridView, widthForColumn column: Int) -> CGFloat
    
    @objc optional func gridView(_ gridView: GridView, didScaleAt scale: CGFloat)
}

// MARK: -
open class GridView: UIScrollView {
    fileprivate typealias Cell = GridViewCell
    
    // MARK: Properties
    override open class var layerClass : AnyClass {
        return AnimatedLayer.self
    }

    /// Set `false` if you don't need to loop of view. Default is `true`.
    open var isInfinitable = true
    /// Set the vertical and horizontal minimum scales. Default for x and y are 1.
    open var minimumScale: Scale = .default
    /// Set the vertical and horizontal maximum scales. Default for x and y are 1.
    open var maximumScale: Scale = .default
    /// Get current vertical and horizontal scales.
    public fileprivate(set) var currentScale: Scale = .default
    /// Set true if need to improve view layout performance. Default is false.
    open var layoutWithoutFillForCell: Bool = false
    open var actualContentOffset: CGPoint {
        return currentMatrix.convertToActualOffset(contentOffset)
    }
    
    @IBOutlet open weak var dataSource: GridViewDataSource?
    
    private let pinchGesture = UIPinchGestureRecognizer()
    private var currentViewBounds: CGRect = .zero
    private var beginningPinchScale: CGFloat = 1
    private var animatedLayer: AnimatedLayer {
        return layer as! AnimatedLayer
    }
    
    fileprivate private(set) var columnRow: [Int: Int] = [:]
    fileprivate private(set) var currentMatrix = ViewMatrix()
    fileprivate var lastValidityContentOffset: CGPoint = .zero
    
    fileprivate var highlightedIndexPath: IndexPath?
    fileprivate var withoutScrollDelegation = false
    fileprivate var needsLayout: NeedsLayout = .reload
    fileprivate var lazyRemoveRows: [Int: [Int]] = [:]
    fileprivate var currentInfo = ViewVisibleInfo<Cell>()
    fileprivate var reuseQueue = ReuseQueue<Cell>()
    fileprivate var bundle = ViewBundle<Cell>()
    fileprivate var currentPinchScale: CGFloat = 1
    fileprivate var gridViewDelegate: GridViewDelegate? {
        return delegate as? GridViewDelegate
    }
    
    public private(set) weak var originDelegate: UIScrollViewDelegate?
    override open var delegate: UIScrollViewDelegate? {
        get { return originDelegate }
        set { originDelegate = newValue }
    }
    private var originContentInset: UIEdgeInsets = .zero
    override open var contentInset: UIEdgeInsets {
        get { return originContentInset }
        set { originContentInset = newValue }
    }
    private var originScrollIndicatorInsets: UIEdgeInsets = .zero
    override open var scrollIndicatorInsets: UIEdgeInsets {
        get { return originScrollIndicatorInsets }
        set { originScrollIndicatorInsets = newValue }
    }
    
    // MARK: Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.delegate = self
        pinchGesture.addTarget(self, action: #selector(GridView.handlePinch))
        addGestureRecognizer(pinchGesture)
        clipsToBounds = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        super.delegate = self
        pinchGesture.addTarget(self, action: #selector(GridView.handlePinch))
        addGestureRecognizer(pinchGesture)
        clipsToBounds = false
    }
    
    override open func responds(to aSelector: Selector!) -> Bool {
        return originDelegate?.responds(to: aSelector) == true || super.responds(to: aSelector)
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let origin = CGPoint(x: -contentInset.left, y: -contentInset.top)
        let size = CGSize(width: contentSize.width + contentInset.horizontal, height: contentSize.height + contentInset.vertical)
        return CGRect(origin: origin, size: size).contains(point)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        withoutScrollDelegation = true
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first, highlightedIndexPath == nil {
            let location = touch.location(in: self)
            let indexPath = currentMatrix.indexPathForRow(at: location)
            highlightRow(at: indexPath)
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let indexPath = highlightedIndexPath {
            unhighlightRow(at: indexPath)
            selectRow(at: indexPath)
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if let indexPath = highlightedIndexPath {
            unhighlightRow(at: indexPath)
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        withoutScrollDelegation = false
        
        if bounds.size != currentViewBounds.size {
            currentViewBounds = bounds
            
            if needsLayout == .none {
                needsLayout = .layout(.rotating(currentMatrix))
            }
        }
        
        let areAnimationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(!layoutWithoutFillForCell)
        
        switch needsLayout {
        case .reload:
            if let superview = superview {
                let inset = UIEdgeInsets(top: -frame.minY, left: -frame.minX, bottom: -superview.bounds.height + frame.maxY, right: -superview.bounds.width + frame.maxX)
                super.scrollIndicatorInsets = inset + originScrollIndicatorInsets
            }
            
            stopScroll()
            
            columnRow.removeAll()
            currentInfo = ViewVisibleInfo()
            currentMatrix = makeMatrix(.all(currentMatrix))
            
            performWithoutDelegation {
                contentSize = currentMatrix.contentSize
            }
            contentOffset = currentMatrix.convert(lastValidityContentOffset, from: currentMatrix)
            super.contentInset = currentMatrix.contentInset
            
            infiniteIfNeeded()
            layoutToRemoveCells()
            
        case .layout(let type):
            stopScroll()
            
            currentMatrix = makeMatrix(type)
            
            withoutScrollDelegation = true
            contentSize = currentMatrix.contentSize
            withoutScrollDelegation = type.isScaling
            contentOffset = currentMatrix.convert(lastValidityContentOffset, from: type.matrix)
            withoutScrollDelegation = false
            super.contentInset = currentMatrix.contentInset
            
            if layoutWithoutFillForCell == true {
                layoutToRemoveCells(needsLayout: true)
            } else if case .pinching = type {
                layoutToRemoveCells(needsLayout: true)
            } else {
                animatedLayer.animate()
                layoutToLazyRemoveCells(with: type.matrix)
            }
            
            if type.isScaling {
                gridViewDelegate?.gridView?(self, didScaleAt: currentPinchScale)
            } else {
                if let superview = superview {
                    let inset = UIEdgeInsets(top: -frame.minY, left: -frame.minX, bottom: -superview.bounds.height + frame.maxY, right: -superview.bounds.width + frame.maxX)
                    super.scrollIndicatorInsets = inset + originScrollIndicatorInsets
                }
            }
            
        case .none:
            if let offset = infiniteValidityOffset() {
                layoutToRemoveCells(offset: offset)
                infiniteIfNeeded()
            } else {
                layoutToRemoveCells()
            }
            
        }
        
        UIView.setAnimationsEnabled(areAnimationsEnabled)
        needsLayout = .none
        lastValidityContentOffset = validityContentOffset
    }
    
    // MARK: Actions
    dynamic private func handlePinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginningPinchScale = currentPinchScale
            
        case .changed:
            contentScale(beginningPinchScale + (gesture.scale - 1), lazyRemoveCells: false)
            
        default:
            return
        }
    }
    
    // MARK: Functions
    fileprivate func absoluteColumn(_ column: Int) -> Int {
        return columnRow.repeat(column)
    }
    
    fileprivate func columnCount() -> Int {
        if columnRow.count > 0 {
            return columnRow.count
        } else {
            return dataSource?.numberOfColumns?(in: self) ?? 1
        }
    }
    
    fileprivate func rowCount(in column: Int) -> Int {
        if let rowCount = columnRow[column] {
            return rowCount
        } else {
            let rowCount = dataSource?.gridView(self, numberOfRowsInColumn: column) ?? 0
            columnRow[column] = rowCount
            return rowCount
        }
    }
    
    fileprivate func forEachIndexPath(column: Int, rows: [Int], body: (IndexPath, Threshold) -> Void) {
        let absColumn: Int
        let threshold: Threshold
        
        if isInfinitable {
            absColumn = absoluteColumn(column)
            threshold = columnRow.threshold(with: column)
        } else {
            absColumn = column
            threshold = .in
        }
        
        for row in rows {
            let indexPath = IndexPath(row: row, column: absColumn)
            body(indexPath, threshold)
        }
    }
    
    private func infiniteIfNeeded() {
        guard isInfinitable else {
            return
        }
        
        let matrix = currentMatrix
        if validityContentOffset.x < matrix.validityContentRect.minX {
            contentOffset.x += matrix.validityContentRect.width
        } else if validityContentOffset.x >= matrix.validityContentRect.maxX {
            contentOffset.x -= matrix.validityContentRect.width
        }
    }
    
    private func infiniteValidityOffset() -> CGPoint? {
        guard isInfinitable else {
            return nil
        }
        
        let matrix = currentMatrix
        let offsetY = contentOffset.y - frame.minY
        if validityContentOffset.x < matrix.validityContentRect.minX {
            return CGPoint(x: validityContentOffset.x + matrix.validityContentRect.width, y: offsetY)
        } else if validityContentOffset.x >= matrix.validityContentRect.maxX {
            return CGPoint(x: validityContentOffset.x - matrix.validityContentRect.width, y: offsetY)
        } else {
            return nil
        }
    }
    
    private func stopScroll() {
        performWithoutDelegation {
            super.setContentOffset(contentOffset, animated: false)
        }
    }
    
    private func performWithoutDelegation(_ closure: () -> Void) {
        let delegation = withoutScrollDelegation
        withoutScrollDelegation = true
        closure()
        withoutScrollDelegation = delegation
    }
}

// MARK: - View Information
extension GridView {
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
    
    public func indexPathForRow(at position: CGPoint) -> IndexPath {
        return currentMatrix.indexPathForRow(at: position)
    }
}

// MARK: - View Operation
extension GridView {
    private func setNeedsLayout(_ newLayout: NeedsLayout) {
        switch (newLayout, needsLayout) {
        case (.layout(let lhs), .layout(let rhs)):
            guard lhs >= rhs else { return }
            
        case (let lhs, let rhs):
            guard lhs >= rhs else { return }
            
        }
        
        needsLayout = newLayout
        setNeedsLayout()
    }
    
    fileprivate func contentScale(_ scale: CGFloat, lazyRemoveCells: Bool) {
        let maximum = maximumScale.max()
        let minimum = minimumScale.min()
        let pinchScale = min(max(scale, minimum), maximum)
        
        guard currentPinchScale != pinchScale else { return }
        currentPinchScale = pinchScale
        
        let trimedScale = min(max(Scale(x: pinchScale, y: pinchScale), minimumScale), maximumScale)
        guard currentScale != trimedScale else { return }
        currentScale = trimedScale
        
        if lazyRemoveCells {
            setNeedsLayout(.layout(.scaling(currentMatrix)))
        } else {
            setNeedsLayout(.layout(.pinching(currentMatrix)))
        }
    }
    
    public func contentScale(_ scale: CGFloat) {
        if currentPinchScale != scale {
            contentScale(scale, lazyRemoveCells: true)
        }
    }
    
    public func reloadData() {
        setNeedsLayout(.reload)
        layoutIfNeeded()
    }
    
    public func invalidateContentSize() {
        setNeedsLayout(.layout(.rotating(currentMatrix)))
    }
    
    public func invalidateLayout(horizontally: Bool = false) {
        if horizontally {
            setNeedsLayout(.layout(.horizontally(currentMatrix)))
        } else {
            setNeedsLayout(.layout(.all(currentMatrix)))
        }
    }
    
    fileprivate func highlightRow(at indexPath: IndexPath) {
        highlightedIndexPath = indexPath
        let cell = currentInfo.object(at: indexPath)
        cell?.isHighlighted = true
        gridViewDelegate?.gridView?(self, didHighlightRowAt: indexPath)
    }
    
    fileprivate func unhighlightRow(at indexPath: IndexPath) {
        highlightedIndexPath = nil
        let cell = currentInfo.object(at: indexPath)
        cell?.isHighlighted = false
        gridViewDelegate?.gridView?(self, didUnhighlightRowAt: indexPath)
    }
    
    fileprivate func selectRow(at indexPath: IndexPath) {
        let cell = currentInfo.selected(at: indexPath)
        cell?.isSelected = true
        gridViewDelegate?.gridView?(self, didSelectRowAt: indexPath)
    }
    
    public func deselectRow(at indexPath: IndexPath) {
        let cell = currentInfo.deselected(at: indexPath)
        cell?.isSelected = false
    }
    
    open override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if isInfinitable {
            let matrix = currentMatrix
            lastValidityContentOffset = CGPoint(x: contentOffset.x + matrix.validityContentRect.minX, y: contentOffset.y + matrix.validityContentRect.minY)
        } else {
            lastValidityContentOffset = contentOffset
        }
        
        let newOffset = CGPoint(x: lastValidityContentOffset.x + frame.minX, y: lastValidityContentOffset.y + frame.minY)
        super.setContentOffset(newOffset, animated: animated)
    }
    
    public func scrollToRow(at indexPath: IndexPath, at scrollPosition: GridViewScrollPosition = [], animated: Bool = false) {
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
        super.setContentOffset(offset, animated: animated)
    }
    
    private func scrollVerticallyOffset(at rect: CGRect, at position: GridViewScrollPosition) -> CGFloat {
        let currentOffset = validityContentOffset
        let superviewFrame = superview?.bounds ?? .zero
        
        let anyVertically: [GridViewScrollPosition] = [.top, .centeredVertically, .bottom, .topFit, .bottomFit]
        let offsetY: CGFloat
        switch position {
        case let p where p.contains(.top),
             let p where p.contains(anyVertically) == false && rect.minY < currentOffset.y:
            offsetY = frame.minY
            
        case let p where p.contains(.topFit):
            offsetY = 0
            
        case let p where p.contains(.centeredVertically):
            offsetY = frame.minY - (superviewFrame.midY - rect.height / 2)
            
        case let p where p.contains(.bottom),
             let p where p.contains(anyVertically) == false && rect.maxY > currentOffset.y + superviewFrame.maxY:
            offsetY = frame.minY - (superviewFrame.maxY - rect.height)
            
        case let p where p.contains(.bottomFit):
            offsetY = frame.minY - (superviewFrame.maxY - rect.height) + (superviewFrame.maxY - frame.maxY)
            
        default:
            offsetY = frame.minY + currentOffset.y - rect.minY
        }
        
        return offsetY
    }
    
    private func scrollHorizontallyOffset(at rect: CGRect, at position: GridViewScrollPosition) -> CGFloat {
        let currentOffset = validityContentOffset
        let superviewFrame = superview?.bounds ?? .zero
        
        let anyHorizontally: [GridViewScrollPosition] = [.left, .centeredHorizontally, .right, .leftFit, .rightFit]
        let offsetX: CGFloat
        switch position {
        case let p where p.contains(.leftFit),
             let p where p.contains(anyHorizontally) == false && rect.minX < currentOffset.x:
            offsetX = 0
            
        case let p where p.contains(.left):
            offsetX = frame.minX
            
        case let p where p.contains(.centeredHorizontally):
            offsetX = frame.minX - (superviewFrame.midX - rect.width / 2)
            
        case let p where p.contains(.right),
             let p where p.contains(anyHorizontally) == false && rect.maxX > currentOffset.x + superviewFrame.maxX:
            offsetX = frame.minX - (superviewFrame.maxX - rect.width)
            
        case let p where p.contains(.rightFit):
            offsetX = frame.minX - (superviewFrame.maxX - rect.width) + (superviewFrame.maxX - frame.maxX)
            
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
        
        var cell: Cell!
        UIView.performWithoutAnimation {
            cell = bundle.instantiate(with: identifier)
        }
        
        if cell == nil {
            cell = bundle.instantiate(with: identifier)
        }
        
        prepare(for: cell)
        reuseQueue.append(cell, for: identifier)
        
        return cell
    }
}

// MARK: - Cell Operation
private extension GridView {
    private func makeCell(at indexPath: IndexPath, matrix: ViewMatrix, threshold: Threshold) -> Cell? {
        let cell = dataSource?.gridView(self, cellForRowAt: indexPath)
        
        if let cell = cell {
            UIView.performWithoutAnimation {
                cell.frame = matrix.rectForRow(at: indexPath, threshold: threshold)
                insertSubview(cell, at: 0)
                cell.layoutIfNeeded()
            }
        }
        
        return cell
    }
    
    func appendCells(at rows: [Int], in column: Int, matrix: ViewMatrix) {
        forEachIndexPath(column: column, rows: rows) { indexPath, threshold in
            if let cell = makeCell(at: indexPath, matrix: matrix, threshold: threshold) {
                gridViewDelegate?.gridView?(self, willDisplay: cell, forRowAt: indexPath)
                currentInfo.append(cell, at: indexPath)
            }
        }
    }
    
    func removeCells(of rows: [Int], in column: Int) {
        forEachIndexPath(column: column, rows: rows) { indexPath, _ in
            if let cell = currentInfo.removedObject(at: indexPath) {
                gridViewDelegate?.gridView?(self, didEndDisplaying: cell, forRowAt: indexPath)
            }
        }
    }
}

// MARK: - Cell Layout
private extension GridView {
    private func replaceCellForRowIn(oldColumn: Int, newColumn: Int, oldInfo: ViewVisibleInfo<Cell>, newInfo: ViewVisibleInfo<Cell>) {
        let oldRows = oldInfo.rows(in: oldColumn).subtracting(newInfo.rows(in: newColumn))
        removeCells(of: oldRows, in: oldColumn)
        
        let newRows = newInfo.rows(in: newColumn).subtracting(oldInfo.rows(in: oldColumn))
        appendCells(at: newRows, in: newColumn, matrix: currentMatrix)
    }
    
    private func replaceCell(for oldColumns: [Int], with newColumns: [Int], absOldColumns: [Int], absNewColumns: [Int], sameColumns: [Int], newInfo: ViewVisibleInfo<Cell>) {
        if sameColumns.count != newColumns.count {
            for newIndex in (0..<newColumns.count) {
                guard absOldColumns.index(of: absNewColumns[newIndex]) == nil else {
                    continue
                }
                let newColumn = newColumns[newIndex]
                appendCells(at: newInfo.rows(in: newColumn), in: newColumn, matrix: currentMatrix)
            }
        }
        
        if sameColumns.count != oldColumns.count {
            for oldIndex in (0..<oldColumns.count) {
                guard absNewColumns.index(of: absOldColumns[oldIndex]) == nil else {
                    continue
                }
                let oldColumn = oldColumns[oldIndex]
                removeCells(of: currentInfo.rows(in: oldColumn), in: oldColumn)
            }
        }
    }
    
    private func replaceCurrentVisibleInfo(_ info: ViewVisibleInfo<Cell>) {
        var newInfo = info
        newInfo.replaceObject(with: currentInfo)
        newInfo.replaceSelectedIndexPath(with: currentInfo)
        currentInfo = newInfo
    }
    
    private func setViewFrame<T: UIView>(for columnRows: [Int: [Int]], atVisibleInfo visibleInfo: ViewVisibleInfo<T>) {
        for (column, rows) in columnRows {
            forEachIndexPath(column: column, rows: rows) { indexPath, threshold in
                visibleInfo.object(at: indexPath)?.frame = currentMatrix.rectForRow(at: indexPath, threshold: threshold)
            }
        }
    }
    
    func layoutToRemoveCells(offset: CGPoint? = nil, needsLayout: Bool = false) {
        let newInfo = makeVisibleInfo(validityOffset: offset)
        let newColumns = newInfo.columns()
        let oldColumns = currentInfo.columns()
        let absNewColumns = newColumns.map(absoluteColumn)
        let absOldColumns = oldColumns.map(absoluteColumn)
        
        for oldIndex in (0..<oldColumns.count) {
            for newIndex in (0..<newColumns.count) {
                if absOldColumns[oldIndex] == absNewColumns[newIndex] {
                    replaceCellForRowIn(oldColumn: oldColumns[oldIndex], newColumn: newColumns[newIndex], oldInfo: currentInfo, newInfo: newInfo)
                    break
                }
            }
        }
        
        let sameColumns = newColumns.intersection(oldColumns)
        
        replaceCell(for: oldColumns, with: newColumns, absOldColumns: absOldColumns, absNewColumns: absNewColumns, sameColumns: sameColumns, newInfo: newInfo)
        replaceCurrentVisibleInfo(newInfo)
        
        if needsLayout || sameColumns.count != absNewColumns.intersection(absOldColumns).count {
            setViewFrame(for: currentInfo.rows(), atVisibleInfo: currentInfo)
        }
    }
    
    func layoutToLazyRemoveCells(with oldMatrix: ViewMatrix) {
        func fill(_ lhs: [Int], _ rhs: [Int]) -> [Int] {
            if  let lhsMin = lhs.min(), let lhsMax = lhs.max(), let rhsMin = rhs.min(), let rhsMax = rhs.max() {
                return [Int](min(lhsMin, rhsMin)...max(lhsMax, rhsMax))
            } else {
                return lhs.union(rhs)
            }
        }
        
        let newInfo = makeVisibleInfo()
        
        var layoutInfo = ViewVisibleInfo<Cell>()
        layoutInfo.replaceColumn(fill(newInfo.columns(), currentInfo.columns()))
        
        let lastOffset = lastValidityContentOffset
        let offset = validityContentOffset
        layoutInfo.replaceRows {
            let oldRows = oldMatrix.indexesForVisibleRow(at: lastOffset, in: $0)
            let currentRows = currentMatrix.indexesForVisibleRow(at: offset, in: $0)
            return fill(oldRows, currentRows)
        }
        
        layoutInfo.columns().forEach { column in
            let oldRows = lazyRemoveRows[column] ?? []
            let currentRows = currentInfo.rows(in: column)
            let layoutRows = layoutInfo.rows(in: column)
            let newRows = newInfo.rows(in: column)
            let needsRows = layoutRows.subtracting(currentRows).subtracting(oldRows)
            appendCells(at: needsRows, in: column, matrix: oldMatrix)
            
            if newRows.count <= 0 {
                lazyRemoveRows[column] = oldRows.union(layoutRows)
            } else {
                lazyRemoveRows[column] = oldRows.subtracting(layoutRows).subtracting(newRows)
                let diffRows = layoutRows.subtracting(newRows)
                if diffRows.count > 0 {
                    lazyRemoveRows[column] = diffRows.union(lazyRemoveRows[column] ?? [])
                }
            }
        }
        
        replaceCurrentVisibleInfo(newInfo)
        
        setViewFrame(for: currentInfo.rows(), atVisibleInfo: currentInfo)
        setViewFrame(for: lazyRemoveRows, atVisibleInfo: currentInfo)
    }
}

// MARK: - Matrix
private extension GridView {
    private func verticalsForRow(in column: Int) -> [Vertical?] {
        var contentHeight: CGFloat = 0
        return (0..<rowCount(in: column)).map { row in
            let indexPath = IndexPath(row: row, column: column)
            guard let height = gridViewDelegate?.gridView?(self, heightForRowAt: indexPath) else {
                return nil
            }
            
            defer {
                contentHeight += height
            }
            
            return Vertical(y: contentHeight, height: height)
        }
    }
    
    func makeMatrix(_ type: NeedsLayout.LayoutType) -> ViewMatrix {
        switch type {
        case .rotating(let matrix), .scaling(let matrix), .pinching(let matrix):
            return ViewMatrix(matrix: matrix, viewFrame: frame, superviewSize: superview?.bounds.size, scale: currentScale, inset: contentInset)
            
        case .all(let matrix), .horizontally(let matrix):
            let count = columnCount()
            
            var size: CGSize = .zero
            var columnHorizontals: [Horizontal] = []
            var columnRowVerticals: [[Vertical?]] = []
            
            (0..<count).forEach { column in
                if let widthForColumn = gridViewDelegate?.gridView?(self, widthForColumn: column) {
                    let horizontal = Horizontal(x: size.width, width: widthForColumn)
                    columnHorizontals.append(horizontal)
                    size.width += widthForColumn
                }
                
                if case .all = type {
                    let columnVerticals = verticalsForRow(in: column)
                    columnRowVerticals.append(columnVerticals)
                    
                    if let last = columnVerticals.last, let vertical = last, size.height < vertical.maxY {
                        size.height = vertical.maxY
                    }
                }
            }
            
            let horizontals: [Horizontal]?
            if columnHorizontals.count > 0 && columnHorizontals.count == count {
                horizontals = columnHorizontals
            } else {
                horizontals = nil
            }
            
            if case .horizontally = type {
                return ViewMatrix(matrix: matrix, horizontals: horizontals, viewFrame: frame, superviewSize: superview?.bounds.size, scale: currentScale, inset: contentInset)
            } else {
                return ViewMatrix(horizontals: horizontals, verticals: columnRowVerticals, viewFrame: frame, contentHeight: size.height, superviewSize: superview?.bounds.size, scale: currentScale, inset: contentInset, isInfinitable: isInfinitable)
            }
        }
    }
}

// MARK: - VisibleInfo
private extension GridView {
    func makeVisibleInfo(validityOffset: CGPoint? = nil) -> ViewVisibleInfo<Cell> {
        let matrix = currentMatrix
        let offset = validityOffset ?? validityContentOffset
        var currentInfo = ViewVisibleInfo<Cell>()
        currentInfo.replaceColumn(matrix.indexesForVisibleColumn(at: offset))
        currentInfo.replaceRows {
            matrix.indexesForVisibleRow(at: offset, in: $0)
        }
        
        return currentInfo
    }
}

// MARK: - AnimatedLayerDelegate
extension GridView: AnimatedLayerDelegate {
    func animatedLayer(_ layer: AnimatedLayer, statusDidChange status: AnimatedLayer.Status) {
        if status == .finished && lazyRemoveRows.count > 0 {
            lazyRemoveRows.forEach { column, rows in
                removeCells(of: rows, in: column)
            }
            lazyRemoveRows = [:]
        }
    }
}

// MARK: - UIScrollViewDelegate
extension GridView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if withoutScrollDelegation == false {
            layoutIfNeeded()
            originDelegate?.scrollViewDidScroll?(scrollView)
        }
    }
}

// for debug view hierarchy
extension GridView {
    var text: String {
        return type(of: self).className
    }
    var title: String {
        return text
    }
}
