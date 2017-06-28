//
//  PageViewController.swift
//  GridViewExample
//
//  Created by Kyohei Ito on 2017/05/12.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import UIKit
import GridView

class PageViewController: UIViewController {
    @IBOutlet weak var gridView: GridView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gridView.register(PageGridViewCell.nib, forCellWithReuseIdentifier: "PageGridViewCell")
        gridView.dataSource = self
        gridView.delegate = self
        gridView.isPagingEnabled = true
        gridView.isDirectionalLockEnabled = true
        gridView.minimumScale = Scale(x: 1/3, y: 1/3)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let frame = gridView.frame
        gridView.contentInset = UIEdgeInsets(top: frame.minY, left: frame.minX, bottom: view.bounds.height - frame.maxY, right: view.bounds.width - frame.maxX)
        gridView.scrollIndicatorInsets = gridView.contentInset
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.gridView.invalidateContentSize()
            self.view.layoutIfNeeded()
            self.adjustStateCells()
        })
    }
    
    func adjustStateCells() {
        gridView.visibleCells().forEach { (cell: PageGridViewCell) in
            let cellFrame = cell.convert(cell.bounds, to: view)
            let centerX = view.frame.midX - cellFrame.midX
            let centerY = view.frame.midY - cellFrame.midY
            let distanceRatio = 1 - min(1, abs(centerX / view.bounds.width) + abs(centerY / view.bounds.height))
            
            let color = 0.5 * distanceRatio
            cell.backgroundColor = UIColor(red: color, green: 0, blue: 0.5 - color, alpha: 1)
        }
    }
}

extension PageViewController: GridViewDataSource, GridViewDelegate {
    func numberOfColumns(in gridView: GridView) -> Int {
        return 30
    }
    
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int {
        return 30
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        let cell = gridView.dequeueReusableCell(withReuseIdentifier: "PageGridViewCell", for: indexPath)
        if let cell = cell as? PageGridViewCell {
            cell.label.text = "\(indexPath.column) - \(indexPath.row)"
        }
        
        return cell
    }
    
    func gridView(_ gridView: GridView, didSelectRowAt indexPath: IndexPath) {
        gridView.scrollToRow(at: indexPath, at: [.topFit, .leftFit], animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustStateCells()
    }
    
    func gridView(_ gridView: GridView, didScaleAt scale: CGFloat) {
        adjustStateCells()
    }
}
