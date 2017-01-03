//
//  MockLocation.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit
@testable import GridView

struct MockLocation: Location {
    public var x: CGFloat
    public var y: CGFloat
    
    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}
