//
//  ViewReference.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/03.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

protocol View: class {
    func removeFromSuperview()
}

extension UIView: View {}

class ViewReference<T: View> {

    deinit {
        view?.removeFromSuperview()
    }
    
    private(set) weak var view: T?
    
    init(_ view: T) {
        self.view = view
    }
}
