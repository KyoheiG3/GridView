//
//  NeedsLayout.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/28.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

enum NeedsLayout {
    case none, reload, layout(LayoutType)
    
    enum LayoutType {
        case all(ViewMatrix), vertically(ViewMatrix), rotating(ViewMatrix), pinching(ViewMatrix)
    }
}

extension NeedsLayout: Equatable {
    static func ==(lhs: NeedsLayout, rhs: NeedsLayout) -> Bool {
        switch (lhs, rhs) {
        case (none, none), (reload, reload), (layout, layout):
            return true
        default:
            return false
        }
    }
}

extension NeedsLayout.LayoutType {
    var matrix: ViewMatrix {
        switch self {
        case .all(let m), .vertically(let m), .rotating(let m), .pinching(let m):
            return m
        }
    }
}

extension NeedsLayout.LayoutType: Equatable {
    static func ==(lhs: NeedsLayout.LayoutType, rhs: NeedsLayout.LayoutType) -> Bool {
        switch (lhs, rhs) {
        case (all, all), (vertically, vertically), (rotating, rotating), (pinching, pinching):
            return true
        default:
            return false
        }
    }
}
