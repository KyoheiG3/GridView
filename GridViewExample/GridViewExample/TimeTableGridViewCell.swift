//
//  TimeTableGridViewCell.swift
//  GridViewExample
//
//  Created by Kyohei Ito on 2017/05/11.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import GridView
#if os(tvOS)
    import FocusZPositionMutating
    extension TimeTableGridViewCell: FocusZPositionMutating { }
#endif

class TimeTableGridViewCell: GridViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var shadowView: UIView! {
        didSet {
        }
    }

    static var nib: UINib {
        return UINib(nibName: "TimeTableGridViewCell", bundle: Bundle(for: self))
    }

    #if os(tvOS)
    override var canBecomeFocused: Bool {
        return false
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

        #if os(iOS)
            clipsToBounds = true
        #else
            clipsToBounds = false
        #endif

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

#if os(tvOS)
class FocusableView: UIView {
    override var canBecomeFocused: Bool {
        return true
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.backgroundColor = UIColor.white.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 20)
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            self.layer.borderColor = UIColor.red.cgColor
            self.layer.borderWidth = 2 / UIScreen.main.scale
        } else {
            self.layer.borderColor = UIColor.gray.cgColor
            self.layer.borderWidth = 1 / UIScreen.main.scale
        }
        coordinator.addCoordinatedAnimations({
            if context.nextFocusedView == self {
                self.transform = .init(scaleX: 1.1, y: 1.1)
            } else {
                self.transform = .identity
            }
        }, completion: nil)
        super.didUpdateFocus(in: context, with: coordinator)
    }
}
#endif
