//
//  MockCell.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit
@testable import GridView

class MockCell: GridViewCell {
    static var nib: UINib {
        #if os(iOS)
            let nibName = "MockCell"
        #else
            let nibName = "MockCell_tvOS"
        #endif
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
}
