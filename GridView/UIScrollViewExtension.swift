//
//  UIScrollViewExtension.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/10.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

extension UIScrollView {
    var validityContentOffset: CGPoint {
        return CGPoint(x: contentOffset.x - frame.minX, y: contentOffset.y - frame.minY)
    }
}
