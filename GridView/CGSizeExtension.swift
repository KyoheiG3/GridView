//
//  CGSizeExtension.swift
//  GridView
//
//  Created by Kyohei Ito on 2017/01/29.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import CoreGraphics

extension CGSize {
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func -(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
}
