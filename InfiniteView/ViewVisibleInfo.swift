//
//  ViewVisibleInfo.swift
//  InfiniteView
//
//  Created by Kyohei Ito on 2016/11/11.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import Foundation

struct ViewVisibleInfo<T: View> {
    private var section = [Int]()
    private var row: [Int: [Int]] = [:]
    private var object: [IndexPath: ViewReference<T>] = [:]
    private var selectedIndexPath = Set<IndexPath>()
    
    mutating func replaceSection(_ section: [Int]) {
        self.section = section
    }
    
    mutating func replaceRows(_ rows: (Int) -> [Int]) {
        for section in self.section {
            self.row[section] = rows(section)
        }
    }
    
    mutating func replaceObject(with info: ViewVisibleInfo) {
        self.object = info.object
    }
    
    mutating func replaceSelectedIndexPath(with info: ViewVisibleInfo) {
        self.selectedIndexPath = info.selectedIndexPath
    }
    
    func subtractingSections(with visibleInfo: ViewVisibleInfo<T>) -> [Int] {
        return sections().subtracting(visibleInfo.sections())
    }
    
    func subtractingRows(with visibleInfo: ViewVisibleInfo<T>, in section: Int) -> [Int] {
        return rows(in: section).subtracting(visibleInfo.rows(in: section))
    }
    
    func sections() -> [Int] {
        return section
    }
    
    func rows(in section: Int) -> [Int] {
        return row[section] ?? []
    }
    
    func visibleObject() -> [IndexPath: ViewReference<T>] {
        return object
    }
    
    func isSelected(_ indexPath: IndexPath) -> Bool {
        return selectedIndexPath.contains(indexPath)
    }
    
    func object(at indexPath: IndexPath) -> T? {
        return self.object[indexPath]?.view
    }
    
    func indexPathsForSelected() -> [IndexPath] {
        return selectedIndexPath.sorted()
    }
    
    mutating func selected(at indexPath: IndexPath) -> T? {
        selectedIndexPath.insert(indexPath)
        return object[indexPath]?.view
    }
    
    mutating func deselected(at indexPath: IndexPath) -> T? {
        selectedIndexPath.remove(indexPath)
        return object[indexPath]?.view
    }
    
    mutating func append(_ object: T, at indexPath: IndexPath) {
        self.object[indexPath] = ViewReference(object)
    }
    
    mutating func removedObject(at indexPath: IndexPath) -> T? {
        let object = self.object[indexPath]
        self.object[indexPath] = nil
        return object?.view
    }
}
