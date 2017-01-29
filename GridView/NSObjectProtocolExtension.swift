//
//  NSObjectProtocolExtension.swift
//  GridView
//
//  Created by Kyohei Ito on 2017/01/29.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import Foundation

extension NSObjectProtocol {
    static var className: String {
        let className = NSStringFromClass(self)
        let range = className.range(of: ".")
        return className.substring(from: range!.upperBound)
    }
}
