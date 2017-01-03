//
//  CGFloatExtension.swift
//  GridView
//
//  Created by Kyohei Ito on 2017/01/02.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    fileprivate static var scale = UIScreen.main.scale
    var integral: CGFloat {
        return CoreGraphics.round(self * CGFloat.scale) / CGFloat.scale
    }
    
    func rounded(p: CGFloat) -> CGFloat {
        let scale = pow(10, p)
        return CoreGraphics.round(self * scale) / scale
    }
    
    func floored(p: CGFloat) -> CGFloat {
        let scale = pow(10, p)
        return CoreGraphics.floor(self * scale) / scale
    }
}

#if DEBUG
extension CGFloat {
    static var debugScale: CGFloat {
        get { return scale }
        set { scale = newValue }
    }
}
#endif
