//
//  ArrayExtensionTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/29.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class ArrayExtensionTests: XCTestCase {
    let array1 = [0,1,2,3,4,5,6,7,8,9]
    let array2 = [0,2,4,6,8]
    let array3 = [1,3,5,7,9]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUnion() {
        XCTAssertEqual(array1.union(array1), [0,1,2,3,4,5,6,7,8,9])
        XCTAssertEqual(array1.union(array2), [0,1,2,3,4,5,6,7,8,9])
        XCTAssertEqual(array1.union(array3), [0,1,2,3,4,5,6,7,8,9])
        
        XCTAssertEqual(array2.union(array1), [0,2,4,6,8,1,3,5,7,9])
        XCTAssertEqual(array2.union(array2), [0,2,4,6,8])
        XCTAssertEqual(array2.union(array3), [0,2,4,6,8,1,3,5,7,9])
        
        XCTAssertEqual(array3.union(array1), [1,3,5,7,9,0,2,4,6,8])
        XCTAssertEqual(array3.union(array2), [1,3,5,7,9,0,2,4,6,8])
        XCTAssertEqual(array3.union(array3), [1,3,5,7,9])
    }
    
    func testSubtracting() {
        XCTAssertEqual(array1.subtracting(array1), [])
        XCTAssertEqual(array1.subtracting(array2), [1,3,5,7,9])
        XCTAssertEqual(array1.subtracting(array3), [0,2,4,6,8])
        
        XCTAssertEqual(array2.subtracting(array1), [])
        XCTAssertEqual(array2.subtracting(array2), [])
        XCTAssertEqual(array2.subtracting(array3), [0,2,4,6,8])
        
        XCTAssertEqual(array3.subtracting(array1), [])
        XCTAssertEqual(array3.subtracting(array2), [1,3,5,7,9])
        XCTAssertEqual(array3.subtracting(array3), [])
    }
    
    func testIntersection() {
        XCTAssertEqual(array1.intersection(array1), [0,1,2,3,4,5,6,7,8,9])
        XCTAssertEqual(array1.intersection(array2), [0,2,4,6,8])
        XCTAssertEqual(array1.intersection(array3), [1,3,5,7,9])
        
        XCTAssertEqual(array2.intersection(array1), [0,2,4,6,8])
        XCTAssertEqual(array2.intersection(array2), [0,2,4,6,8])
        XCTAssertEqual(array2.intersection(array3), [])
        
        XCTAssertEqual(array3.intersection(array1), [1,3,5,7,9])
        XCTAssertEqual(array3.intersection(array2), [])
        XCTAssertEqual(array3.intersection(array3), [1,3,5,7,9])
    }
    
}
