//
//  IndexPathTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2017/01/21.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class IndexPathTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        XCTAssertEqual(IndexPath(row: 0, column: 0), IndexPath(row: 0, section: 0))
        XCTAssertEqual(IndexPath(row: 2, column: 2), IndexPath(row: 2, section: 2))
        XCTAssertEqual(IndexPath(row: 5, column: 5), IndexPath(row: 5, section: 5))
        XCTAssertEqual(IndexPath(row: 7, column: 7), IndexPath(row: 7, section: 7))
        XCTAssertEqual(IndexPath(row: 10, column: 10), IndexPath(row: 10, section: 10))
    }
    
    func testColumn() {
        var indexPath = IndexPath(row: 0, section: 0)
        
        XCTAssertEqual(indexPath.section, 0)
        XCTAssertEqual(indexPath.column, 0)
        
        indexPath.section = 2
        XCTAssertEqual(indexPath.section, 2)
        XCTAssertEqual(indexPath.column, 2)
        
        indexPath.column = 5
        XCTAssertEqual(indexPath.section, 5)
        XCTAssertEqual(indexPath.column, 5)
        
    }
}
