//
//  Countable.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/23.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

enum Threshold {
    case `in`, above, below
}

protocol Countable {
    var count: Int { get }
    
    func abs(_ value: Int) -> Int
    func threshold(with value: Int) -> Threshold
}

extension Dictionary: Countable {}

extension Countable {
    func abs(_ value: Int) -> Int {
        guard value < 0 || value >= count else {
            return value
        }
        
        return (value + count) % count
    }
    
    func threshold(with value: Int) -> Threshold {
        switch value {
        case (let s) where s < 0:
            return .below
        case (let s) where s >= count:
            return .above
        default:
            return .in
        }
    }
}
