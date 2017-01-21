//
//  NeedsLayoutTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class NeedsLayoutTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNeedsLayoutEquatable() {
        let none = NeedsLayout.none
        let reload = NeedsLayout.reload
        let layout = NeedsLayout.layout(.all(ViewMatrix()))
        
        XCTAssertTrue(none == none)
        XCTAssertTrue(reload == reload)
        XCTAssertTrue(layout == layout)
        
        XCTAssertFalse(none == reload)
        XCTAssertFalse(none == layout)
        XCTAssertFalse(reload == none)
        XCTAssertFalse(reload == layout)
        XCTAssertFalse(layout == none)
        XCTAssertFalse(layout == reload)
    }
    
    func testNeedsLayoutComparable() {
        let none = NeedsLayout.none
        let layout = NeedsLayout.layout(.all(ViewMatrix()))
        let reload = NeedsLayout.reload
        
        XCTAssertFalse(none < none)
        XCTAssertTrue(none < reload)
        XCTAssertTrue(none < layout)
        
        XCTAssertFalse(layout < none)
        XCTAssertTrue(layout < reload)
        XCTAssertFalse(layout < layout)
        
        XCTAssertFalse(reload < none)
        XCTAssertFalse(reload < reload)
        XCTAssertFalse(reload < layout)
    }
    
    func testLayoutTypeEquatable() {
        let matrix = ViewMatrix()
        let all = NeedsLayout.LayoutType.all(matrix)
        let vertically = NeedsLayout.LayoutType.vertically(matrix)
        let rotating = NeedsLayout.LayoutType.rotating(matrix)
        let pinching = NeedsLayout.LayoutType.pinching(matrix)
        
        XCTAssertTrue(all == all)
        XCTAssertTrue(vertically == vertically)
        XCTAssertTrue(rotating == rotating)
        XCTAssertTrue(pinching == pinching)
        
        XCTAssertFalse(all == vertically)
        XCTAssertFalse(all == rotating)
        XCTAssertFalse(all == pinching)
        XCTAssertFalse(vertically == all)
        XCTAssertFalse(vertically == rotating)
        XCTAssertFalse(vertically == pinching)
        XCTAssertFalse(rotating == all)
        XCTAssertFalse(rotating == vertically)
        XCTAssertFalse(rotating == pinching)
        XCTAssertFalse(pinching == all)
        XCTAssertFalse(pinching == vertically)
        XCTAssertFalse(pinching == rotating)
    }
    
    func testLayoutTypeComparable() {
        let matrix = ViewMatrix()
        let all = NeedsLayout.LayoutType.all(matrix)
        let vertically = NeedsLayout.LayoutType.vertically(matrix)
        let rotating = NeedsLayout.LayoutType.rotating(matrix)
        let pinching = NeedsLayout.LayoutType.pinching(matrix)
        
        XCTAssertFalse(all < all)
        XCTAssertFalse(all < vertically)
        XCTAssertFalse(all < rotating)
        XCTAssertFalse(all < pinching)
        
        XCTAssertTrue(vertically < all)
        XCTAssertFalse(vertically < vertically)
        XCTAssertFalse(vertically < rotating)
        XCTAssertFalse(vertically < pinching)
        
        XCTAssertTrue(rotating < all)
        XCTAssertTrue(rotating < vertically)
        XCTAssertFalse(rotating < rotating)
        XCTAssertFalse(rotating < pinching)
        
        XCTAssertTrue(pinching < all)
        XCTAssertTrue(pinching < vertically)
        XCTAssertTrue(pinching < rotating)
        XCTAssertFalse(pinching < pinching)
    }
    
    func testLayoutTypeMatrix() {
        let matrix = ViewMatrix()
        
        XCTAssertNotNil(NeedsLayout.LayoutType.all(matrix).matrix)
        XCTAssertNotNil(NeedsLayout.LayoutType.vertically(matrix).matrix)
        XCTAssertNotNil(NeedsLayout.LayoutType.rotating(matrix).matrix)
        XCTAssertNotNil(NeedsLayout.LayoutType.pinching(matrix).matrix)
    }
    
    func testDebugDescription() {
        let matrix = ViewMatrix()
        
        XCTAssertNotNil(NeedsLayout.none.debugDescription)
        XCTAssertNotNil(NeedsLayout.layout(.all(ViewMatrix())).debugDescription)
        XCTAssertNotNil(NeedsLayout.reload.debugDescription)
        
        XCTAssertNotNil(NeedsLayout.LayoutType.all(matrix).debugDescription)
        XCTAssertNotNil(NeedsLayout.LayoutType.vertically(matrix).debugDescription)
        XCTAssertNotNil(NeedsLayout.LayoutType.rotating(matrix).debugDescription)
        XCTAssertNotNil(NeedsLayout.LayoutType.pinching(matrix).debugDescription)
    }
}
