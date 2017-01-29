//
//  ViewBundle.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/04.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

protocol Initializable {
    init()
}

extension NSObject: Initializable {}

struct ViewBundle<T: Initializable> where T: NSObjectProtocol {
    private var nib: [String: UINib] = [:]
    private var `class`: [String: T.Type] = [:]
    
    mutating func register(ofNib nib: UINib?, for identifier: String) {
        self.nib[identifier] = nib
        self.class[identifier] = nil
    }
    
    mutating func register(ofClass cellClass: T.Type, for identifier: String) {
        self.class[identifier] = cellClass
        self.nib[identifier] = nil
    }
    
    private func nibInstantiate(with identifier: String) -> T? {
        return self.nib[identifier]?.instantiate(withOwner: nil, options: nil).first as? T
    }
    
    private func classInstantiate(with identifier: String) -> T? {
        return self.class[identifier]?.init()
    }
    
    func instantiate(with identifier: String) -> T {
        if let cell = nibInstantiate(with: identifier) ?? classInstantiate(with: identifier) {
            return cell
        } else {
            fatalError("could not dequeue a view of kind: \(T.className) with identifier \(identifier) - must register a nib or a class for the identifier")
        }
    }
}
