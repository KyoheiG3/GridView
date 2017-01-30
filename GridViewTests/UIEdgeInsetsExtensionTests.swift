//
//  UIEdgeInsetsExtensionTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2017/01/29.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class UIEdgeInsetsExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOperator() {
        let inset1 = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let inset2 = UIEdgeInsets(top: -10, left: -20, bottom: -30, right: -40)
        
        XCTAssertEqual(inset1 + inset1, UIEdgeInsets(top: 20, left: 40, bottom: 60, right: 80))
        XCTAssertEqual(inset1 + inset2, .zero)
        XCTAssertEqual(inset2 + inset1, .zero)
        XCTAssertEqual(inset2 + inset2, UIEdgeInsets(top: -20, left: -40, bottom: -60, right: -80))
        
        XCTAssertEqual(inset1 - inset1, .zero)
        XCTAssertEqual(inset1 - inset2, UIEdgeInsets(top: 20, left: 40, bottom: 60, right: 80))
        XCTAssertEqual(inset2 - inset1, UIEdgeInsets(top: -20, left: -40, bottom: -60, right: -80))
        XCTAssertEqual(inset2 - inset2, .zero)
    }
    
    func testHorizontal() {
        let inset1 = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        let inset2 = UIEdgeInsets(top: -10, left: -20, bottom: -30, right: -40)
        
        XCTAssertEqual(inset1.horizontal, 60)
        XCTAssertEqual(inset2.horizontal, -60)
        
        XCTAssertEqual(inset1.vertical, 40)
        XCTAssertEqual(inset2.vertical, -40)
    }
}
