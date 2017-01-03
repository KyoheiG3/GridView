//
//  ReuseQueueTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

private class MockView: UIView, Reusable {}

class ReuseQueueTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExtensionDefaults() {
        XCTAssertNotNil(MockReusable().prepareForReuse())
        
        let view = MockView()
        XCTAssertTrue(view.canReuse)
        
        let superview = UIView()
        superview.addSubview(view)
        
        XCTAssertFalse(view.canReuse)
    }
    
    func testAppend() {
        var queue = ReuseQueue<MockReusable>()
        
        XCTAssertNil(queue.dequeue(with: "1"))
        XCTAssertNil(queue.dequeue(with: "2"))
        
        queue.append(MockReusable(), for: "1")
        
        XCTAssertNotNil(queue.dequeue(with: "1"))
        XCTAssertNil(queue.dequeue(with: "2"))
        
        queue.append(MockReusable(), for: "2")
        
        XCTAssertNotNil(queue.dequeue(with: "1"))
        XCTAssertNotNil(queue.dequeue(with: "2"))
    }
    
    func testDequeue() {
        var queue = ReuseQueue<MockReusable>()
        
        XCTAssertNil(queue.dequeue(with: "1"))
        
        let reusable = MockReusable()
        queue.append(reusable, for: "1")
        
        XCTAssertNotNil(queue.dequeue(with: "1"))
        XCTAssertNotNil(queue.dequeue(with: "1"))
        
        reusable.canReuse = false
        XCTAssertNil(queue.dequeue(with: "1"))
        XCTAssertNil(queue.dequeue(with: "1"))
        
        reusable.canReuse = true
        XCTAssertNotNil(queue.dequeue(with: "1"))
        
        reusable.canReuse = false
        XCTAssertNil(queue.dequeue(with: "1"))
    }
}
