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
        return UINib(nibName: "MockCell", bundle: Bundle(for: self))
    }
}
