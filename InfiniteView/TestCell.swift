//
//  TestCell.swift
//  InfiniteView
//
//  Created by Kyohei Ito on 2016/11/02.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

class TestLabel: UILabel {
}

class TestCell: InfiniteViewCell {
    @IBOutlet weak var label: TestLabel!
    
    static var nib: UINib {
        return UINib(nibName: "TestCell", bundle: Bundle(for: self))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    func configure() {
        label.text = "\(indexPath.section)-\(indexPath.row)"
    }
}
