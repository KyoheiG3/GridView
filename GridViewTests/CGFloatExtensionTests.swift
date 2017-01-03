//
//  CGFloatExtensionTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2017/01/02.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class CGFloatExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIntegral() {
        CGFloat.debugScale = 2
        XCTAssertEqual(CGFloat.debugScale, 2)
        XCTAssertEqual(CGFloat(10.0).integral, 10.0)
        XCTAssertEqual(CGFloat(10.1).integral, 10.0)
        XCTAssertEqual(CGFloat(10.2).integral, 10.0)
        XCTAssertEqual(CGFloat(10.3).integral, 10.5)
        XCTAssertEqual(CGFloat(10.4).integral, 10.5)
        XCTAssertEqual(CGFloat(10.5).integral, 10.5)
        XCTAssertEqual(CGFloat(10.6).integral, 10.5)
        XCTAssertEqual(CGFloat(10.7).integral, 10.5)
        XCTAssertEqual(CGFloat(10.8).integral, 11)
        XCTAssertEqual(CGFloat(10.9).integral, 11)
        XCTAssertEqual(CGFloat(-10.0).integral, -10.0)
        XCTAssertEqual(CGFloat(-10.1).integral, -10.0)
        XCTAssertEqual(CGFloat(-10.2).integral, -10.0)
        XCTAssertEqual(CGFloat(-10.3).integral, -10.5)
        XCTAssertEqual(CGFloat(-10.4).integral, -10.5)
        XCTAssertEqual(CGFloat(-10.5).integral, -10.5)
        XCTAssertEqual(CGFloat(-10.6).integral, -10.5)
        XCTAssertEqual(CGFloat(-10.7).integral, -10.5)
        XCTAssertEqual(CGFloat(-10.8).integral, -11)
        XCTAssertEqual(CGFloat(-10.9).integral, -11)
        
        CGFloat.debugScale = 3
        XCTAssertEqual(CGFloat.debugScale, 3)
        XCTAssertEqual(CGFloat(10.0).integral.rounded(p: 5), 10.0)
        XCTAssertEqual(CGFloat(10.1).integral.rounded(p: 5), 10.0)
        XCTAssertEqual(CGFloat(10.2).integral.rounded(p: 5), 10.33333)
        XCTAssertEqual(CGFloat(10.3).integral.rounded(p: 5), 10.33333)
        XCTAssertEqual(CGFloat(10.4).integral.rounded(p: 5), 10.33333)
        XCTAssertEqual(CGFloat(10.5).integral.rounded(p: 5), 10.66667)
        XCTAssertEqual(CGFloat(10.6).integral.rounded(p: 5), 10.66667)
        XCTAssertEqual(CGFloat(10.7).integral.rounded(p: 5), 10.66667)
        XCTAssertEqual(CGFloat(10.8).integral.rounded(p: 5), 10.66667)
        XCTAssertEqual(CGFloat(10.9).integral.rounded(p: 5), 11)
        XCTAssertEqual(CGFloat(-10.0).integral.rounded(p: 5), -10.0)
        XCTAssertEqual(CGFloat(-10.1).integral.rounded(p: 5), -10.0)
        XCTAssertEqual(CGFloat(-10.2).integral.rounded(p: 5), -10.33333)
        XCTAssertEqual(CGFloat(-10.3).integral.rounded(p: 5), -10.33333)
        XCTAssertEqual(CGFloat(-10.4).integral.rounded(p: 5), -10.33333)
        XCTAssertEqual(CGFloat(-10.5).integral.rounded(p: 5), -10.66667)
        XCTAssertEqual(CGFloat(-10.6).integral.rounded(p: 5), -10.66667)
        XCTAssertEqual(CGFloat(-10.7).integral.rounded(p: 5), -10.66667)
        XCTAssertEqual(CGFloat(-10.8).integral.rounded(p: 5), -10.66667)
        XCTAssertEqual(CGFloat(-10.9).integral.rounded(p: 5), -11)
    }
    
    func testRounded() {
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 0), 10)
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 1), 10)
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 2), 10.01)
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 3), 10.012)
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 4), 10.0123)
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 5), 10.01235)
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 6), 10.012346)
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 7), 10.0123457)
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 8), 10.01234568)
        XCTAssertEqual(CGFloat(10.0123456789).rounded(p: 9), 10.012345679)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 0), -10)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 1), -10)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 2), -10.01)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 3), -10.012)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 4), -10.0123)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 5), -10.01235)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 6), -10.012346)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 7), -10.0123457)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 8), -10.01234568)
        XCTAssertEqual(CGFloat(-10.0123456789).rounded(p: 9), -10.012345679)
    }
    
    func testFloored() {
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 0), 10)
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 1), 10)
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 2), 10.01)
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 3), 10.012)
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 4), 10.0123)
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 5), 10.01234)
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 6), 10.012345)
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 7), 10.0123456)
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 8), 10.01234567)
        XCTAssertEqual(CGFloat(10.0123456789).floored(p: 9), 10.012345678)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 0), -11)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 1), -10.1)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 2), -10.02)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 3), -10.013)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 4), -10.0124)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 5), -10.01235)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 6), -10.012346)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 7), -10.0123457)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 8), -10.01234568)
        XCTAssertEqual(CGFloat(-10.0123456789).floored(p: 9), -10.012345679)
    }
}
