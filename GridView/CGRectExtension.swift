//
//  CGRectExtension.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/26.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import CoreGraphics

extension CGRect {
    init(horizontal: Horizontal) {
        self.init(x: horizontal.x, y: 0, width: horizontal.width, height: 0)
    }
    init(vertical: Vertical) {
        self.init(x: 0, y: vertical.y, width: 0, height: vertical.height)
    }
    init(horizontal: Horizontal, vertical: Vertical) {
        self.init(x: horizontal.x, y: vertical.y, width: horizontal.width, height: vertical.height)
    }
    
    var vertical: Vertical {
        get {
            return Vertical(y: origin.y, height: height)
        }
        set {
            origin.y = newValue.y
            size.height = newValue.height
        }
    }
    
    var horizontal: Horizontal {
        get {
            return Horizontal(x: origin.x, width: width)
        }
        set {
            origin.x = newValue.x
            size.width = newValue.width
        }
    }
}
