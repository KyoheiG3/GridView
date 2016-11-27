//
//  ArrayExtension.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/03.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    func union(_ elements: [Element]) -> [Element] {
        return self + elements.subtracting(self)
    }
    
    func subtracting(_ elements: [Element]) -> [Element] {
        var copy = self
        for element in elements {
            if let index = copy.index(of: element) {
                copy.remove(at: index)
            }
        }
        
        return copy
    }
    
    func intersection(_ elements: [Element]) -> [Element] {
        var copy: [Element] = []
        for element in elements {
            if index(of: element) != nil {
                copy.append(element)
            }
        }
        
        return copy
    }
}
