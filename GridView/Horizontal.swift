//
//  Horizontal.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/28.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import CoreGraphics

struct Horizontal: Equatable {
    static let zero = Horizontal(x: 0, width: 0)
    
    static func ==(lhs: Horizontal, rhs: Horizontal) -> Bool {
        return lhs.x == rhs.x && lhs.width == rhs.width
    }
    
    static func *(lhs: Horizontal, rhs: CGFloat) -> Horizontal {
        return Horizontal(x: lhs.x * rhs, width: lhs.width * rhs)
    }
    
    var x: CGFloat {
        didSet {
            maxX = maxX - oldValue + x
        }
    }
    var width: CGFloat {
        didSet {
            maxX = maxX - oldValue + width
        }
    }
    private(set) var maxX: CGFloat
    var integral: Horizontal {
        return Horizontal(origin: self)
    }
    
    init(x: CGFloat, width: CGFloat) {
        self.x = x
        self.width = width
        self.maxX = x + width
    }
    
    private init(origin: Horizontal) {
        self.x = origin.x.integral
        self.width = origin.width.integral
        self.maxX = (origin.x + origin.width).integral
    }
}
