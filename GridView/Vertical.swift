//
//  Vertical.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/28.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import CoreGraphics

struct Vertical {
    static let zero = Vertical(y: 0, height: 0)
    
    static func *(lhs: Vertical, rhs: CGFloat) -> Vertical {
        return Vertical(y: lhs.y * rhs, height: lhs.height * rhs)
    }
    
    var y: CGFloat
    var height: CGFloat
    
    var maxY: CGFloat {
        return y + height
    }
}
