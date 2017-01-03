//
//  VerticalTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class VerticalTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let vertical = Vertical(y: 100, height: 100)
        
        XCTAssertEqual(vertical.y, 100)
        XCTAssertEqual(vertical.height, 100)
        XCTAssertEqual(vertical.maxY, 200)
    }
    
    func testZero() {
        XCTAssertEqual(Vertical.zero.y, 0)
        XCTAssertEqual(Vertical.zero.height, 0)
        XCTAssertEqual(Vertical.zero.maxY, 0)
    }
    
    func testMaxX() {
        var vertical = Vertical(y: 100, height: 100)
        XCTAssertEqual(vertical.maxY, 200)
        
        vertical.y = 200
        XCTAssertEqual(vertical.maxY, 300)
        
        vertical.height = 200
        XCTAssertEqual(vertical.maxY, 400)
    }
    
    func testOperator() {
        let vertical = Vertical(y: 100, height: 100) * 10
        
        XCTAssertEqual(vertical.y, 1000)
        XCTAssertEqual(vertical.height, 1000)
        XCTAssertEqual(vertical.maxY, 2000)
    }
}
