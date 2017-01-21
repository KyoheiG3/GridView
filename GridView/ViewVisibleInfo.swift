//
//  ViewVisibleInfo.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/11.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import Foundation

struct ViewVisibleInfo<T: View> {
    private var column: [Int] = []
    private var row: [Int: [Int]] = [:]
    private var object: [IndexPath: ViewReference<T>] = [:]
    private var selectedIndexPath: Set<IndexPath> = []
    
    mutating func replaceColumn(_ column: [Int]) {
        self.column = column
    }
    
    mutating func replaceRows(_ rows: (Int) -> [Int]) {
        for column in self.column {
            self.row[column] = rows(column)
        }
    }
    
    mutating func replaceObject(with info: ViewVisibleInfo) {
        self.object = info.object
    }
    
    mutating func replaceSelectedIndexPath(with info: ViewVisibleInfo) {
        self.selectedIndexPath = info.selectedIndexPath
    }
    
    func columns() -> [Int] {
        return column
    }
    
    func rows() -> [Int: [Int]] {
        return row
    }
    
    func rows(in column: Int) -> [Int] {
        return row[column] ?? []
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
