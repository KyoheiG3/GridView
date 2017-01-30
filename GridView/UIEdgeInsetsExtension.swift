//
//  UIEdgeInsetsExtension.swift
//  GridView
//
//  Created by Kyohei Ito on 2017/01/28.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

extension UIEdgeInsets {
    static func +(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
    }
    
    static func -(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: lhs.top - rhs.top, left: lhs.left - rhs.left, bottom: lhs.bottom - rhs.bottom, right: lhs.right - rhs.right)
    }
    
    var horizontal: CGFloat {
        return left + right
    }
    
    var vertical: CGFloat {
        return top + bottom
    }
}
