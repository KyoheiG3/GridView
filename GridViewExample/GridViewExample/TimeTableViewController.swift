//
//  ViewController.swift
//  GridViewExample
//
//  Created by Kyohei Ito on 2016/10/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit
import GridView

extension UIColor {
    fileprivate convenience init(hex: Int, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255
        let green = CGFloat((hex & 0x00FF00) >> 8 ) / 255
        let blue = CGFloat((hex & 0x0000FF) >> 0 ) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

class TimeTableViewController: UIViewController {
    @IBOutlet weak var timeTableView: GridView!
    @IBOutlet weak var channelListView: GridView!
    @IBOutlet weak var dateTimeView: GridView!

    private let channels: [String] = ["News", "Anime", "Drama", "MTV", "Music", "Pets", "Documentary", "Soccer", "Cooking", "Gourmet", "Extreme", "Esports"]
    
    fileprivate lazy var slotList: [[Slot]] = {
        let detailText = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        let minutesOfDay = 24 * 60
        let frames = [15, 15, 20, 20, 30, 30, 40, 40, 50, 50, 60, 60, 75, 75, 90, 90]
        return self.channels.enumerated().map { index, channel in
            var slots: [Slot] = []
            var totalMinutes = 0
            while totalMinutes < minutesOfDay {
                var minutes = frames[Int(arc4random_uniform(UInt32(frames.count)))]
                let startAt = totalMinutes + minutes
                minutes -= max(startAt - minutesOfDay, 0)
                let slot = Slot(minutes: minutes, startAt: totalMinutes, title: "\(channel)'s slot", detail: detailText)
                totalMinutes = startAt
                slots.append(slot)
            }
            return slots
        }
    }()
    
    private lazy var channelListDataSource: ChannelListDataSource = .init(channels: self.channels)
    private let dateTimeDataSource = DateTimeGridViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.layoutIfNeeded()
        
        timeTableView.register(TimeTableGridViewCell.nib, forCellWithReuseIdentifier: "TimeTableGridViewCell")
        channelListView.register(ChannelListGridViewCell.nib, forCellWithReuseIdentifier: "ChannelListGridViewCell")
        dateTimeView.register(DateTimeGridViewCell.nib, forCellWithReuseIdentifier: "DateTimeGridViewCell")
        
//        timeTableView.layoutWithoutFillForCell = true
        timeTableView.superview?.clipsToBounds = true
        timeTableView.contentInset.top = channelListView.bounds.height
        timeTableView.minimumScale = Scale(x: 0.5, y: 0.5)
        timeTableView.maximumScale = Scale(x: 1.5, y: 1.5)
        timeTableView.scrollIndicatorInsets.top = timeTableView.contentInset.top
        timeTableView.scrollIndicatorInsets.left = dateTimeView.bounds.width
        timeTableView.dataSource = self
        timeTableView.delegate = self
        timeTableView.reloadData()
        
//        channelListView.layoutWithoutFillForCell = true
        channelListView.superview?.backgroundColor = .black
        channelListView.superview?.isUserInteractionEnabled = false
        channelListView.minimumScale.x = timeTableView.minimumScale.x
        channelListView.maximumScale.x = timeTableView.maximumScale.x
        channelListView.dataSource = channelListDataSource
        channelListView.delegate = channelListDataSource
        channelListView.reloadData()
        
        dateTimeView.superview?.clipsToBounds = true
        dateTimeView.superview?.backgroundColor = UIColor(hex: 0x6FB900)
        dateTimeView.superview?.isUserInteractionEnabled = false
        dateTimeView.contentInset.top = channelListView.bounds.height
        dateTimeView.minimumScale.y = timeTableView.minimumScale.y
        dateTimeView.maximumScale.y = timeTableView.maximumScale.y
        dateTimeView.isInfinitable = false
        dateTimeView.dataSource = dateTimeDataSource
        dateTimeView.delegate = dateTimeDataSource
        dateTimeView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.timeTableView.invalidateContentSize()
            self.channelListView.invalidateContentSize()
            self.view.layoutIfNeeded()
        })
    }
}

extension TimeTableViewController: GridViewDataSource, GridViewDelegate {
    func numberOfColumns(in gridView: GridView) -> Int {
        return slotList.count
    }
    
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int {
        return slotList[column].count
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(slotList[indexPath.column][indexPath.row].minutes * 2)
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        let cell = gridView.dequeueReusableCell(withReuseIdentifier: "TimeTableGridViewCell", for: indexPath)
        if let cell = cell as? TimeTableGridViewCell {
            cell.configure(slotList[indexPath.column][indexPath.row])
        }
        
        return cell
    }
    
    func gridView(_ gridView: GridView, didScaleAt scale: CGFloat) {
        channelListView.contentScale(scale)
        dateTimeView.contentScale(scale)
    }
    
    func gridView(_ gridView: GridView, didSelectRowAt indexPath: IndexPath) {
        gridView.deselectRow(at: indexPath)
        gridView.scrollToRow(at: indexPath, at: [.topFit, .centeredHorizontally], animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        channelListView.contentOffset.x = scrollView.contentOffset.x
        dateTimeView.contentOffset.y = scrollView.contentOffset.y
    }
}

final class DateTimeGridViewDataSource: NSObject, GridViewDataSource, GridViewDelegate {
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int {
        return 24
    }
    
    func gridView(_ gridView: GridView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 * 2
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        let cell = gridView.dequeueReusableCell(withReuseIdentifier: "DateTimeGridViewCell", for: indexPath)
        if let cell = cell as? DateTimeGridViewCell {
            cell.configure(indexPath.row)
        }
        
        return cell
    }
}

final class ChannelListDataSource: NSObject, GridViewDataSource, GridViewDelegate {
    let channels: [String]
    
    init(channels: [String]) {
        self.channels = channels
    }
    
    func numberOfColumns(in gridView: GridView) -> Int {
        return channels.count
    }
    
    func gridView(_ gridView: GridView, numberOfRowsInColumn column: Int) -> Int {
        return 1
    }
    
    func gridView(_ gridView: GridView, cellForRowAt indexPath: IndexPath) -> GridViewCell {
        let cell = gridView.dequeueReusableCell(withReuseIdentifier: "ChannelListGridViewCell", for: indexPath)
        if let cell = cell as? ChannelListGridViewCell {
            cell.configure(channels[indexPath.column])
        }
        
        return cell
    }
}
