//
//  CGHeight.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/26.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import CoreGraphics

struct CGWidth {
    static let zero = CGWidth(x: 0, width: 0)
    
    var x: CGFloat
    var width: CGFloat
    
    var maxX: CGFloat {
        return x + width
    }
}

struct CGHeight {
    static let zero = CGHeight(y: 0, height: 0)
    
    var y: CGFloat
    var height: CGFloat
    
    var maxY: CGFloat {
        return y + height
    }
}

extension CGRect {
    init(width: CGWidth) {
        self.init(x: width.x, y: 0, width: width.width, height: 0)
    }
    init(height: CGHeight) {
        self.init(x: 0, y: height.y, width: 0, height: height.height)
    }
    init(width: CGWidth, height: CGHeight) {
        self.init(x: width.x, y: height.y, width: width.width, height: height.height)
    }
    
    var vertical: CGHeight {
        get {
            return CGHeight(y: origin.y, height: height)
        }
        set {
            origin.y = newValue.y
            size.height = newValue.height
        }
    }
    
    var horizontal: CGWidth {
        get {
            return CGWidth(x: origin.x, width: width)
        }
        set {
            origin.x = newValue.x
            size.width = newValue.width
        }
    }
}
