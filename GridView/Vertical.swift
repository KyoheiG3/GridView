//
//  Vertical.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/28.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import CoreGraphics

struct Vertical: Equatable {
    static let zero = Vertical(y: 0, height: 0)
    
    static func ==(lhs: Vertical, rhs: Vertical) -> Bool {
        return lhs.y == rhs.y && lhs.height == rhs.height
    }
    
    static func *(lhs: Vertical, rhs: CGFloat) -> Vertical {
        return Vertical(y: lhs.y * rhs, height: lhs.height * rhs)
    }
    
    var y: CGFloat {
        didSet {
            maxY = maxY - oldValue + y
        }
    }
    var height: CGFloat {
        didSet {
            maxY = maxY - oldValue + height
        }
    }
    private(set) var maxY: CGFloat
    var integral: Vertical {
        return Vertical(origin: self)
    }
    
    init(y: CGFloat, height: CGFloat) {
        self.y = y
        self.height = height
        self.maxY = y + height
    }
    
    private init(origin: Vertical) {
        self.y = origin.y.integral
        self.height = origin.height.integral
        self.maxY = (origin.y + origin.height).integral
    }
}
