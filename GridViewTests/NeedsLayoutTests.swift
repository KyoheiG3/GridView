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
        let horizontally = NeedsLayout.LayoutType.horizontally(matrix)
        let rotating = NeedsLayout.LayoutType.rotating(matrix)
        let scaling = NeedsLayout.LayoutType.scaling(matrix)
        let pinching = NeedsLayout.LayoutType.pinching(matrix)
        
        XCTAssertTrue(all == all)
        XCTAssertTrue(horizontally == horizontally)
        XCTAssertTrue(rotating == rotating)
        XCTAssertTrue(scaling == scaling)
        XCTAssertTrue(pinching == pinching)
        
        XCTAssertFalse(all == horizontally)
        XCTAssertFalse(all == rotating)
        XCTAssertFalse(all == scaling)
        XCTAssertFalse(all == pinching)
        XCTAssertFalse(horizontally == all)
        XCTAssertFalse(horizontally == rotating)
        XCTAssertFalse(horizontally == scaling)
        XCTAssertFalse(horizontally == pinching)
        XCTAssertFalse(rotating == all)
        XCTAssertFalse(rotating == horizontally)
        XCTAssertFalse(rotating == scaling)
        XCTAssertFalse(rotating == pinching)
        XCTAssertFalse(scaling == all)
        XCTAssertFalse(scaling == horizontally)
        XCTAssertFalse(scaling == rotating)
        XCTAssertFalse(scaling == pinching)
        XCTAssertFalse(pinching == all)
        XCTAssertFalse(pinching == horizontally)
        XCTAssertFalse(pinching == scaling)
        XCTAssertFalse(pinching == rotating)
    }
    
    func testLayoutTypeComparable() {
        let matrix = ViewMatrix()
        let all = NeedsLayout.LayoutType.all(matrix)
        let horizontally = NeedsLayout.LayoutType.horizontally(matrix)
        let rotating = NeedsLayout.LayoutType.rotating(matrix)
        let scaling = NeedsLayout.LayoutType.scaling(matrix)
        let pinching = NeedsLayout.LayoutType.pinching(matrix)
        
        XCTAssertFalse(all < all)
        XCTAssertFalse(all < horizontally)
        XCTAssertFalse(all < rotating)
        XCTAssertFalse(all < scaling)
        XCTAssertFalse(all < pinching)
        
        XCTAssertTrue(horizontally < all)
        XCTAssertFalse(horizontally < horizontally)
        XCTAssertFalse(horizontally < rotating)
        XCTAssertFalse(horizontally < scaling)
        XCTAssertFalse(horizontally < pinching)
        
        XCTAssertTrue(rotating < all)
        XCTAssertTrue(rotating < horizontally)
        XCTAssertFalse(rotating < rotating)
        XCTAssertFalse(rotating < scaling)
        XCTAssertFalse(rotating < pinching)
        
        XCTAssertTrue(scaling < all)
        XCTAssertTrue(scaling < horizontally)
        XCTAssertTrue(scaling < rotating)
        XCTAssertFalse(scaling < scaling)
        XCTAssertFalse(scaling < pinching)
        
        XCTAssertTrue(pinching < all)
        XCTAssertTrue(pinching < horizontally)
        XCTAssertTrue(pinching < rotating)
        XCTAssertTrue(pinching < scaling)
        XCTAssertFalse(pinching < pinching)
    }
    
    func testLayoutTypeMatrix() {
        let matrix = ViewMatrix()
        
        XCTAssertNotNil(NeedsLayout.LayoutType.all(matrix).matrix)
        XCTAssertNotNil(NeedsLayout.LayoutType.horizontally(matrix).matrix)
        XCTAssertNotNil(NeedsLayout.LayoutType.rotating(matrix).matrix)
        XCTAssertNotNil(NeedsLayout.LayoutType.pinching(matrix).matrix)
    }
    
    func testDebugDescription() {
        let matrix = ViewMatrix()
        
        XCTAssertNotNil(NeedsLayout.none.debugDescription)
        XCTAssertNotNil(NeedsLayout.layout(.all(ViewMatrix())).debugDescription)
        XCTAssertNotNil(NeedsLayout.reload.debugDescription)
        
        XCTAssertNotNil(NeedsLayout.LayoutType.all(matrix).debugDescription)
        XCTAssertNotNil(NeedsLayout.LayoutType.horizontally(matrix).debugDescription)
        XCTAssertNotNil(NeedsLayout.LayoutType.rotating(matrix).debugDescription)
        XCTAssertNotNil(NeedsLayout.LayoutType.pinching(matrix).debugDescription)
    }
    
    func testIsScaling() {
        let matrix = ViewMatrix()
        let all = NeedsLayout.LayoutType.all(matrix)
        let horizontally = NeedsLayout.LayoutType.horizontally(matrix)
        let rotating = NeedsLayout.LayoutType.rotating(matrix)
        let scaling = NeedsLayout.LayoutType.scaling(matrix)
        let pinching = NeedsLayout.LayoutType.pinching(matrix)
        
        XCTAssertFalse(all.isScaling)
        XCTAssertFalse(horizontally.isScaling)
        XCTAssertFalse(rotating.isScaling)
        XCTAssertTrue(scaling.isScaling)
        XCTAssertTrue(pinching.isScaling)
    }
}
