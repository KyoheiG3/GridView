//
//  DateTimeGridViewCell.swift
//  GridViewExample
//
//  Created by Kyohei Ito on 2017/05/11.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import UIKit
import GridView

class DateTimeGridViewCell: GridViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    static var nib: UINib {
        return UINib(nibName: "DateTimeGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeLabel.font = .boldSystemFont(ofSize: 14)
        timeLabel.textColor = .white
        timeLabel.numberOfLines = 1
        timeLabel.textAlignment = .center
        
        borderView.backgroundColor = .white
    }
    
    func configure(_ hour: Int) {
        timeLabel.text = "\(hour)"
    }
}
