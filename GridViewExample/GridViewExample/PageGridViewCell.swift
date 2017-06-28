//
//  PageGridViewCell.swift
//  GridViewExample
//
//  Created by Kyohei Ito on 2017/05/12.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import UIKit
import GridView

class PageGridViewCell: GridViewCell {
    @IBOutlet weak var label: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: "PageGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 2
        
        label.font = .boldSystemFont(ofSize: 36)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
    }
}
