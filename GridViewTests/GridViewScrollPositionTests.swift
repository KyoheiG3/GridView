//
//  GridViewScrollPositionTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class GridViewScrollPositionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let p1 = GridViewScrollPosition(rawValue: 1)
        XCTAssertEqual(p1.rawValue, 1)
        XCTAssertEqual(p1, .top)
        
        let p2 = GridViewScrollPosition(rawValue: 2)
        XCTAssertEqual(p2.rawValue, 2)
        XCTAssertEqual(p2, .centeredVertically)
        
        let p3 = GridViewScrollPosition(rawValue: 3)
        XCTAssertEqual(p3.rawValue, 3)
        XCTAssertEqual(p3, [.top, .centeredVertically])
        
        let p4 = GridViewScrollPosition(rawValue: 4)
        XCTAssertEqual(p4.rawValue, 4)
        XCTAssertEqual(p4, .bottom)
        
        let p5 = GridViewScrollPosition(rawValue: 5)
        XCTAssertEqual(p5.rawValue, 5)
        XCTAssertEqual(p5, [.bottom, .top])
    }
    
    func testContains() {
        let positions: [GridViewScrollPosition] = [.top, .centeredVertically, .bottom, .left, .centeredHorizontally, .right, .topFit, .bottomFit, .rightFit, .leftFit]
        
        XCTAssertTrue(GridViewScrollPosition.top.contains(positions))
        XCTAssertTrue(GridViewScrollPosition.centeredVertically.contains(positions))
        XCTAssertTrue(GridViewScrollPosition.bottom.contains(positions))
        XCTAssertTrue(GridViewScrollPosition.left.contains(positions))
        XCTAssertTrue(GridViewScrollPosition.centeredHorizontally.contains(positions))
        XCTAssertTrue(GridViewScrollPosition.right.contains(positions))
        XCTAssertTrue(GridViewScrollPosition.topFit.contains(positions))
        XCTAssertTrue(GridViewScrollPosition.bottomFit.contains(positions))
        XCTAssertTrue(GridViewScrollPosition.rightFit.contains(positions))
        XCTAssertTrue(GridViewScrollPosition.leftFit.contains(positions))
        XCTAssertFalse(GridViewScrollPosition(rawValue: 1 << 10).contains(positions))
    }
}
