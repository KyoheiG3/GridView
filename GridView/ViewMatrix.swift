//
//  ViewMatrix.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/25.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

struct ViewMatrix: Countable {
    private let infinite: Bool
    private let heights: [[CGHeight]]
    private let visibleSize: CGSize?
    private let viewFrame: CGRect
    private let aroundInset: AroundInsets
    
    let validityContentRect: CGRect
    let contentSize: CGSize
    let contentInset: UIEdgeInsets
    var count: Int {
        return heights.count
    }
    
    func convert(_ offsetX: CGFloat, from matrix: ViewMatrix) -> CGFloat {
        if infinite {
            let diffScale = aroundInset.left.scale - matrix.aroundInset.left.scale
            let oldAllScale = matrix.aroundInset.left.scale + matrix.aroundInset.right.scale + 1
            let newWidth = validityContentRect.width + viewFrame.width * oldAllScale
            let oldWidth = matrix.contentSize.width
            return newWidth * offsetX / oldWidth + viewFrame.width * diffScale
        } else {
            return contentSize.width * offsetX / matrix.contentSize.width
        }
    }
    
    init() {
        self.init(heights: [], viewFrame: .zero, contentSize: .zero, superviewSize: nil, infinite: false)
    }
    
    init(matrix: ViewMatrix, viewFrame: CGRect, contentSize: CGSize, superviewSize: CGSize?) {
        self.init(heights: matrix.heights, viewFrame: viewFrame, contentSize: contentSize, superviewSize: superviewSize, infinite: matrix.infinite)
    }
    
    init(heights: [[CGHeight]], viewFrame: CGRect, contentSize: CGSize, superviewSize: CGSize?, infinite: Bool) {
        self.heights = heights
        self.viewFrame = viewFrame
        self.visibleSize = superviewSize
        self.infinite = infinite
        
        let parentSize = superviewSize ?? .zero
        if infinite {
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
    
    private subscript(section: Int) -> [CGHeight] {
        if section < 0 || section >= heights.count {
            return []
        }
        return heights[section]
    }
    
    private subscript(section: Int, row: Int) -> CGHeight {
        let heights = self[section]
        if row < 0 || row >= heights.count {
            return .zero
        }
        return heights[row]
    }
    
    func rectForRow(at indexPath: IndexPath, threshold: Threshold = .in) -> CGRect {
        let height = self[indexPath.section, indexPath.row]
        var rect = CGRect(height: height)
        rect.size.width = viewFrame.width
        rect.origin.x = rect.size.width * CGFloat(indexPath.section)
        rect.origin.x += aroundInset.left.width
        
        switch threshold {
        case .below:
            rect.origin.x -= validityContentRect.width
        case .above:
            rect.origin.x += validityContentRect.width
        default:
            break
        }
        
        return rect
    }
    
    func indexPathForRow(at point: CGPoint) -> IndexPath {
        let absPoint = CGPoint(x: point.x - aroundInset.left.width, y: point.y)
        let absSection = abs(section(at: absPoint))
        let row = indexForRow(at: absPoint, in: absSection)
        return IndexPath(row: row, section: absSection)
    }
    
    private func section(at point: CGPoint) -> Int {
        return Int(floor(point.x / viewFrame.width))
    }
    
    private func indexForRow(at point: CGPoint, in section: Int) -> Int {
        let step = 100
        let heights = self[section]
        
        for index in stride(from: 0, to: heights.count, by: step) {
            let next = index + step
            guard heights.count <= next || heights[next].maxY > point.y else {
                continue
            }
            
            for offset in (index..<heights.count) {
                guard heights[offset].maxY > point.y else {
                    continue
                }
                
                return offset
            }
            
            return index
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
            frame.origin.x = viewFrame.width * CGFloat(section)
            
            if visibleRect.intersects(frame) {
                sections.append(section)
            } else {
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
        if infinite {
            absSection = abs(section)
        } else {
            absSection = section
        }
        
        let index = indexForRow(at: visibleRect.origin, in: absSection)
        let heights = self[absSection]
        
        var rect: CGRect = .zero
        rect.size.width = viewFrame.width
        for row in (index..<heights.count) {
            let height = heights[row]
            rect.size.height = height.height
            rect.origin.y = height.y
            
            if visibleRect.intersects(rect) {
                rows.append(row)
            } else {
                break
            }
        }
        
        return rows
    }
}
