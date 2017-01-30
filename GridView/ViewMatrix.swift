//
//  ViewMatrix.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/25.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

struct ViewMatrix: Countable {
    private let isInfinitable: Bool
    private let horizontals: [Horizontal]?
    private let verticals: [[Vertical?]]
    private let visibleSize: CGSize?
    private let viewFrame: CGRect
    private let scale: Scale
    private let inset: UIEdgeInsets
    private let aroundInset: AroundInsets
    private let contentHeight: CGFloat
    
    let validityContentRect: CGRect
    let contentSize: CGSize
    let contentInset: UIEdgeInsets
    var count: Int {
        return verticals.count
    }
    
    func convertToActualOffset(_ offset: CGPoint) -> CGPoint {
        return CGPoint(x: offset.x - aroundInset.left.width, y: offset.y)
    }
    
    func convert(_ offset: CGPoint, from matrix: ViewMatrix) -> CGPoint {
        let oldContentOffset = offset + matrix.viewFrame.origin
        let indexPath = matrix.indexPathForRow(at: oldContentOffset)
        
        let oldRect = matrix.rectForRow(at: indexPath)
        let oldOffset = oldContentOffset - oldRect.origin
        guard oldRect.width != 0 && oldRect.height != 0 else { return .zero }
        
        let newRect = rectForRow(at: indexPath)
        let newOffset = CGPoint(x: newRect.width * oldOffset.x / oldRect.width, y: newRect.height * oldOffset.y / oldRect.height)
        
        let contentOffset = newRect.origin + newOffset
        
        let actualSize: CGSize = contentSize - (visibleSize ?? .zero)
        let maxOffset = CGPoint(x: viewFrame.origin.x + inset.right + actualSize.width, y: viewFrame.origin.y + inset.bottom + actualSize.height)
        let minOffset = CGPoint(x: viewFrame.origin.x - inset.left, y: viewFrame.origin.y - inset.top)
        return min(max(contentOffset, minOffset), maxOffset)
    }
    
    init() {
        self.init(horizontals: nil, verticals: [], viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .zero, inset: .zero, isInfinitable: false)
    }
    
    init(matrix: ViewMatrix, horizontals: [Horizontal]? = nil, viewFrame: CGRect, superviewSize: CGSize?, scale: Scale, inset: UIEdgeInsets) {
        let height = matrix.contentHeight
        self.init(horizontals: horizontals ?? matrix.horizontals, verticals: matrix.verticals, viewFrame: viewFrame, contentHeight: height, superviewSize: superviewSize, scale: scale, inset: inset, isInfinitable: matrix.isInfinitable)
    }
    
    init(horizontals: [Horizontal]?,  verticals: [[Vertical?]], viewFrame: CGRect, contentHeight: CGFloat, superviewSize: CGSize?, scale: Scale, inset: UIEdgeInsets, isInfinitable: Bool) {
        var contentSize: CGSize = .zero
        contentSize.width = (horizontals?.last?.maxX ?? viewFrame.width * CGFloat(verticals.count)) * scale.x
        if contentHeight == 0 {
            contentSize.height = viewFrame.height * CGFloat(verticals.first?.count ?? 0) * scale.y
        } else {
            contentSize.height = contentHeight * scale.y
        }
        
        self.horizontals = horizontals
        self.verticals = verticals
        self.viewFrame = viewFrame
        self.visibleSize = superviewSize
        self.scale = scale
        self.inset = inset
        self.contentHeight = contentHeight
        self.isInfinitable = isInfinitable
        
        let parentSize = superviewSize ?? .zero
        if isInfinitable {
            let aroundInset = AroundInsets(parentSize: parentSize, frame: viewFrame)
            self.aroundInset = aroundInset
            
            let allWidth = aroundInset.left.width + aroundInset.right.width + viewFrame.width
            self.validityContentRect = CGRect(origin: CGPoint(x: aroundInset.left.width - viewFrame.minX, y: 0), size: contentSize)
            self.contentSize = CGSize(width: contentSize.width + allWidth, height: contentSize.height)
            self.contentInset = UIEdgeInsets(top: -viewFrame.minY + inset.top, left: -aroundInset.left.width, bottom: -parentSize.height + viewFrame.maxY + inset.bottom, right: -aroundInset.right.width)
        } else {
            self.aroundInset = .zero
            self.validityContentRect = CGRect(origin: .zero, size: contentSize)
            self.contentSize = contentSize
            self.contentInset = UIEdgeInsets(top: -viewFrame.minY, left: -viewFrame.minX, bottom: -parentSize.height + viewFrame.maxY, right: -parentSize.width + viewFrame.maxX) + inset
        }
    }
    
    fileprivate func verticalsForColumn(_ column: Int) -> [Vertical?] {
        if column < 0 || column >= verticals.count {
            return []
        }
        return verticals[column]
    }
    
    fileprivate func vertical(of verticals: [Vertical?], at index: Int) -> Vertical {
        if index < 0 || index >= verticals.count {
            return .zero
        }
        guard let vertical = verticals[index] else {
            let viewHeight = viewFrame.height
            return Vertical(y: viewHeight * CGFloat(index), height: viewHeight)
        }
        return vertical
    }
    
    fileprivate func verticalForRow(at indexPath: IndexPath) -> Vertical {
        return vertical(of: verticalsForColumn(indexPath.column), at: indexPath.row) * scale.y
    }
    
