//
//  ChannelListGridViewCell.swift
//  GridViewExample
//
//  Created by Kyohei Ito on 2017/05/11.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import GridView

class ChannelListGridViewCell: GridViewCell {
    @IBOutlet weak var channelLabel: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: "ChannelListGridViewCell", bundle: Bundle(for: self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        channelLabel.font = .boldSystemFont(ofSize: 16)
        channelLabel.textColor = .lightGray
        channelLabel.textAlignment = .center
    }
    
    func configure(_ channelName: String) {
        channelLabel.text = channelName
    }
}
