//
//  ViewController.swift
//  GridViewExample
//
//  Created by Kyohei Ito on 2016/10/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit
import GridView

private let minValue: CGFloat = 70
private let maxValue: CGFloat = 100

class ViewController: UIViewController {
    @IBOutlet weak var gridView: GridView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gridView.register(TestCell.nib, forCellWithReuseIdentifier: "GridViewCell")
        gridView.backgroundColor = UIColor.red
//        gridView.isPagingEnabled = true
        gridView.contentWidth = maxValue
        gridView.dataSource = self
        gridView.delegate = self
        gridView.minimumScale = Scale(x: 0.5, y: 0.7)
        gridView.maximumScale = Scale(x: 4.5, y: 4.3)
//        gridView.isInfinitable = false
//        gridView.contentPosition = 0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func invalidate() {
//        gridView.contentWidth = gridView.contentWidth == minValue ? maxValue : minValue
//        gridView.invalidateLayout(vertically: true)
//        gridView.scaleBy(x: 0.3 + CGFloat(arc4random_uniform(10)) / 10, y: 0.6 + CGFloat(arc4random_uniform(10)) / 10)
//        gridView.reloadData()
//        gridView.invalidateLayout()
//        gridView.contentScale(0.3 + CGFloat(arc4random_uniform(10)) / 10)
        gridView.contentScale(1.1)
        
//        gridView.layoutIfNeeded()
        UIView.animate(withDuration: 1, animations: gridView.layoutIfNeeded)
    }
}

extension ViewController: GridViewDataSource, GridViewDelegate {
    func numberOfSections(in gridView: GridView) -> Int {
        return 100 + Int(arc4random_uniform(5))
    }
    
    func gridView(_ gridView: GridView, numberOfRowsInSection section: Int) -> Int {
        return 100 + Int(arc4random_uniform(5))
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20 + CGFloat(arc4random_uniform(10) * 5)
    }
    
    func gridView(_ gridView: GridView, widthForSection section: Int) -> CGFloat {
        return 20 + CGFloat(arc4random_uniform(10) * 5)
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
//        print("cellForRowAt \(indexPath)")
        let cell = gridView.dequeueReusableCell(withReuseIdentifier: "GridViewCell", for: indexPath)
        if let cell = cell as? TestCell {
            cell.configure()
        }
        
        return cell
    }
    
    func gridView(_ gridView: GridView, willDisplay cell: GridViewCell, forRowAt indexPath: IndexPath) {
//        print("willDisplay \(indexPath)")
    }
    
    func gridView(_ gridView: GridView, didEndDisplaying cell: GridViewCell, forRowAt indexPath: IndexPath) {
//        print("didEndDisplaying \(indexPath)")
    }
    
    func gridView(_ gridView: GridView, didSelectRowAt indexPath: IndexPath) {
        gridView.scrollToRow(at: indexPath, at: [.centeredVertically, .fit], animated: true)
    }
}

