//
//  Horizontal.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/28.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import CoreGraphics

struct Horizontal {
    static let zero = Horizontal(x: 0, width: 0)
    
    static func *(lhs: Horizontal, rhs: CGFloat) -> Horizontal {
        return Horizontal(x: lhs.x * rhs, width: lhs.width * rhs)
    }
    
    var x: CGFloat
    var width: CGFloat
    
    var maxX: CGFloat {
        return x + width
    }
}
