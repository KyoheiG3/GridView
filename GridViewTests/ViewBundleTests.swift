//
//  ViewBundleTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class ViewBundleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRegisterOfNib() {
        var bundle = ViewBundle<GridViewCell>()
        
        bundle.register(ofNib: MockCell.nib, for: "MockCellNib")
        XCTAssertNotNil(bundle.instantiate(with: "MockCellNib"))
    }
    
    func testRegisterOfClass() {
        var bundle = ViewBundle<GridViewCell>()
        
        bundle.register(ofClass: MockCell.self, for: "MockCellClass")
        XCTAssertNotNil(bundle.instantiate(with: "MockCellClass"))
    }
    
}
