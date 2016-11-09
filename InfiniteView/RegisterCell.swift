//
//  RegisterCell.swift
//  InfiniteView
//
//  Created by Kyohei Ito on 2016/11/04.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

struct RegisterCell {
    private var nib: [String: UINib] = [:]
    private var `class`: [String: InfiniteViewCell.Type] = [:]
    
    mutating func register(of nib: UINib?, for identifier: String) {
        self.nib[identifier] = nib
    }
    
    mutating func register<T: InfiniteViewCell>(of cellClass: T.Type, for identifier: String) {
        self.class[identifier] = cellClass
    }
    
    private func nibInstantiate(with identifier: String) -> InfiniteViewCell? {
        return self.nib[identifier]?.instantiate(withOwner: nil, options: nil).first as? InfiniteViewCell
    }
    
    private func classInstantiate(with identifier: String) -> InfiniteViewCell? {
        return self.class[identifier]?.init()
    }
    
    func instantiate(with identifier: String) -> InfiniteViewCell {
        if let cell = nibInstantiate(with: identifier) ?? classInstantiate(with: identifier) {
            return cell
        } else {
            fatalError("could not dequeue a view of kind: InfiniteViewCell with identifier \(identifier) - must register a nib or a class for the identifier")
        }
    }
}
