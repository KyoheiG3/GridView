//
//  CGHeight.swift
//  InfiniteView
//
//  Created by Kyohei Ito on 2016/11/26.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

struct CGHeight {
    static let zero = CGHeight(y: 0, height: 0)
    
    var y: CGFloat
    var height: CGFloat
    
    var maxY: CGFloat {
        return y + height
    }
}

extension CGRect {
    init(height: CGHeight) {
        self.init(x: 0, y: height.y, width: 0, height: height.height)
    }
}
