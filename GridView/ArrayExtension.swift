//
//  ArrayExtension.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/03.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import Foundation

extension Array where Element: Hashable, Element: Comparable {
    func union(_ elements: [Element]) -> [Element] {
        return self + elements.subtracting(self)
    }
    
    func subtracting(_ elements: [Element]) -> [Element] {
        return [Element](Set(self).subtracting(elements)).sorted()
    }
    
    func intersection(_ elements: [Element]) -> [Element] {
        return [Element](Set(self).intersection(elements)).sorted()
    }
}
