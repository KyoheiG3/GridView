//
//  ViewVisibleInfo.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/11.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import Foundation

struct ViewVisibleInfo<T: View> {
    private var section: [Int] = []
    private var row: [Int: [Int]] = [:]
    private var object: [IndexPath: ViewReference<T>] = [:]
    private var selectedIndexPath: Set<IndexPath> = []
    
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
    
    func sections() -> [Int] {
        return section
    }
    
    func rows() -> [Int: [Int]] {
        return row
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
        return object[indexPath]?.view
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
    
    mutating func append(_ newObject: T, at indexPath: IndexPath) {
        object[indexPath] = ViewReference(newObject)
    }
    
    mutating func removedObject(at indexPath: IndexPath) -> T? {
        let oldObject = object[indexPath]
        object[indexPath] = nil
        return oldObject?.view
    }
}
