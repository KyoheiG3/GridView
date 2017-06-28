//
//  TimeTableGridViewCell.swift
//  GridViewExample
//
//  Created by Kyohei Ito on 2017/05/11.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import GridView

class TimeTableGridViewCell: GridViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: "TimeTableGridViewCell", bundle: Bundle(for: self))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        timeLabel.text = nil
        titleLabel.text = nil
        detailLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = true
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1 / UIScreen.main.scale
        
        timeLabel.font = .boldSystemFont(ofSize: 10)
        timeLabel.textAlignment = .center
        
        titleLabel.font = .boldSystemFont(ofSize: 10)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 4
        titleLabel.textAlignment = .left
        
        detailLabel.font = .systemFont(ofSize: 10)
        detailLabel.textColor = UIColor.darkGray
        detailLabel.textAlignment = .left
    }
    
    func configure(_ slot: Slot) {
        timeLabel.text = String(format: "%02d", slot.startAt % 60)
        titleLabel.text = slot.title
        detailLabel.text = slot.detail
    }
}
