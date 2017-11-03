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
    @IBOutlet weak var shadowView: UIView! {
        didSet {
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowRadius = 20
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 20)
            shadowView.alpha = 0
        }
    }

    static var nib: UINib {
        return UINib(nibName: "TimeTableGridViewCell", bundle: Bundle(for: self))
    }

    #if os(tvOS)
    override var canBecomeFocused: Bool {
        return true
    }

    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        if context.nextFocusedView == self {
            self.layer.zPosition = 0.0
        } else {
            self.layer.zPosition = -0.1
        }
        return super.shouldUpdateFocus(in: context)
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            if context.nextFocusedView == self {
                self.shadowView.alpha = 1
                self.layer.zPosition = 0.0
                self.layer.borderColor = UIColor.red.cgColor
                self.layer.borderWidth = 2 / UIScreen.main.scale
                self.transform = .init(scaleX: 1.1, y: 1.1)
            } else {
                self.shadowView.alpha = 0
                self.layer.zPosition = -0.1
                self.layer.borderColor = UIColor.gray.cgColor
                self.layer.borderWidth = 1 / UIScreen.main.scale
                self.transform = .identity
            }
        }, completion: nil)
        super.didUpdateFocus(in: context, with: coordinator)
    }
    #endif
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        timeLabel.text = nil
        titleLabel.text = nil
        detailLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = true
        #if os(tvOS)
        layer.zPosition = -0.1
        #endif
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
