//
//  ViewController.swift
//  InfiniteView
//
//  Created by Kyohei Ito on 2016/10/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

private let minValue: CGFloat = 70
private let maxValue: CGFloat = 100

class ViewController: UIViewController {
    @IBOutlet weak var infiniteView: InfiniteView!
    var height: CGFloat = minValue
    let heights: [[CGFloat]] = [[10, 20, 30, 40, 50], [20, 30, 40, 50, 10], [30, 40, 50, 10, 20], [40, 50, 10, 20, 30], [50, 10, 20, 30, 40]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        infiniteView.register(TestCell.nib, forCellWithReuseIdentifier: "InfiniteViewCell")
        infiniteView.backgroundColor = UIColor.red
//        infiniteView.isPagingEnabled = true
        infiniteView.clipsToBounds = false
        infiniteView.contentWidth = maxValue
        infiniteView.dataSource = self
        infiniteView.delegate = self
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
//        infiniteView.invalidateLayout()
//        infiniteView.contentWidth = infiniteView.contentWidth == 50 ? 100 : 50
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func invalidate() {
        height = height == minValue ? maxValue : minValue
//        infiniteView.contentWidth = oldHeight// + CGFloat(arc4random_uniform(5) * 10)
        infiniteView.contentWidth = infiniteView.contentWidth == minValue ? maxValue : minValue
        infiniteView.invalidateLayout()
        
        UIView.animate(withDuration: 1, animations: infiniteView.layoutIfNeeded)
    }
}

extension ViewController: InfiniteViewDataSource, InfiniteViewDelegate {
    func numberOfSections(in infiniteView: InfiniteView) -> Int {
        return 100
    }
    
    func infiniteView(_ infiniteView: InfiniteView, numberOfRowsInSection section: Int) -> Int {
        return 1000
    }
    
    func infiniteView(_ infiniteView: InfiniteView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let section = indexPath.section % 5
//        let row = indexPath.row % 5
        return height//CGFloat(arc4random_uniform(5) * 10)//heights[section][row]
    }
    
    func infiniteView(_ infiniteView: InfiniteView, cellForRowAt indexPath: IndexPath) -> InfiniteViewCell {
        let cell = infiniteView.dequeueReusableCell(withReuseIdentifier: "InfiniteViewCell", for: indexPath)
        if let cell = cell as? TestCell {
            cell.configure()
        }
        
        return cell
    }
    
    func infiniteView(_ infiniteView: InfiniteView, willDisplay cell: InfiniteViewCell, forRowAt indexPath: IndexPath) {
//        print("willDisplay \(indexPath)")
    }
    
    func infiniteView(_ infiniteView: InfiniteView, didEndDisplaying cell: InfiniteViewCell, forRowAt indexPath: IndexPath) {
//        print("didEndDisplaying \(indexPath)")
    }
    
    func infiniteView(_ infiniteView: InfiniteView, didSelectRowAt indexPath: IndexPath) {
    }
}

