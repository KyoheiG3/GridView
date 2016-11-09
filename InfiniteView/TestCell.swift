//
//  TestCell.swift
//  InfiniteView
//
//  Created by Kyohei Ito on 2016/11/02.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

class TestCell: InfiniteViewCell {
    let benchmark = Benchmark()
    @IBOutlet weak var label: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: "TestCell", bundle: Bundle(for: self))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        benchmark.finish()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    func configure() {
//        benchmark.start()
        label.text = "\(indexPath.section)-\(indexPath.row)"
    }
}
