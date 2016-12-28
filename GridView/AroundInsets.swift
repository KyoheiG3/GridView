//
//  AroundInsets.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/25.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

struct AroundInsets {
    struct Inset {
        static let zero = Inset(width: 0)
        
        let width: CGFloat
        
        init(width: CGFloat) {
            self.width = width
        }
    }
    
    static let zero = AroundInsets(parentSize: .zero, frame: .zero)
    var left: Inset
    var right: Inset
    
    init(parentSize: CGSize, frame: CGRect) {
        func around(_ x: CGFloat) -> CGFloat {
            return ceil(x / frame.width) * frame.width
        }
        
        if frame.width > 0 {
            left = Inset(width: around(frame.minX))
            right = Inset(width: around(parentSize.width - frame.maxX))
        } else {
            left = .zero
            right = .zero
        }
    }
}
