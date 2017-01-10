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
    private let aroundInset: AroundInsets
    private let contentHeight: CGFloat
    
    let validityContentRect: CGRect
    let contentSize: CGSize
    let contentInset: UIEdgeInsets
    var count: Int {
        return verticals.count
    }
    
    func convert(_ offset: CGPoint, from matrix: ViewMatrix) -> CGPoint {
        let oldContentOffset = offset + matrix.viewFrame.origin
        let indexPath = matrix.indexPathForRow(at: oldContentOffset)
        let oldRect = matrix.rectForRow(at: indexPath)
        let newRect = rectForRow(at: indexPath)
        let oldOffset = oldContentOffset - oldRect.origin
        guard oldRect.width != 0 && oldRect.height != 0 else { return .zero }
        let newOffset = CGPoint(x: newRect.width * oldOffset.x / oldRect.width, y: newRect.height * oldOffset.y / oldRect.height)
        let viewOrigin = rectForRow(at: indexPath).origin
        let contentOffset = viewOrigin + newOffset
        let parentSize: CGSize = visibleSize ?? .zero
        let edgeOrigin = CGPoint(x: contentSize.width - parentSize.width, y: contentSize.height - parentSize.height) + viewFrame.origin
        return min(max(contentOffset, viewFrame.origin), edgeOrigin)
    }
    
    init() {
        self.init(horizontals: nil, verticals: [], viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .zero, isInfinitable: false)
    }
    
    init(matrix: ViewMatrix, horizontals: [Horizontal]? = nil, viewFrame: CGRect, superviewSize: CGSize?, scale: Scale) {
        let height = matrix.contentHeight
        self.init(horizontals: horizontals ?? matrix.horizontals, verticals: matrix.verticals, viewFrame: viewFrame, contentHeight: height, superviewSize: superviewSize, scale: scale, isInfinitable: matrix.isInfinitable)
    }
    
    init(horizontals: [Horizontal]?,  verticals: [[Vertical?]], viewFrame: CGRect, contentHeight: CGFloat, superviewSize: CGSize?, scale: Scale, isInfinitable: Bool) {
        var contentSize: CGSize = .zero
        contentSize.width = (horizontals?.last?.maxX ?? viewFrame.width * CGFloat(verticals.count)) * scale.x
        contentSize.height = contentHeight * scale.y
        
        self.horizontals = horizontals
        self.verticals = verticals
        self.viewFrame = viewFrame
        self.visibleSize = superviewSize
        self.scale = scale
        self.contentHeight = contentHeight
        self.isInfinitable = isInfinitable
        
        let parentSize = superviewSize ?? .zero
        if isInfinitable {
            let inset = AroundInsets(parentSize: parentSize, frame: viewFrame)
            self.aroundInset = inset
            
            let allWidth = inset.left.width + inset.right.width + viewFrame.width
            self.validityContentRect = CGRect(origin: CGPoint(x: inset.left.width - viewFrame.minX, y: 0), size: contentSize)
            self.contentSize = CGSize(width: contentSize.width + allWidth, height: contentSize.height)
            self.contentInset = UIEdgeInsets(top: -viewFrame.minY, left: -inset.left.width, bottom: -parentSize.height + viewFrame.maxY, right: -inset.right.width)
        } else {
            self.aroundInset = .zero
            self.validityContentRect = CGRect(origin: .zero, size: contentSize)
            self.contentSize = contentSize
            self.contentInset = UIEdgeInsets(top: -viewFrame.minY, left: -viewFrame.minX, bottom: -parentSize.height + viewFrame.maxY, right: -parentSize.width + viewFrame.maxX)
        }
    }
    
    fileprivate func verticalsForSection(_ section: Int) -> [Vertical?] {
        if section < 0 || section >= verticals.count {
            return []
        }
        return verticals[section]
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
        return vertical(of: verticalsForSection(indexPath.section), at: indexPath.row) * scale.y
    }
    
    fileprivate func offsetXForSection(_ section: Int) -> CGFloat {
        guard let horizontals = horizontals else {
            return 0
        }
        
        switch horizontals.threshold(with: section) {
        case .below:
            return -validityContentRect.width
        case .above:
            return validityContentRect.width
        case .in:
            return 0
        }
    }
    
    fileprivate func horizontalForSection(_ section: Int) -> Horizontal {
        var horizontal: Horizontal
        if let horizontals = horizontals {
            let absSection = self.repeat(section)
            horizontal = horizontals[absSection] * scale.x
            horizontal.x += offsetXForSection(section)
        } else {
            let viewWidth = viewFrame.width * scale.x
            horizontal = Horizontal(x: viewWidth * CGFloat(section), width: viewWidth)
        }
        
        return horizontal
    }
    
    func rectForRow(at indexPath: IndexPath, threshold: Threshold = .in) -> CGRect {
        let vertical = verticalForRow(at: indexPath)
        var rect = CGRect(vertical: vertical)
        rect.horizontal = horizontalForSection(indexPath.section)
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
        let absSection = self.repeat(section(at: absPoint))
        let row = indexForRow(at: absPoint, in: absSection)
        return IndexPath(row: row, section: absSection)
    }
    
    fileprivate func section(at point: CGPoint) -> Int {
        guard let horizontals = horizontals else {
            let viewWidth = viewFrame.width * scale.x
            guard viewWidth != 0 else {
                return 0
            }
            return Int(floor(point.x / viewWidth))
        }
        
        var point = point
        var section = 0
        repeat {
            if point.x < 0 {
                section += horizontals.count
                point.x += validityContentRect.width
            } else if point.x >= validityContentRect.width {
                section -= horizontals.count
                point.x -= validityContentRect.width
            }
        } while point.x < 0 || point.x >= validityContentRect.width
        
        for index in (0..<horizontals.count) {
            let horizontal = (horizontals[index] * scale.x).integral
            if horizontal.x <= point.x && horizontal.maxX > point.x {
                return index - section
            }
        }
        
        fatalError("Section did not get at location \(point).")
    }
    
    fileprivate func indexForRow(at point: CGPoint, in section: Int) -> Int {
        let step = 100
        let verticals = verticalsForSection(section)
        
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
    
    func indexesForVisibleSection(at point: CGPoint) -> [Int] {
        var sections: [Int] = []
        guard let visibleSize = visibleSize else {
            return sections
        }
        
        let visibleRect = CGRect(origin: CGPoint(x: point.x - aroundInset.left.width, y: 0), size: visibleSize)
        let index = section(at: visibleRect.origin)
        
        var frame = CGRect(origin: .zero, size: viewFrame.size)
        for offset in (0..<count) {
            let section = offset + index
            frame.horizontal = horizontalForSection(section)
            
            if visibleRect.intersects(frame) {
                sections.append(section)
            } else if sections.count > 0 {
                break
            }
        }
        
        return sections
    }
    
    func indexesForVisibleRow(at point: CGPoint, in section: Int) -> [Int] {
        var rows: [Int] = []
        guard let visibleSize = visibleSize else {
            return rows
        }
        
        let visibleRect = CGRect(origin: CGPoint(x: 0, y: point.y), size: visibleSize)
        let absSection: Int
        if isInfinitable {
            absSection = self.repeat(section)
        } else {
            absSection = section
        }
        
        let index = indexForRow(at: visibleRect.origin, in: absSection)
        let verticals = verticalsForSection(absSection)
        
        var rect: CGRect = .zero
        rect.size.width = horizontalForSection(section).width
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
    func debugVerticalsForSection(_ section: Int) -> [Vertical?] {
        return verticalsForSection(section)
    }
    func debugVerticalForRow(at indexPath: IndexPath) -> Vertical {
        return verticalForRow(at: indexPath)
    }
    func debugOffsetXForSection(_ section: Int) -> CGFloat {
        return offsetXForSection(section)
    }
    func debugHorizontalForSection(_ section: Int) -> Horizontal {
        return horizontalForSection(section)
    }
    func debugSection(at point: CGPoint) -> Int {
        return section(at: point)
    }
    func debugIndexForRow(at point: CGPoint, in section: Int) -> Int {
        return indexForRow(at: point, in: section)
    }
}
#endif
