//
//  ViewMatrix.swift
//  InfiniteView
//
//  Created by Kyohei Ito on 2016/11/25.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

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
