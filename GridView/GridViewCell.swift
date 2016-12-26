//
//  GridViewCell.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/10/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

open class GridViewCell: UIView, Reusable {
    open internal(set) var indexPath = IndexPath(row: 0, section: 0)
    open var isSelected: Bool = false
    
    open func prepareForReuse() {
    }
    
    open func setSelected(_ selected: Bool) {
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
