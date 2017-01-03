//
//  HorizontalTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class HorizontalTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let horizontal = Horizontal(x: 100, width: 100)
        
        XCTAssertEqual(horizontal.x, 100)
        XCTAssertEqual(horizontal.width, 100)
        XCTAssertEqual(horizontal.maxX, 200)
    }
    
    func testZero() {
        XCTAssertEqual(Horizontal.zero.x, 0)
        XCTAssertEqual(Horizontal.zero.width, 0)
        XCTAssertEqual(Horizontal.zero.maxX, 0)
    }
    
    func testMaxX() {
        var horizontal = Horizontal(x: 100, width: 100)
        XCTAssertEqual(horizontal.maxX, 200)
        
        horizontal.x = 200
        XCTAssertEqual(horizontal.maxX, 300)
        
        horizontal.width = 200
        XCTAssertEqual(horizontal.maxX, 400)
    }
    
    func testOperator() {
        let horizontal = Horizontal(x: 100, width: 100) * 10
        
        XCTAssertEqual(horizontal.x, 1000)
        XCTAssertEqual(horizontal.width, 1000)
        XCTAssertEqual(horizontal.maxX, 2000)
    }
}
