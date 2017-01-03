//
//  ScaleTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class ScaleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let scale = Scale(x: 100, y: 100)
        
        XCTAssertEqual(scale.x, 100)
        XCTAssertEqual(scale.y, 100)
    }
    
    func testZero() {
        XCTAssertEqual(Scale.zero.x, 0)
        XCTAssertEqual(Scale.zero.y, 0)
    }
    
    func testDefault() {
        XCTAssertEqual(Scale.default.x, 1)
        XCTAssertEqual(Scale.default.y, 1)
    }
}
