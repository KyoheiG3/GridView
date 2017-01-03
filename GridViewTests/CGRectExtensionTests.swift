//
//  CGRectExtensionTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class CGRectExtensionTests: XCTestCase {
    let horizontal = Horizontal(x: 100, width: 100)
    let vertical = Vertical(y: 100, height: 100)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHorizontalInit() {
        let rect = CGRect(horizontal: horizontal)
        
        XCTAssertEqual(rect.origin.x, 100)
        XCTAssertEqual(rect.origin.y, 0)
        XCTAssertEqual(rect.size.width, 100)
        XCTAssertEqual(rect.size.height, 0)
    }
    
    func testVerticalInit() {
        let rect = CGRect(vertical: vertical)
        
        XCTAssertEqual(rect.origin.x, 0)
        XCTAssertEqual(rect.origin.y, 100)
        XCTAssertEqual(rect.size.width, 0)
        XCTAssertEqual(rect.size.height, 100)
    }
    
    func testInit() {
        let rect = CGRect(horizontal: horizontal, vertical: vertical)
        
        XCTAssertEqual(rect.origin.x, 100)
        XCTAssertEqual(rect.origin.y, 100)
        XCTAssertEqual(rect.size.width, 100)
        XCTAssertEqual(rect.size.height, 100)
    }
    
    func testVerticalProperty() {
        var rect = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        XCTAssertEqual(rect.vertical.y, 100)
        XCTAssertEqual(rect.vertical.height, 100)
        XCTAssertEqual(rect.vertical.maxY, 200)
        
        rect.vertical = Vertical(y: 200, height: 200)
        
        XCTAssertEqual(rect.vertical.y, 200)
        XCTAssertEqual(rect.vertical.height, 200)
        XCTAssertEqual(rect.vertical.maxY, 400)
    }
    
    func testHorizontalProperty() {
        var rect = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        XCTAssertEqual(rect.horizontal.x, 100)
        XCTAssertEqual(rect.horizontal.width, 100)
        XCTAssertEqual(rect.horizontal.maxX, 200)
        
        rect.horizontal = Horizontal(x: 200, width: 200)
        
        XCTAssertEqual(rect.horizontal.x, 200)
        XCTAssertEqual(rect.horizontal.width, 200)
        XCTAssertEqual(rect.horizontal.maxX, 400)
    }
    
}
