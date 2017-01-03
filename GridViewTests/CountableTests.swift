//
//  CountableTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class CountableTests: XCTestCase {
    let array = [0,1,2,3,4,5,6,7,8,9]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRepeat() {
        XCTAssertEqual(array.repeat(5), 5)
        XCTAssertEqual(array.repeat(13), 3)
        XCTAssertEqual(array.repeat(20), 0)
        XCTAssertEqual(array.repeat(35), 5)
        XCTAssertEqual(array.repeat(-3), 7)
        XCTAssertEqual(array.repeat(-5), 5)
        XCTAssertEqual(array.repeat(-13), 7)
        XCTAssertEqual(array.repeat(-20), 0)
        XCTAssertEqual(array.repeat(-35), 5)
    }
    
    func testThreshold() {
        XCTAssertEqual(array.threshold(with: 5), .in)
        XCTAssertEqual(array.threshold(with: 13), .above)
        XCTAssertEqual(array.threshold(with: 20), .above)
        XCTAssertEqual(array.threshold(with: 35), .above)
        XCTAssertEqual(array.threshold(with: -5), .below)
        XCTAssertEqual(array.threshold(with: -13), .below)
        XCTAssertEqual(array.threshold(with: -20), .below)
        XCTAssertEqual(array.threshold(with: -35), .below)
    }
}
