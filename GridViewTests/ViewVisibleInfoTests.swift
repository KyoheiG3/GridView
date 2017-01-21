//
//  ViewVisibleInfoTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class ViewVisibleInfoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testcolumns() {
        var info = ViewVisibleInfo<UIView>()
        
        info.replaceColumn([0,1,2])
        XCTAssertEqual(info.columns(), [0,1,2])
        
        info.replaceColumn([3,4,5])
        XCTAssertEqual(info.columns(), [3,4,5])
    }
    
    func testRows() {
        var info = ViewVisibleInfo<UIView>()
        
        info.replaceColumn([0,1,2])
        info.replaceRows { column -> [Int] in
            [0,1,2]
        }
        XCTAssertEqual(info.columns(), [0,1,2])
        XCTAssertEqual(info.rows()[0]!, [0,1,2])
        XCTAssertEqual(info.rows()[1]!, [0,1,2])
        XCTAssertEqual(info.rows()[2]!, [0,1,2])
        XCTAssertEqual(info.rows(in: 0), [0,1,2])
        XCTAssertEqual(info.rows(in: 1), [0,1,2])
        XCTAssertEqual(info.rows(in: 2), [0,1,2])
        XCTAssertEqual(info.rows(in: 3), [])
        
        info.replaceColumn([3,4,5])
        info.replaceRows { column -> [Int] in
            [3,4,5]
        }
        XCTAssertEqual(info.columns(), [3,4,5])
        XCTAssertEqual(info.rows()[3]!, [3,4,5])
        XCTAssertEqual(info.rows()[4]!, [3,4,5])
        XCTAssertEqual(info.rows()[5]!, [3,4,5])
        XCTAssertEqual(info.rows(in: 3), [3,4,5])
        XCTAssertEqual(info.rows(in: 4), [3,4,5])
        XCTAssertEqual(info.rows(in: 5), [3,4,5])
        XCTAssertEqual(info.rows(in: 6), [])
    }
    
    func testObjects() {
        let view1 = UIView(), view2 = UIView(), view3 = UIView()
        let path1 = IndexPath(row: 1, column: 0), path2 = IndexPath(row: 2, column: 0), path3 = IndexPath(row: 3, column: 0)
        
        var info1 = ViewVisibleInfo<UIView>()
        info1.append(view1, at: path1)
        info1.append(view2, at: path2)
        info1.append(view3, at: path3)
        
        XCTAssertEqual(info1.visibleObject()[path1]?.view, view1)
        XCTAssertEqual(info1.visibleObject()[path2]?.view, view2)
        XCTAssertEqual(info1.visibleObject()[path3]?.view, view3)
        XCTAssertEqual(info1.object(at: path1), view1)
        XCTAssertEqual(info1.object(at: path2), view2)
        XCTAssertEqual(info1.object(at: path3), view3)
        
        let view4 = UIView(), view5 = UIView(), view6 = UIView()
        let path4 = IndexPath(row: 4, column: 0), path5 = IndexPath(row: 5, column: 0), path6 = IndexPath(row: 6, column: 0)
        var info2 = ViewVisibleInfo<UIView>()
        info2.append(view4, at: path4)
        info2.append(view5, at: path5)
        info2.append(view6, at: path6)
        
        XCTAssertEqual(info2.visibleObject()[path4]?.view, view4)
        XCTAssertEqual(info2.visibleObject()[path5]?.view, view5)
        XCTAssertEqual(info2.visibleObject()[path6]?.view, view6)
        XCTAssertEqual(info2.object(at: path4), view4)
        XCTAssertEqual(info2.object(at: path5), view5)
        XCTAssertEqual(info2.object(at: path6), view6)
        
        info1.replaceObject(with: info2)
        XCTAssertNil(info1.visibleObject()[path1]?.view)
        XCTAssertNil(info1.visibleObject()[path2]?.view)
        XCTAssertNil(info1.visibleObject()[path3]?.view)
        XCTAssertNil(info1.object(at: path1))
        XCTAssertNil(info1.object(at: path2))
        XCTAssertNil(info1.object(at: path3))
        
        XCTAssertNotNil(info1.visibleObject()[path4]?.view)
        XCTAssertNotNil(info1.visibleObject()[path5]?.view)
        XCTAssertNotNil(info1.visibleObject()[path6]?.view)
        XCTAssertNotNil(info1.object(at: path4))
        XCTAssertNotNil(info1.object(at: path5))
        XCTAssertNotNil(info1.object(at: path6))
        
        XCTAssertNil(info1.removedObject(at: path1))
        XCTAssertNil(info1.removedObject(at: path2))
        XCTAssertNil(info1.removedObject(at: path3))
        XCTAssertNotNil(info1.removedObject(at: path4))
        XCTAssertNotNil(info1.removedObject(at: path5))
        XCTAssertNotNil(info1.removedObject(at: path6))
        
        XCTAssertNil(info1.object(at: path4))
        XCTAssertNil(info1.object(at: path5))
        XCTAssertNil(info1.object(at: path6))
    }
    
    func testSelected() {
        let view1 = UIView()
        let path1 = IndexPath(row: 1, column: 0), path2 = IndexPath(row: 2, column: 0), path3 = IndexPath(row: 3, column: 0)
        
        var info1 = ViewVisibleInfo<UIView>()
        info1.append(view1, at: path1)
        
        XCTAssertNotNil(info1.selected(at: path1))
        XCTAssertNil(info1.selected(at: path2))
        
        XCTAssertTrue(info1.isSelected(path1))
        XCTAssertTrue(info1.isSelected(path2))
        XCTAssertFalse(info1.isSelected(path3))
        
        XCTAssertEqual(info1.indexPathsForSelected(), [path1,path2])
        XCTAssertNil(info1.selected(at: path3))
        XCTAssertNotNil(info1.deselected(at: path1))
        XCTAssertEqual(info1.indexPathsForSelected(), [path2,path3])
        XCTAssertNil(info1.deselected(at: path2))
        XCTAssertEqual(info1.indexPathsForSelected(), [path3])
        
        let view4 = UIView(), view5 = UIView(), view6 = UIView()
        let path4 = IndexPath(row: 4, column: 0), path5 = IndexPath(row: 5, column: 0), path6 = IndexPath(row: 6, column: 0)
        var info2 = ViewVisibleInfo<UIView>()
        info2.append(view4, at: path4)
        info2.append(view5, at: path5)
        info2.append(view6, at: path6)
        XCTAssertNotNil(info2.selected(at: path4))
        XCTAssertNotNil(info2.selected(at: path5))
        XCTAssertNotNil(info2.selected(at: path6))
        
        XCTAssertEqual(info2.indexPathsForSelected(), [path4,path5,path6])
        info2.replaceSelectedIndexPath(with: info1)
        XCTAssertEqual(info1.indexPathsForSelected(), [path3])
    }
    
}
