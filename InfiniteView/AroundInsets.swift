//
//  AroundInsets.swift
//  InfiniteView
//
//  Created by Kyohei Ito on 2016/11/25.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

struct AroundInsets {
    struct Inset {
        static let zero = Inset(scale: 0, width: 0)
        
        let scale: CGFloat
        let width: CGFloat
        
        init(scale: CGFloat, width: CGFloat) {
            self.scale = scale
            self.width = width
        }
    }
    
    static let zero = AroundInsets(parentSize: .zero, frame: .zero)
    var left: Inset
    var right: Inset
    
    init(parentSize: CGSize, frame: CGRect) {
        if frame.width > 0 {
            let leftScale = ceil(frame.minX / frame.width)
            let rightScale = ceil((parentSize.width - frame.maxX) / frame.width)
            
            left = Inset(scale: leftScale, width: frame.width * leftScale)
            right = Inset(scale: rightScale, width: frame.width * rightScale)
        } else {
            left = .zero
            right = .zero
        }
    }
}
