//
//  Location.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/28.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

protocol Location: Equatable {
    var x: CGFloat { get }
    var y: CGFloat { get }
    
    init(x: CGFloat, y: CGFloat)
    
    func min() -> CGFloat
    func max() -> CGFloat
}

extension Location {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func *(lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    public static func /(lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    public static func +(lhs: Self, rhs: CGFloat) -> Self {
        return Self(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    public static func -(lhs: Self, rhs: CGFloat) -> Self {
        return Self(x: lhs.x - rhs, y: lhs.y - rhs)
    }
    
    func min() -> CGFloat {
        return Swift.min(x, y)
    }
    
    func max() -> CGFloat {
        return Swift.max(x, y)
    }
}

extension CGPoint: Location {}

func max<T: Location>(_ lhs: T, _ rhs: T...) -> T {
    let rx = rhs.max(by: { $0.x < $1.x })?.x ?? lhs.x
    let ry = rhs.max(by: { $0.y < $1.y })?.y ?? lhs.y
    return T(x: max(lhs.x, rx), y: max(lhs.y, ry))
}

func min<T: Location>(_ lhs: T, _ rhs: T...) -> T {
    let rx = rhs.min(by: { $0.x < $1.x })?.x ?? lhs.x
    let ry = rhs.min(by: { $0.y < $1.y })?.y ?? lhs.y
    return T(x: min(lhs.x, rx), y: min(lhs.y, ry))
}
