//
//  ViewReferenceTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class ViewReferenceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let view = UIView()
        let ref = ViewReference(view)
        
        XCTAssertNotNil(ref.view)
    }
    
    func testDeinit() {
        let view = UIView()
        let superview = UIView()
        superview.addSubview(view)
        
        XCTAssertNotNil(view.superview)
        
        var ref: ViewReference? = ViewReference(view)
        XCTAssertNotNil(ref?.view?.superview)
        XCTAssertNotNil(view.superview)
        
        ref = nil
        XCTAssertNil(ref?.view?.superview)
        XCTAssertNil(view.superview)
    }
    
}
