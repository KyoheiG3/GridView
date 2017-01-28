//
//  CGSizeExtensionTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2017/01/29.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class CGSizeExtensionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOperator() {
        let size1 = CGSize(width: 10, height: 20)
        let size2 = CGSize(width: -10, height: -20)
        
        XCTAssertEqual(size1 + size1, CGSize(width: 20, height: 40))
        XCTAssertEqual(size1 + size2, .zero)
        XCTAssertEqual(size2 + size1, .zero)
        XCTAssertEqual(size2 + size2, CGSize(width: -20, height: -40))
        
        XCTAssertEqual(size1 - size1, .zero)
        XCTAssertEqual(size1 - size2, CGSize(width: 20, height: 40))
        XCTAssertEqual(size2 - size1, CGSize(width: -20, height: -40))
        XCTAssertEqual(size2 - size2, .zero)
    }
}
