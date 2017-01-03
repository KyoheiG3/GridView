//
//  UIScrollViewExtensionTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/30.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class UIScrollViewExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidityContentOffset() {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        let scrollView = UIScrollView(frame: CGRect(x: 10, y: 10, width: 80, height: 80))
        view.addSubview(scrollView)
        
        scrollView.contentSize = view.bounds.size
        
        XCTAssertEqual(scrollView.validityContentOffset.x, -10)
        XCTAssertEqual(scrollView.validityContentOffset.y, -10)
    }
    
}
