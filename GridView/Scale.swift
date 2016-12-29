//
//  Scale.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/28.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

public struct Scale: Location {
    public static let zero = Scale(x: 0, y: 0)
    
    public var x: CGFloat
    public var y: CGFloat
    
    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

public extension Scale {
    static let `default` = Scale(x: 1, y: 1)
}
