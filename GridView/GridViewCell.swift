//
//  GridViewCell.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/10/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

open class GridViewCell: UIView, Reusable {
    open internal(set) var indexPath = IndexPath(row: 0, column: 0)
    open var isSelected: Bool = false {
        didSet {
            setSelected(isSelected)
        }
    }
    
    open var isHighlighted: Bool = false {
        didSet {
            setHighlighted(isHighlighted)
        }
    }
    
    open func prepareForReuse() {
    }
    
    open func setSelected(_ selected: Bool) {
    }
    
    open func setHighlighted(_ highlighted: Bool) {
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        autoresizingMask = .init(rawValue: 0)
    }
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .init(rawValue: 0)
    }
}
