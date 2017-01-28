//
//  LocationTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class LocationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOperator() {
        XCTAssertTrue(MockLocation(x: 10, y: 10) == MockLocation(x: 10, y: 10))
        XCTAssertFalse(MockLocation(x: 10, y: 10) == MockLocation(x: 20, y: 10))
        XCTAssertFalse(MockLocation(x: 10, y: 10) == MockLocation(x: 10, y: 20))
        XCTAssertFalse(MockLocation(x: 10, y: 10) == MockLocation(x: 20, y: 20))
        
        let l1 = MockLocation(x: 10, y: 10) + MockLocation(x: 10, y: 10)
        XCTAssertEqual(l1.x, 20)
        XCTAssertEqual(l1.y, 20)
        
        let l2 = MockLocation(x: 10, y: 10) - MockLocation(x: 10, y: 10)
        XCTAssertEqual(l2.x, 0)
        XCTAssertEqual(l2.y, 0)
        
        let l3 = MockLocation(x: 10, y: 10) * MockLocation(x: 10, y: 10)
        XCTAssertEqual(l3.x, 100)
        XCTAssertEqual(l3.y, 100)
        
        let l4 = MockLocation(x: 10, y: 10) / MockLocation(x: 10, y: 10)
        XCTAssertEqual(l4.x, 1)
        XCTAssertEqual(l4.y, 1)
        
        let l5 = MockLocation(x: 10, y: 10) + 10
        XCTAssertEqual(l5.x, 20)
        XCTAssertEqual(l5.y, 20)
        
        let l6 = MockLocation(x: 10, y: 10) - 10
        XCTAssertEqual(l6.x, 0)
        XCTAssertEqual(l6.y, 0)
    }
    
    func testMin() {
        XCTAssertEqual(MockLocation(x: 10, y: 10).min(), 10)
        XCTAssertEqual(MockLocation(x: 1, y: 10).min(), 1)
        XCTAssertEqual(MockLocation(x: 10, y: 1).min(), 1)
        
        XCTAssertEqual(min(MockLocation(x: 10, y: 10), MockLocation(x: 10, y: 1), MockLocation(x: 1, y: 10)), MockLocation(x: 1, y: 1))
        XCTAssertEqual(min(MockLocation(x: 10, y: 10), MockLocation(x: 10, y: 1), MockLocation(x: 10, y: 5)), MockLocation(x: 10, y: 1))
        XCTAssertEqual(min(MockLocation(x: 10, y: 10), MockLocation(x: 1, y: 10), MockLocation(x: 5, y: 10)), MockLocation(x: 1, y: 10))
        XCTAssertEqual(min(MockLocation(x: 1, y: 1), MockLocation(x: 5, y: 5), MockLocation(x: 10, y: 10)), MockLocation(x: 1, y: 1))
        XCTAssertEqual(min(MockLocation(x: 10, y: 10)), MockLocation(x: 10, y: 10))
    }
    
    func testMax() {
        XCTAssertEqual(MockLocation(x: 10, y: 10).max(), 10)
        XCTAssertEqual(MockLocation(x: 1, y: 10).max(), 10)
        XCTAssertEqual(MockLocation(x: 10, y: 1).max(), 10)
        
        XCTAssertEqual(max(MockLocation(x: 10, y: 10), MockLocation(x: 10, y: 1), MockLocation(x: 1, y: 10)), MockLocation(x: 10, y: 10))
        XCTAssertEqual(max(MockLocation(x: 1, y: 1), MockLocation(x: 10, y: 1), MockLocation(x: 5, y: 1)), MockLocation(x: 10, y: 1))
        XCTAssertEqual(max(MockLocation(x: 1, y: 1), MockLocation(x: 1, y: 10), MockLocation(x: 1, y: 5)), MockLocation(x: 1, y: 10))
        XCTAssertEqual(max(MockLocation(x: 10, y: 10), MockLocation(x: 5, y: 5), MockLocation(x: 1, y: 1)), MockLocation(x: 10, y: 10))
        XCTAssertEqual(max(MockLocation(x: 10, y: 10)), MockLocation(x: 10, y: 10))
    }
}