    fileprivate func offsetXForColumn(_ column: Int) -> CGFloat {
        guard let horizontals = horizontals else {
            return 0
        }
        
        switch horizontals.threshold(with: column) {
        case .below:
            return -validityContentRect.width
        case .above:
            return validityContentRect.width
        case .in:
            return 0
        }
    }
    
    fileprivate func horizontalForColumn(_ column: Int) -> Horizontal {
        var horizontal: Horizontal
        if let horizontals = horizontals {
            let absColumn = self.repeat(column)
            horizontal = horizontals[absColumn] * scale.x
            horizontal.x += offsetXForColumn(column)
        } else {
            let viewWidth = viewFrame.width * scale.x
            horizontal = Horizontal(x: viewWidth * CGFloat(column), width: viewWidth)
        }
        
        return horizontal
    }
    
    func rectForRow(at indexPath: IndexPath, threshold: Threshold = .in) -> CGRect {
        let vertical = verticalForRow(at: indexPath)
        var rect = CGRect(vertical: vertical)
        rect.horizontal = horizontalForColumn(indexPath.column)
        rect.origin.x += aroundInset.left.width
        
        switch threshold {
        case .below:
            rect.origin.x -= validityContentRect.width
        case .above:
            rect.origin.x += validityContentRect.width
        case .in:
            break
        }
        
        return rect
    }
    
    func indexPathForRow(at point: CGPoint) -> IndexPath {
        let absPoint = CGPoint(x: point.x - aroundInset.left.width, y: point.y)
        let absColumn = self.repeat(column(at: absPoint))
        let row = indexForRow(at: absPoint, in: absColumn)
        return IndexPath(row: row, column: absColumn)
    }
    
    fileprivate func column(at point: CGPoint) -> Int {
        guard let horizontals = horizontals else {
            let viewWidth = viewFrame.width * scale.x
            guard viewWidth != 0 else {
                return 0
            }
            return Int(floor(point.x / viewWidth))
        }
        
        var point = point
        var column = 0
        repeat {
            if point.x < 0 {
                column += horizontals.count
                point.x += validityContentRect.width
            } else if point.x >= validityContentRect.width {
                column -= horizontals.count
                point.x -= validityContentRect.width
            }
        } while point.x < 0 || point.x >= validityContentRect.width
        
        for index in (0..<horizontals.count) {
            let horizontal = (horizontals[index] * scale.x).integral
            if horizontal.x <= point.x && horizontal.maxX > point.x {
                return index - column
            }
        }
        
        fatalError("Column did not get at location \(point).")
    }
    
    fileprivate func indexForRow(at point: CGPoint, in column: Int) -> Int {
        let step = 100
        let verticals = verticalsForColumn(column)
        
        for index in stride(from: 0, to: verticals.count, by: step) {
            let next = index + step
            guard verticals.count <= next || vertical(of: verticals, at: next).maxY * scale.y > point.y else {
                continue
            }
            
            for offset in (index..<verticals.count) {
                guard vertical(of: verticals, at: offset).maxY * scale.y > point.y else {
                    continue
                }
                
                return offset
            }
        }
        
        return 0
    }
    
    func indexesForVisibleColumn(at point: CGPoint) -> [Int] {
        var columns: [Int] = []
        guard let visibleSize = visibleSize else {
            return columns
        }
        
        let visibleRect = CGRect(origin: CGPoint(x: point.x - aroundInset.left.width, y: 0), size: visibleSize)
        let index = column(at: visibleRect.origin)
        
        var frame = CGRect(origin: .zero, size: viewFrame.size)
        for offset in (0..<count) {
            let column = offset + index
            frame.horizontal = horizontalForColumn(column)
            
            if visibleRect.intersects(frame) {
                columns.append(column)
            } else if columns.count > 0 {
                break
            }
        }
        
        return columns
    }
    
    func indexesForVisibleRow(at point: CGPoint, in column: Int) -> [Int] {
        var rows: [Int] = []
        guard let visibleSize = visibleSize else {
            return rows
        }
        
        let visibleRect = CGRect(origin: CGPoint(x: 0, y: point.y), size: visibleSize)
        let absColumn: Int
        if isInfinitable {
            absColumn = self.repeat(column)
        } else {
            absColumn = column
        }
        
        let index = indexForRow(at: visibleRect.origin, in: absColumn)
        let verticals = verticalsForColumn(absColumn)
        
        var rect: CGRect = .zero
        rect.size.width = horizontalForColumn(column).width
        for row in (index..<verticals.count) {
            rect.vertical = vertical(of: verticals, at: row) * scale.y
            
            if visibleRect.intersects(rect) {
                rows.append(row)
            } else if rows.count > 0 {
                break
            }
        }
        
        return rows
    }
}

#if DEBUG
extension ViewMatrix {
    func debugVerticalsForColumn(_ column: Int) -> [Vertical?] {
        return verticalsForColumn(column)
    }
    func debugVerticalForRow(at indexPath: IndexPath) -> Vertical {
        return verticalForRow(at: indexPath)
    }
    func debugOffsetXForColumn(_ column: Int) -> CGFloat {
        return offsetXForColumn(column)
    }
    func debugHorizontalForColumn(_ column: Int) -> Horizontal {
        return horizontalForColumn(column)
    }
    func debugColumn(at point: CGPoint) -> Int {
        return column(at: point)
    }
    func debugIndexForRow(at point: CGPoint, in column: Int) -> Int {
        return indexForRow(at: point, in: column)
    }
}
#endif
