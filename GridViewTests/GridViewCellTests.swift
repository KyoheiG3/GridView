//
//  GridViewCellTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class GridViewCellTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let cell1 = MockCell.nib.instantiate(withOwner: nil, options: nil).first as? GridViewCell
        let cell2 = GridViewCell(frame: .zero)
        
        XCTAssertEqual(cell1?.autoresizingMask, UIViewAutoresizing(rawValue: 0))
        XCTAssertEqual(cell2.autoresizingMask, UIViewAutoresizing(rawValue: 0))
        
        XCTAssertNotNil(GridViewCell().prepareForReuse())
        XCTAssertNotNil(GridViewCell().setSelected(true))
        XCTAssertNotNil(GridViewCell().setSelected(false))
    }
    
}
