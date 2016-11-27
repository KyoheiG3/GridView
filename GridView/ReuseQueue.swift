//
//  ReuseQueue.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/03.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

protocol Reusable {
    var canReuse: Bool { get }
}

struct ReuseQueue<E: Reusable> {
    private var queue: [String: [E]] = [:]
    
    func dequeue(with identifier: String) -> E? {
        guard let elements = queue[identifier] else { return nil }
        
        for element in elements where element.canReuse {
            return element
        }
        return nil
    }
    
    mutating func append(_ element: E, for identifier: String) {
        if queue[identifier] == nil {
            queue[identifier] = []
        }
        
        queue[identifier]?.append(element)
    }
}
