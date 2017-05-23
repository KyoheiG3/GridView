//
//  GridViewScrollPosition.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/28.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

public struct GridViewScrollPosition: OptionSet {
    public private(set) var rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    // The vertical positions are mutually exclusive to each other, but are bitwise or-able with the horizontal scroll positions.
    // Combining positions from the same grouping (horizontal or vertical) will result in an NSInvalidArgumentException.
    public static var top = GridViewScrollPosition(rawValue: 1 << 0)
    public static var centeredVertically = GridViewScrollPosition(rawValue: 1 << 1)
    public static var bottom = GridViewScrollPosition(rawValue: 1 << 2)
    
    // Likewise, the horizontal positions are mutually exclusive to each other.
    public static var left = GridViewScrollPosition(rawValue: 1 << 3)
    public static var centeredHorizontally = GridViewScrollPosition(rawValue: 1 << 4)
    public static var right = GridViewScrollPosition(rawValue: 1 << 5)
    
    public static var topFit = GridViewScrollPosition(rawValue: 1 << 6)
    public static var bottomFit = GridViewScrollPosition(rawValue: 1 << 7)
    public static var leftFit = GridViewScrollPosition(rawValue: 1 << 8)
    public static var rightFit = GridViewScrollPosition(rawValue: 1 << 9)
}

extension GridViewScrollPosition {
    func contains(_ members: [GridViewScrollPosition]) -> Bool {
        for member in members {
            if contains(member) {
                return true
            }
        }
        
        return false
    }
}
