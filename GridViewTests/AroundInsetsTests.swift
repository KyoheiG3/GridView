//
//  AroundInsetsTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class AroundInsetsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let parentSize = CGSize(width: 300, height: 300)
        let inset1 = AroundInsets(parentSize: parentSize, frame: CGRect(origin: CGPoint(x: 135, y: 135), size: CGSize(width: 30, height: 30)))
        
        XCTAssertEqual(inset1.left.width.truncatingRemainder(dividingBy: 30), 0)
        XCTAssertEqual(inset1.right.width.truncatingRemainder(dividingBy: 30), 0)
        XCTAssertEqual(inset1.left.width / 30, 5)
        XCTAssertEqual(inset1.right.width / 30, 5)
        
        let inset2 = AroundInsets(parentSize: parentSize, frame: CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: 100, height: 100)))
        
        XCTAssertEqual(inset2.left.width.truncatingRemainder(dividingBy: 100), 0)
        XCTAssertEqual(inset2.right.width.truncatingRemainder(dividingBy: 100), 0)
        XCTAssertEqual(inset2.left.width / 100, 1)
        XCTAssertEqual(inset2.right.width / 100, 1)
    }
    
    func testZero() {
        XCTAssertEqual(AroundInsets.zero.left.width, 0)
        XCTAssertEqual(AroundInsets.zero.right.width, 0)
    }
}
