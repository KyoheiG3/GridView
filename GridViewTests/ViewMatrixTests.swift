//
//  ViewMatrixTests.swift
//  GridView
//
//  Created by Kyohei Ito on 2017/01/01.
//  Copyright © 2017年 Kyohei Ito. All rights reserved.
//

import XCTest
@testable import GridView

class ViewMatrixTests: XCTestCase {
    /*
     0(x: 0, width: 10)
     1(x: 10, width: 20)
     2(x: 30, width: 30)
     3(x: 60, width: 40)
     4(x: 100, width: 50)
     5(x: 150, width: 60)
     6(x: 210, width: 70)
     7(x: 280, width: 80)
     8(x: 360, width: 90)
     9(x: 450, width: 100)
     */
    let horizontals: [Horizontal] = (0..<10).reduce([]) { acc, next -> [Horizontal] in
        let x = acc.last?.x ?? 0
        let width = CGFloat(next * 10)
        let horizontal = Horizontal(x: x + width, width: width + 10)
        return acc + [horizontal]
    }
    let vertical: [Vertical] = (0..<10).map { Vertical(y: CGFloat($0) * 100, height: 100) }
    lazy var verticals: [[Vertical]] = (0..<10).map { _ in self.vertical }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testZero() {
        let matrix = ViewMatrix()
        XCTAssertEqual(matrix.validityContentRect, .zero)
        XCTAssertEqual(matrix.contentSize, .zero)
        XCTAssertEqual(matrix.contentInset, .zero)
        XCTAssertEqual(matrix.count, 0)
        
        XCTAssertEqual(matrix.convert(CGPoint(x: 100, y: 100), from: ViewMatrix()), .zero)
        
        XCTAssertEqual(matrix.rectForRow(at: IndexPath(row: 10, column: 10)), .zero)
        XCTAssertEqual(matrix.rectForRow(at: IndexPath(row: 10, column: 10), threshold: .above), .zero)
        XCTAssertEqual(matrix.rectForRow(at: IndexPath(row: 10, column: 10), threshold: .below), .zero)
        
        XCTAssertEqual(matrix.indexPathForRow(at: CGPoint(x: 0, y: 0)), IndexPath(row: 0, column: 0))
        XCTAssertEqual(matrix.indexPathForRow(at: CGPoint(x: 100, y: 100)), IndexPath(row: 0, column: 0))
        
        XCTAssertEqual(matrix.indexesForVisibleColumn(at: CGPoint(x: 0, y: 0)), [])
        XCTAssertEqual(matrix.indexesForVisibleColumn(at: CGPoint(x: 100, y: 100)), [])
        
        XCTAssertEqual(matrix.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: 0), [])
        XCTAssertEqual(matrix.indexesForVisibleRow(at: CGPoint(x: 100, y: 100), in: 100), [])
    }
    
    func testInit() {
        let vertical1: [Vertical] = (0..<10).map { Vertical(y: CGFloat($0) * 100, height: 100) }
        let verticals1: [[Vertical]] = (0..<10).map { _ in vertical1 }
        
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 70, y: 70, width: 100, height: 100), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.validityContentRect, CGRect(x: 0, y: 0, width: 1000, height: 1000))
        XCTAssertEqual(matrix1.contentSize, CGSize(width: 1000, height: 1000))
        XCTAssertEqual(matrix1.contentInset, UIEdgeInsets(top: -70, left: -70, bottom: -130, right: -130))
        
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 70, y: 70, width: 100, height: 100), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: true)
        XCTAssertEqual(matrix2.validityContentRect, CGRect(x: 30, y: 0, width: 1000, height: 1000))
        XCTAssertEqual(matrix2.contentSize, CGSize(width: 1400, height: 1000))
        XCTAssertEqual(matrix2.contentInset, UIEdgeInsets(top: -70, left: -100, bottom: -130, right: -200))
        
        let matrix3 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 70, y: 70, width: 160, height: 160), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix3.validityContentRect, CGRect(x: 0, y: 0, width: 1600, height: 1000))
        XCTAssertEqual(matrix3.contentSize, CGSize(width: 1600, height: 1000))
        XCTAssertEqual(matrix3.contentInset, UIEdgeInsets(top: -70, left: -70, bottom: -70, right: -70))
        
        let matrix4 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 70, y: 70, width: 160, height: 160), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: true)
        XCTAssertEqual(matrix4.validityContentRect, CGRect(x: 90, y: 0, width: 1600, height: 1000))
        XCTAssertEqual(matrix4.contentSize, CGSize(width: 2080, height: 1000))
        XCTAssertEqual(matrix4.contentInset, UIEdgeInsets(top: -70, left: -160, bottom: -70, right: -160))
        
        let matrix5 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 70, y: 70, width: 160, height: 160), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40), isInfinitable: false)
        XCTAssertEqual(matrix5.validityContentRect, CGRect(x: 0, y: 0, width: 1600, height: 1000))
        XCTAssertEqual(matrix5.contentSize, CGSize(width: 1600, height: 1000))
        XCTAssertEqual(matrix5.contentInset, UIEdgeInsets(top: -60, left: -50, bottom: -40, right: -30))
        
        let matrix6 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 70, y: 70, width: 160, height: 160), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40), isInfinitable: true)
        XCTAssertEqual(matrix6.validityContentRect, CGRect(x: 90, y: 0, width: 1600, height: 1000))
        XCTAssertEqual(matrix6.contentSize, CGSize(width: 2080, height: 1000))
        XCTAssertEqual(matrix6.contentInset, UIEdgeInsets(top: -60, left: -160, bottom: -40, right: -160))
        
        let matrix7 = ViewMatrix(matrix: matrix1, viewFrame: CGRect(x: 70, y: 70, width: 100, height: 100), superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero)
        XCTAssertEqual(matrix7.validityContentRect, CGRect(x: 0, y: 0, width: 1000, height: 1000))
        XCTAssertEqual(matrix7.contentSize, CGSize(width: 1000, height: 1000))
        XCTAssertEqual(matrix7.contentInset, UIEdgeInsets(top: -70, left: -70, bottom: -130, right: -130))
        
        let matrix8 = ViewMatrix(matrix: matrix1, viewFrame: CGRect(x: 70, y: 70, width: 160, height: 160), superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero)
        XCTAssertEqual(matrix8.validityContentRect, CGRect(x: 0, y: 0, width: 1600, height: 1000))
        XCTAssertEqual(matrix8.contentSize, CGSize(width: 1600, height: 1000))
        XCTAssertEqual(matrix8.contentInset, UIEdgeInsets(top: -70, left: -70, bottom: -70, right: -70))
        
        let matrix9 = ViewMatrix(matrix: matrix1, viewFrame: CGRect(x: 70, y: 70, width: 100, height: 100), superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40))
        XCTAssertEqual(matrix9.validityContentRect, CGRect(x: 0, y: 0, width: 1000, height: 1000))
        XCTAssertEqual(matrix9.contentSize, CGSize(width: 1000, height: 1000))
        XCTAssertEqual(matrix9.contentInset, UIEdgeInsets(top: -60, left: -50, bottom: -100, right: -90))
        
        let matrix10 = ViewMatrix(matrix: matrix1, viewFrame: CGRect(x: 70, y: 70, width: 160, height: 160), superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40))
        XCTAssertEqual(matrix10.validityContentRect, CGRect(x: 0, y: 0, width: 1600, height: 1000))
        XCTAssertEqual(matrix10.contentSize, CGSize(width: 1600, height: 1000))
        XCTAssertEqual(matrix10.contentInset, UIEdgeInsets(top: -60, left: -50, bottom: -40, right: -30))
        
        let matrix11 = ViewMatrix(matrix: matrix2, viewFrame: CGRect(x: 70, y: 70, width: 100, height: 100), superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40))
        XCTAssertEqual(matrix11.validityContentRect, CGRect(x: 30, y: 0, width: 1000, height: 1000))
        XCTAssertEqual(matrix11.contentSize, CGSize(width: 1400, height: 1000))
        XCTAssertEqual(matrix11.contentInset, UIEdgeInsets(top: -60, left: -100, bottom: -100, right: -200))
        
        let matrix12 = ViewMatrix(matrix: matrix2, viewFrame: CGRect(x: 70, y: 70, width: 160, height: 160), superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40))
        XCTAssertEqual(matrix12.validityContentRect, CGRect(x: 90, y: 0, width: 1600, height: 1000))
        XCTAssertEqual(matrix12.contentSize, CGSize(width: 2080, height: 1000))
        XCTAssertEqual(matrix12.contentInset, UIEdgeInsets(top: -60, left: -160, bottom: -40, right: -160))
    }
    
    func testVerticalsForColumn() {
        let matrix = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .zero, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix.debugVerticalsForColumn(-5).count, 0)
        XCTAssertEqual(matrix.debugVerticalsForColumn(10).count, 0)
        XCTAssertEqual(matrix.debugVerticalsForColumn(0)[0], vertical[0])
        XCTAssertEqual(matrix.debugVerticalsForColumn(5)[0], vertical[0])
        XCTAssertEqual(matrix.debugVerticalsForColumn(9)[0], vertical[0])
        XCTAssertEqual(matrix.debugVerticalsForColumn(0)[5], vertical[5])
        XCTAssertEqual(matrix.debugVerticalsForColumn(5)[5], vertical[5])
        XCTAssertEqual(matrix.debugVerticalsForColumn(9)[5], vertical[5])
        XCTAssertEqual(matrix.debugVerticalsForColumn(0)[9], vertical[9])
        XCTAssertEqual(matrix.debugVerticalsForColumn(5)[9], vertical[9])
        XCTAssertEqual(matrix.debugVerticalsForColumn(9)[9], vertical[9])
    }
    
    func testVerticalForRow() {
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: -5, column: 0)), Vertical.zero)
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: 0, column: 0)), Vertical(y: 0, height: 100))
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: 5, column: 0)), Vertical(y: 500, height: 100))
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: 10, column: 0)), Vertical.zero)
        
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: -5, column: 5)), Vertical.zero)
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: 0, column: 5)), Vertical(y: 0, height: 100))
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: 5, column: 5)), Vertical(y: 500, height: 100))
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: 10, column: 5)), Vertical.zero)
        
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: -5, column: 10)), Vertical.zero)
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: 0, column: 10)), Vertical.zero)
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: 5, column: 10)), Vertical.zero)
        XCTAssertEqual(matrix1.debugVerticalForRow(at: IndexPath(row: 10, column: 10)), Vertical.zero)
        
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: Scale(x: 0.5, y: 0.5), inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix2.debugVerticalForRow(at: IndexPath(row: 0, column: 0)), Vertical(y: 0, height: 50))
        XCTAssertEqual(matrix2.debugVerticalForRow(at: IndexPath(row: 5, column: 0)), Vertical(y: 250, height: 50))
        
        XCTAssertEqual(matrix2.debugVerticalForRow(at: IndexPath(row: 0, column: 5)), Vertical(y: 0, height: 50))
        XCTAssertEqual(matrix2.debugVerticalForRow(at: IndexPath(row: 5, column: 5)), Vertical(y: 250, height: 50))
    }
    
    func testOffsetXForColumn() {
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.debugOffsetXForColumn(-5), 0)
        XCTAssertEqual(matrix1.debugOffsetXForColumn(0), 0)
        XCTAssertEqual(matrix1.debugOffsetXForColumn(5), 0)
        XCTAssertEqual(matrix1.debugOffsetXForColumn(9), 0)
        XCTAssertEqual(matrix1.debugOffsetXForColumn(10), 0)
        
        let matrix2 = ViewMatrix(horizontals: horizontals, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix2.debugOffsetXForColumn(-10), -550)
        XCTAssertEqual(matrix2.debugOffsetXForColumn(-5), -550)
        XCTAssertEqual(matrix2.debugOffsetXForColumn(0), 0)
        XCTAssertEqual(matrix2.debugOffsetXForColumn(5), 0)
        XCTAssertEqual(matrix2.debugOffsetXForColumn(9), 0)
        XCTAssertEqual(matrix2.debugOffsetXForColumn(10), 550)
        XCTAssertEqual(matrix2.debugOffsetXForColumn(15), 550)
    }
    
    func testHorizontalForColumn() {
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.debugHorizontalForColumn(-5), .zero)
        XCTAssertEqual(matrix1.debugHorizontalForColumn(0), .zero)
        XCTAssertEqual(matrix1.debugHorizontalForColumn(5), .zero)
        XCTAssertEqual(matrix1.debugHorizontalForColumn(9), .zero)
        XCTAssertEqual(matrix1.debugHorizontalForColumn(10), .zero)
        
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 0, y: 0, width: 100, height: 100), contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix2.debugHorizontalForColumn(-5), Horizontal(x: -500, width: 100))
        XCTAssertEqual(matrix2.debugHorizontalForColumn(0), Horizontal(x: 0, width: 100))
        XCTAssertEqual(matrix2.debugHorizontalForColumn(5), Horizontal(x: 500, width: 100))
        XCTAssertEqual(matrix2.debugHorizontalForColumn(9), Horizontal(x: 900, width: 100))
        XCTAssertEqual(matrix2.debugHorizontalForColumn(10), Horizontal(x: 1000, width: 100))
        
        let matrix3 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 0, y: 0, width: 100, height: 100), contentHeight: 0, superviewSize: nil, scale: Scale(x: 0.5, y: 0.5), inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix3.debugHorizontalForColumn(-5), Horizontal(x: -250, width: 50))
        XCTAssertEqual(matrix3.debugHorizontalForColumn(0), Horizontal(x: 0, width: 50))
        XCTAssertEqual(matrix3.debugHorizontalForColumn(5), Horizontal(x: 250, width: 50))
        XCTAssertEqual(matrix3.debugHorizontalForColumn(9), Horizontal(x: 450, width: 50))
        XCTAssertEqual(matrix3.debugHorizontalForColumn(10), Horizontal(x: 500, width: 50))
        
        let matrix4 = ViewMatrix(horizontals: horizontals, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix4.debugHorizontalForColumn(-5), Horizontal(x: 150 - 550, width: 60))
        XCTAssertEqual(matrix4.debugHorizontalForColumn(0), Horizontal(x: 0, width: 10))
        XCTAssertEqual(matrix4.debugHorizontalForColumn(5), Horizontal(x: 150, width: 60))
        XCTAssertEqual(matrix4.debugHorizontalForColumn(9), Horizontal(x: 450, width: 100))
        XCTAssertEqual(matrix4.debugHorizontalForColumn(10), Horizontal(x: 0 + 550, width: 10))
        XCTAssertEqual(matrix4.debugHorizontalForColumn(15), Horizontal(x: 150 + 550, width: 60))
        
        let matrix5 = ViewMatrix(horizontals: horizontals, verticals: verticals, viewFrame: CGRect(x: 0, y: 0, width: 100, height: 100), contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix5.debugHorizontalForColumn(-5), Horizontal(x: 150 - 550, width: 60))
        XCTAssertEqual(matrix5.debugHorizontalForColumn(0), Horizontal(x: 0, width: 10))
        XCTAssertEqual(matrix5.debugHorizontalForColumn(5), Horizontal(x: 150, width: 60))
        XCTAssertEqual(matrix5.debugHorizontalForColumn(9), Horizontal(x: 450, width: 100))
        XCTAssertEqual(matrix5.debugHorizontalForColumn(10), Horizontal(x: 0 + 550, width: 10))
        XCTAssertEqual(matrix5.debugHorizontalForColumn(15), Horizontal(x: 150 + 550, width: 60))
        
        let matrix6 = ViewMatrix(horizontals: horizontals, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: Scale(x: 0.5, y: 0.5), inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix6.debugHorizontalForColumn(-5), Horizontal(x: 75 - 275, width: 30))
        XCTAssertEqual(matrix6.debugHorizontalForColumn(0), Horizontal(x: 0, width: 5))
        XCTAssertEqual(matrix6.debugHorizontalForColumn(5), Horizontal(x: 75, width: 30))
        XCTAssertEqual(matrix6.debugHorizontalForColumn(9), Horizontal(x: 225, width: 50))
        XCTAssertEqual(matrix6.debugHorizontalForColumn(10), Horizontal(x: 0 + 275, width: 5))
        XCTAssertEqual(matrix6.debugHorizontalForColumn(15), Horizontal(x: 75 + 275, width: 30))
    }
    
    func testRectForRowAtIndexPathThreshold() {
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 0, column: 0), threshold: .below), CGRect(x: 0, y: 0, width: 0, height: 100))
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 0, column: 0), threshold: .above), CGRect(x: 0, y: 0, width: 0, height: 100))
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 0, column: 0), threshold: .in), CGRect(x: 0, y: 0, width: 0, height: 100))
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 5, column: 0), threshold: .below), CGRect(x: 0, y: 500, width: 0, height: 100))
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 5, column: 0), threshold: .above), CGRect(x: 0, y: 500, width: 0, height: 100))
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 5, column: 0), threshold: .in), CGRect(x: 0, y: 500, width: 0, height: 100))
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 9, column: 0), threshold: .below), CGRect(x: 0, y: 900, width: 0, height: 100))
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 9, column: 0), threshold: .above), CGRect(x: 0, y: 900, width: 0, height: 100))
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 9, column: 0), threshold: .in), CGRect(x: 0, y: 900, width: 0, height: 100))
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 10, column: 0), threshold: .below), .zero)
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 10, column: 0), threshold: .above), .zero)
        XCTAssertEqual(matrix1.rectForRow(at: IndexPath(row: 10, column: 0), threshold: .in), .zero)
        
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: -5), threshold: .below), CGRect(x: -500 - 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: -5), threshold: .above), CGRect(x: -500 + 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: -5), threshold: .in), CGRect(x: -500, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 0), threshold: .below), CGRect(x: 0 - 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 0), threshold: .above), CGRect(x: 0 + 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 0), threshold: .in), CGRect(x: 0, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 5), threshold: .below), CGRect(x: 500 - 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 5), threshold: .above), CGRect(x: 500 + 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 5), threshold: .in), CGRect(x: 500, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 9), threshold: .below), CGRect(x: 900 - 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 9), threshold: .above), CGRect(x: 900 + 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 9), threshold: .in), CGRect(x: 900, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 10), threshold: .below), CGRect(x: 1000 - 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 10), threshold: .above), CGRect(x: 1000 + 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 10), threshold: .in), CGRect(x: 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 15), threshold: .below), CGRect(x: 1500 - 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 15), threshold: .above), CGRect(x: 1500 + 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix2.rectForRow(at: IndexPath(row: 0, column: 15), threshold: .in), CGRect(x: 1500, y: 0, width: 100, height: 0))
        
        let matrix3 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: true)
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: -5), threshold: .below), CGRect(x: -400 - 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: -5), threshold: .above), CGRect(x: -400 + 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: -5), threshold: .in), CGRect(x: -400, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 0), threshold: .below), CGRect(x: 100 - 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 0), threshold: .above), CGRect(x: 100 + 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 0), threshold: .in), CGRect(x: 100, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 5), threshold: .below), CGRect(x: 600 - 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 5), threshold: .above), CGRect(x: 600 + 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 5), threshold: .in), CGRect(x: 600, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 9), threshold: .below), CGRect(x: 1000 - 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 9), threshold: .above), CGRect(x: 1000 + 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 9), threshold: .in), CGRect(x: 1000, y: 0, width: 100, height: 100))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 10), threshold: .below), CGRect(x: 1100 - 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 10), threshold: .above), CGRect(x: 1100 + 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 10), threshold: .in), CGRect(x: 1100, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 15), threshold: .below), CGRect(x: 1600 - 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 15), threshold: .above), CGRect(x: 1600 + 1000, y: 0, width: 100, height: 0))
        XCTAssertEqual(matrix3.rectForRow(at: IndexPath(row: 0, column: 15), threshold: .in), CGRect(x: 1600, y: 0, width: 100, height: 0))
    }
    
    func testIndexPathForRow() {
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.indexPathForRow(at: .zero), IndexPath(row: 0, column: 0))
        
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix2.indexPathForRow(at: .zero), IndexPath(row: 0, column: 0))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: -500, y: 0)), IndexPath(row: 0, column: 5))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 100, y: 0)), IndexPath(row: 0, column: 1))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 500, y: 0)), IndexPath(row: 0, column: 5))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 900, y: 0)), IndexPath(row: 0, column: 9))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 1000, y: 0)), IndexPath(row: 0, column: 0))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 2000, y: 0)), IndexPath(row: 0, column: 0))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 0, y: -500)), IndexPath(row: 0, column: 0))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 0, y: 100)), IndexPath(row: 1, column: 0))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 0, y: 500)), IndexPath(row: 5, column: 0))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 0, y: 900)), IndexPath(row: 9, column: 0))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 0, y: 1000)), IndexPath(row: 0, column: 0))
        XCTAssertEqual(matrix2.indexPathForRow(at: CGPoint(x: 0, y: 2000)), IndexPath(row: 0, column: 0))
        
        let matrix3 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: true)
        XCTAssertEqual(matrix3.indexPathForRow(at: .zero), IndexPath(row: 0, column: 9))
        XCTAssertEqual(matrix3.indexPathForRow(at: CGPoint(x: -500, y: 0)), IndexPath(row: 0, column: 4))
        XCTAssertEqual(matrix3.indexPathForRow(at: CGPoint(x: 100, y: 0)), IndexPath(row: 0, column: 0))
        XCTAssertEqual(matrix3.indexPathForRow(at: CGPoint(x: 500, y: 0)), IndexPath(row: 0, column: 4))
        XCTAssertEqual(matrix3.indexPathForRow(at: CGPoint(x: 900, y: 0)), IndexPath(row: 0, column: 8))
        XCTAssertEqual(matrix3.indexPathForRow(at: CGPoint(x: 1000, y: 0)), IndexPath(row: 0, column: 9))
        XCTAssertEqual(matrix3.indexPathForRow(at: CGPoint(x: 1500, y: 0)), IndexPath(row: 0, column: 4))
    }
    
    func testColumn() {
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.debugColumn(at: CGPoint(x: 50, y: 0)), 0)
        XCTAssertEqual(matrix1.debugColumn(at: CGPoint(x: 100, y: 0)), 0)
        XCTAssertEqual(matrix1.debugColumn(at: CGPoint(x: 150, y: 0)), 0)
        XCTAssertEqual(matrix1.debugColumn(at: CGPoint(x: 200, y: 0)), 0)
        XCTAssertEqual(matrix1.debugColumn(at: CGPoint(x: 250, y: 0)), 0)
        
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix2.debugColumn(at: CGPoint(x: 50, y: 0)), 0)
        XCTAssertEqual(matrix2.debugColumn(at: CGPoint(x: 100, y: 0)), 1)
        XCTAssertEqual(matrix2.debugColumn(at: CGPoint(x: 150, y: 0)), 1)
        XCTAssertEqual(matrix2.debugColumn(at: CGPoint(x: 200, y: 0)), 2)
        XCTAssertEqual(matrix2.debugColumn(at: CGPoint(x: 250, y: 0)), 2)
        
        let matrix3 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: nil, scale: Scale(x: 0.5, y: 0.5), inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix3.debugColumn(at: CGPoint(x: 50, y: 0)), 1)
        XCTAssertEqual(matrix3.debugColumn(at: CGPoint(x: 100, y: 0)), 2)
        XCTAssertEqual(matrix3.debugColumn(at: CGPoint(x: 150, y: 0)), 3)
        XCTAssertEqual(matrix3.debugColumn(at: CGPoint(x: 200, y: 0)), 4)
        XCTAssertEqual(matrix3.debugColumn(at: CGPoint(x: 250, y: 0)), 5)
        
        let matrix4 = ViewMatrix(horizontals: horizontals, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -50, y: 0)), -1)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -100, y: 0)), -1)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -150, y: 0)), -2)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -200, y: 0)), -3)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -250, y: 0)), -3)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -300, y: 0)), -4)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -350, y: 0)), -5)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -400, y: 0)), -5)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -450, y: 0)), -6)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -500, y: 0)), -8)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -550, y: 0)), -10)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -600, y: 0)), -11)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -650, y: 0)), -11)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -700, y: 0)), -12)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: -750, y: 0)), -13)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 50, y: 0)), 2)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 100, y: 0)), 4)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 150, y: 0)), 5)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 200, y: 0)), 5)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 250, y: 0)), 6)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 300, y: 0)), 7)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 350, y: 0)), 7)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 400, y: 0)), 8)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 450, y: 0)), 9)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 500, y: 0)), 9)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 550, y: 0)), 10)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 600, y: 0)), 12)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 650, y: 0)), 14)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 700, y: 0)), 15)
        XCTAssertEqual(matrix4.debugColumn(at: CGPoint(x: 750, y: 0)), 15)
        
        let matrix5 = ViewMatrix(horizontals: horizontals, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: Scale(x: 0.5, y: 0.5), inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 50, y: 0)), 4)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 100, y: 0)), 5)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 150, y: 0)), 7)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 200, y: 0)), 8)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 250, y: 0)), 9)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 300, y: 0)), 12)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 350, y: 0)), 15)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 400, y: 0)), 16)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 450, y: 0)), 17)
        XCTAssertEqual(matrix5.debugColumn(at: CGPoint(x: 500, y: 0)), 19)
    }
    
    func testIndexForRow() {
        let verticals1 = [(0..<10).map { Vertical(y: CGFloat($0) * 100, height: 100) }]
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.debugIndexForRow(at: CGPoint(x: 0, y: -500), in: 0), 0)
        XCTAssertEqual(matrix1.debugIndexForRow(at: CGPoint(x: 0, y: 0), in: 0), 0)
        XCTAssertEqual(matrix1.debugIndexForRow(at: CGPoint(x: 0, y: 100), in: 0), 1)
        XCTAssertEqual(matrix1.debugIndexForRow(at: CGPoint(x: 0, y: 500), in: 0), 5)
        XCTAssertEqual(matrix1.debugIndexForRow(at: CGPoint(x: 0, y: 999), in: 0), 9)
        XCTAssertEqual(matrix1.debugIndexForRow(at: CGPoint(x: 0, y: 1000), in: 0), 0)
        
        let verticals2 = [(0..<100).map { Vertical(y: CGFloat($0) * 100, height: 100) }]
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals2, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix2.debugIndexForRow(at: CGPoint(x: 0, y: -500), in: 0), 0)
        XCTAssertEqual(matrix2.debugIndexForRow(at: CGPoint(x: 0, y: 0), in: 0), 0)
        XCTAssertEqual(matrix2.debugIndexForRow(at: CGPoint(x: 0, y: 100), in: 0), 1)
        XCTAssertEqual(matrix2.debugIndexForRow(at: CGPoint(x: 0, y: 500), in: 0), 5)
        XCTAssertEqual(matrix2.debugIndexForRow(at: CGPoint(x: 0, y: 1000), in: 0), 10)
        XCTAssertEqual(matrix2.debugIndexForRow(at: CGPoint(x: 0, y: 5000), in: 0), 50)
        XCTAssertEqual(matrix2.debugIndexForRow(at: CGPoint(x: 0, y: 9999), in: 0), 99)
        XCTAssertEqual(matrix2.debugIndexForRow(at: CGPoint(x: 0, y: 10000), in: 0), 0)
        
        let verticals3 = [(0..<1000).map { Vertical(y: CGFloat($0) * 100, height: 100) }]
        let matrix3 = ViewMatrix(horizontals: nil, verticals: verticals3, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix3.debugIndexForRow(at: CGPoint(x: 0, y: -500), in: 0), 0)
        XCTAssertEqual(matrix3.debugIndexForRow(at: CGPoint(x: 0, y: 0), in: 0), 0)
        XCTAssertEqual(matrix3.debugIndexForRow(at: CGPoint(x: 0, y: 1000), in: 0), 10)
        XCTAssertEqual(matrix3.debugIndexForRow(at: CGPoint(x: 0, y: 5000), in: 0), 50)
        XCTAssertEqual(matrix3.debugIndexForRow(at: CGPoint(x: 0, y: 9900), in: 0), 99)
        XCTAssertEqual(matrix3.debugIndexForRow(at: CGPoint(x: 0, y: 10000), in: 0), 100)
        XCTAssertEqual(matrix3.debugIndexForRow(at: CGPoint(x: 0, y: 50000), in: 0), 500)
        XCTAssertEqual(matrix3.debugIndexForRow(at: CGPoint(x: 0, y: 99999), in: 0), 999)
        XCTAssertEqual(matrix3.debugIndexForRow(at: CGPoint(x: 0, y: 100000), in: 0), 0)
        
        let verticals4 = [(0..<1000).map { Vertical(y: CGFloat($0) * 100, height: 100) }]
        let matrix4 = ViewMatrix(horizontals: nil, verticals: verticals4, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: Scale(x: 0.5, y: 0.5), inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix4.debugIndexForRow(at: CGPoint(x: 0, y: -500), in: 0), 0)
        XCTAssertEqual(matrix4.debugIndexForRow(at: CGPoint(x: 0, y: 0), in: 0), 0)
        XCTAssertEqual(matrix4.debugIndexForRow(at: CGPoint(x: 0, y: 1000), in: 0), 20)
        XCTAssertEqual(matrix4.debugIndexForRow(at: CGPoint(x: 0, y: 5000), in: 0), 100)
        XCTAssertEqual(matrix4.debugIndexForRow(at: CGPoint(x: 0, y: 9900), in: 0), 198)
        XCTAssertEqual(matrix4.debugIndexForRow(at: CGPoint(x: 0, y: 10000), in: 0), 200)
        XCTAssertEqual(matrix4.debugIndexForRow(at: CGPoint(x: 0, y: 49999), in: 0), 999)
        XCTAssertEqual(matrix4.debugIndexForRow(at: CGPoint(x: 0, y: 50000), in: 0), 0)
    }
    
    func testIndexesForVisibleColumn() {
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.indexesForVisibleColumn(at: .zero), [])
        
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix2.indexesForVisibleColumn(at: CGPoint(x: -100, y: 0)), [-1,0,1])
        XCTAssertEqual(matrix2.indexesForVisibleColumn(at: CGPoint(x: -50, y: 0)), [-1,0,1,2])
        XCTAssertEqual(matrix2.indexesForVisibleColumn(at: CGPoint(x: 0, y: 0)), [0,1,2])
        XCTAssertEqual(matrix2.indexesForVisibleColumn(at: CGPoint(x: 50, y: 0)), [0,1,2,3])
        XCTAssertEqual(matrix2.indexesForVisibleColumn(at: CGPoint(x: 100, y: 0)), [1,2,3])
        XCTAssertEqual(matrix2.indexesForVisibleColumn(at: CGPoint(x: 150, y: 0)), [1,2,3,4])
        XCTAssertEqual(matrix2.indexesForVisibleColumn(at: CGPoint(x: 200, y: 0)), [2,3,4])
        XCTAssertEqual(matrix2.indexesForVisibleColumn(at: CGPoint(x: 250, y: 0)), [2,3,4,5])
        
        let matrix3 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: true)
        XCTAssertEqual(matrix3.indexesForVisibleColumn(at: CGPoint(x: -100, y: 0)), [-2,-1,0])
        XCTAssertEqual(matrix3.indexesForVisibleColumn(at: CGPoint(x: -50, y: 0)), [-2,-1,0,1])
        XCTAssertEqual(matrix3.indexesForVisibleColumn(at: CGPoint(x: 0, y: 0)), [-1,0,1])
        XCTAssertEqual(matrix3.indexesForVisibleColumn(at: CGPoint(x: 50, y: 0)), [-1,0,1,2])
        XCTAssertEqual(matrix3.indexesForVisibleColumn(at: CGPoint(x: 100, y: 0)), [0,1,2])
        XCTAssertEqual(matrix3.indexesForVisibleColumn(at: CGPoint(x: 150, y: 0)), [0,1,2,3])
        XCTAssertEqual(matrix3.indexesForVisibleColumn(at: CGPoint(x: 200, y: 0)), [1,2,3])
        XCTAssertEqual(matrix3.indexesForVisibleColumn(at: CGPoint(x: 250, y: 0)), [1,2,3,4])
        
        let matrix4 = ViewMatrix(horizontals: horizontals, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: -100, y: 0)), [-1,0,1,2,3,4,5])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: -50, y: 0)), [-1,0,1,2,3,4,5,6])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 0, y: 0)), [0,1,2,3,4,5,6,7])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 50, y: 0)), [2,3,4,5,6,7])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 100, y: 0)), [4,5,6,7,8])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 150, y: 0)), [5,6,7,8])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 200, y: 0)), [5,6,7,8,9])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 250, y: 0)), [6,7,8,9])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 300, y: 0)), [7,8,9,10,11,12])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 350, y: 0)), [7,8,9,10,11,12,13])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 400, y: 0)), [8,9,10,11,12,13,14])
        XCTAssertEqual(matrix4.indexesForVisibleColumn(at: CGPoint(x: 450, y: 0)), [9,10,11,12,13,14,15])
    }
    
    func testIndexesForVisibleRow() {
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: .zero, contentHeight: 0, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: 0), [])
        XCTAssertEqual(matrix1.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: 0), [])
        XCTAssertEqual(matrix1.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: 0), [])
        
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: -100), in: 0), [0,1])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: -50), in: 0), [0,1,2])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: 0), [0,1,2])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 50), in: 0), [0,1,2,3])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: 0), [1,2,3])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 150), in: 0), [1,2,3,4])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: 0), [2,3,4])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 250), in: 0), [2,3,4,5])
        
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: -5), [])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: -5), [])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: -5), [])
        
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: 10), [])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: 10), [])
        XCTAssertEqual(matrix2.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: 10), [])
        
        let matrix3 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: true)
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: -100), in: 0), [0,1])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: -50), in: 0), [0,1,2])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: 0), [0,1,2])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 50), in: 0), [0,1,2,3])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: 0), [1,2,3])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 150), in: 0), [1,2,3,4])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: 0), [2,3,4])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 250), in: 0), [2,3,4,5])
        
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: -5), [0,1,2])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: -5), [1,2,3])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: -5), [2,3,4])
        
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: 10), [0,1,2])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: 10), [1,2,3])
        XCTAssertEqual(matrix3.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: 10), [2,3,4])
        
        let matrix4 = ViewMatrix(horizontals: nil, verticals: verticals, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 0, superviewSize: CGSize(width: 300, height: 300), scale: Scale(x: 0.5, y: 0.5), inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: -100), in: 0), [0,1,2,3])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: -50), in: 0), [0,1,2,3,4])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: 0), [0,1,2,3,4,5])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 50), in: 0), [1,2,3,4,5,6])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: 0), [2,3,4,5,6,7])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 150), in: 0), [3,4,5,6,7,8])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: 0), [4,5,6,7,8,9])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 250), in: 0), [5,6,7,8,9])
        
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: -5), [])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: -5), [])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: -5), [])
        
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 0), in: 10), [])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 100), in: 10), [])
        XCTAssertEqual(matrix4.indexesForVisibleRow(at: CGPoint(x: 0, y: 200), in: 10), [])
    }
    
    func testConvertFromMatrix() {
        let vertical1: [Vertical] = (0..<10).map { Vertical(y: CGFloat($0) * 100, height: 100) }
        let verticals1: [[Vertical]] = (0..<10).map { _ in vertical1 }
        let vertical2: [Vertical] = (0..<10).map { Vertical(y: CGFloat($0) * 50, height: 50) }
        let verticals2: [[Vertical]] = (0..<10).map { _ in vertical2 }
        
        let matrix1 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        let matrix2 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.convert(.zero, from: matrix2), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix1.convert(CGPoint(x: -1000, y: -1000), from: matrix2), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 50, y: 50), from: matrix2), CGPoint(x: 150, y: 150))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 100, y: 100), from: matrix2), CGPoint(x: 200, y: 200))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 150, y: 150), from: matrix2), CGPoint(x: 250, y: 250))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 1000, y: 1000), from: matrix2), CGPoint(x: 800, y: 800))
        
        let matrix3 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: Scale(x: 0.5, y: 0.5), inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.convert(.zero, from: matrix3), CGPoint(x: 200, y: 200))
        XCTAssertEqual(matrix1.convert(CGPoint(x: -1000, y: -1000), from: matrix3), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 50, y: 50), from: matrix3), CGPoint(x: 300, y: 300))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 100, y: 100), from: matrix3), CGPoint(x: 400, y: 400))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 150, y: 150), from: matrix3), CGPoint(x: 500, y: 500))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 1000, y: 1000), from: matrix3), CGPoint(x: 800, y: 800))
        
        let matrix4 = ViewMatrix(horizontals: nil, verticals: verticals2, viewFrame: CGRect(x: 50, y: 50, width: 50, height: 50), contentHeight: 500, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.convert(.zero, from: matrix4), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix1.convert(CGPoint(x: -1000, y: -1000), from: matrix4), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 50, y: 50), from: matrix4), CGPoint(x: 200, y: 200))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 100, y: 100), from: matrix4), CGPoint(x: 300, y: 300))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 150, y: 150), from: matrix4), CGPoint(x: 400, y: 400))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 1000, y: 1000), from: matrix4), CGPoint(x: 800, y: 800))
        
        let matrix5 = ViewMatrix(horizontals: nil, verticals: verticals2, viewFrame: CGRect(x: 50, y: 50, width: 50, height: 50), contentHeight: 500, superviewSize: CGSize(width: 300, height: 300), scale: Scale(x: 0.5, y: 0.5), inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix1.convert(.zero, from: matrix5), CGPoint(x: 200, y: 200))
        XCTAssertEqual(matrix1.convert(CGPoint(x: -1000, y: -1000), from: matrix5), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 50, y: 50), from: matrix5), CGPoint(x: 400, y: 400))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 100, y: 100), from: matrix5), CGPoint(x: 600, y: 600))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 150, y: 150), from: matrix5), CGPoint(x: 800, y: 800))
        XCTAssertEqual(matrix1.convert(CGPoint(x: 1000, y: 1000), from: matrix5), CGPoint(x: 800, y: 800))
        
        let matrix6 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 1000, superviewSize: nil, scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix6.convert(.zero, from: matrix1), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix6.convert(CGPoint(x: -1000, y: -1000), from: matrix1), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix6.convert(CGPoint(x: 50, y: 50), from: matrix1), CGPoint(x: 150, y: 150))
        XCTAssertEqual(matrix6.convert(CGPoint(x: 100, y: 100), from: matrix1), CGPoint(x: 200, y: 200))
        XCTAssertEqual(matrix6.convert(CGPoint(x: 150, y: 150), from: matrix1), CGPoint(x: 250, y: 250))
        XCTAssertEqual(matrix6.convert(CGPoint(x: 2000, y: 2000), from: matrix1), CGPoint(x: 1100, y: 1100))
        
        let matrix7 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 50, y: 50, width: 100, height: 100), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: .zero, isInfinitable: false)
        XCTAssertEqual(matrix7.convert(.zero, from: matrix1), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix7.convert(CGPoint(x: -1000, y: -1000), from: matrix1), CGPoint(x: 50, y: 50))
        XCTAssertEqual(matrix7.convert(CGPoint(x: 50, y: 50), from: matrix1), CGPoint(x: 150, y: 150))
        XCTAssertEqual(matrix7.convert(CGPoint(x: 100, y: 100), from: matrix1), CGPoint(x: 200, y: 200))
        XCTAssertEqual(matrix7.convert(CGPoint(x: 150, y: 150), from: matrix1), CGPoint(x: 250, y: 250))
        XCTAssertEqual(matrix7.convert(CGPoint(x: 2000, y: 2000), from: matrix1), CGPoint(x: 750, y: 750))
        
        let matrix8 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 100, y: 100, width: 100, height: 100), contentHeight: 1000, superviewSize: nil, scale: .default, inset: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40), isInfinitable: false)
        XCTAssertEqual(matrix8.convert(.zero, from: matrix1), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix8.convert(CGPoint(x: -1000, y: -1000), from: matrix1), CGPoint(x: 80, y: 90))
        XCTAssertEqual(matrix8.convert(CGPoint(x: 50, y: 50), from: matrix1), CGPoint(x: 150, y: 150))
        XCTAssertEqual(matrix8.convert(CGPoint(x: 100, y: 100), from: matrix1), CGPoint(x: 200, y: 200))
        XCTAssertEqual(matrix8.convert(CGPoint(x: 150, y: 150), from: matrix1), CGPoint(x: 250, y: 250))
        XCTAssertEqual(matrix8.convert(CGPoint(x: 2000, y: 2000), from: matrix1), CGPoint(x: 1140, y: 1130))
        
        let matrix9 = ViewMatrix(horizontals: nil, verticals: verticals1, viewFrame: CGRect(x: 50, y: 50, width: 100, height: 100), contentHeight: 1000, superviewSize: CGSize(width: 300, height: 300), scale: .default, inset: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40), isInfinitable: false)
        XCTAssertEqual(matrix9.convert(.zero, from: matrix1), CGPoint(x: 100, y: 100))
        XCTAssertEqual(matrix9.convert(CGPoint(x: -1000, y: -1000), from: matrix1), CGPoint(x: 30, y: 40))
        XCTAssertEqual(matrix9.convert(CGPoint(x: 50, y: 50), from: matrix1), CGPoint(x: 150, y: 150))
        XCTAssertEqual(matrix9.convert(CGPoint(x: 100, y: 100), from: matrix1), CGPoint(x: 200, y: 200))
        XCTAssertEqual(matrix9.convert(CGPoint(x: 150, y: 150), from: matrix1), CGPoint(x: 250, y: 250))
        XCTAssertEqual(matrix9.convert(CGPoint(x: 2000, y: 2000), from: matrix1), CGPoint(x: 790, y: 780))
    }
}
