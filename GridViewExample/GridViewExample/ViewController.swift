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
    var height: CGFloat = minValue
    let heights: [[CGFloat]] = [[10, 20, 30, 40, 50], [20, 30, 40, 50, 10], [30, 40, 50, 10, 20], [40, 50, 10, 20, 30], [50, 10, 20, 30, 40]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gridView.register(TestCell.nib, forCellWithReuseIdentifier: "GridViewCell")
        gridView.backgroundColor = UIColor.red
//        gridView.isPagingEnabled = true
        gridView.clipsToBounds = false
        gridView.contentWidth = maxValue
        gridView.dataSource = self
        gridView.delegate = self
        gridView.infinite = true
//        gridView.contentPosition = 0
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//        gridView.contentWidth = size.width - 200
//        gridView.invalidateLayout()
//        gridView.contentWidth = gridView.contentWidth == minValue ? maxValue : minValue
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func invalidate() {
//        height = height == minValue ? maxValue : minValue
//        gridView.contentWidth = gridView.contentWidth == minValue ? maxValue : minValue
//        gridView.invalidateLayout()
//        UIView.animate(withDuration: 1, animations: gridView.layoutIfNeeded)
        gridView.reloadData()
    }
}

extension ViewController: GridViewDataSource, GridViewDelegate {
    func numberOfSections(in gridView: GridView) -> Int {
        return 10 + Int(arc4random_uniform(5))
    }
    
    func gridView(_ gridView: GridView, numberOfRowsInSection section: Int) -> Int {
        return 10 + Int(arc4random_uniform(5))
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let section = indexPath.section % 5
//        let row = indexPath.row % 5
        return height//CGFloat(arc4random_uniform(5) * 10)//heights[section][row]
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
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
    }
}

