//
//  NeedsLayout.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/12/28.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

enum NeedsLayout: CustomDebugStringConvertible {
    case none, reload, layout(LayoutType)
    var debugDescription: String {
        switch self {
        case .none: return ".none"
        case .reload: return ".reload"
        case .layout(let type): return ".layout(\(type.debugDescription))"
        }
    }
    
    enum LayoutType: CustomDebugStringConvertible {
        case all(ViewMatrix), horizontally(ViewMatrix), rotating(ViewMatrix), scaling(ViewMatrix), pinching(ViewMatrix)
        var isScaling: Bool {
            switch self {
            case .scaling, .pinching:
                return true
            default:
                return false
            }
        }
        
        var debugDescription: String {
            switch self {
            case .all:              return ".all"
            case .horizontally:     return ".horizontally"
            case .rotating:         return ".rotating"
            case .scaling:          return ".scaling"
            case .pinching:         return ".pinching"
            }
        }
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

extension NeedsLayout: Comparable {
    /// .none < .layout < .reload
    static func <(lhs: NeedsLayout, rhs: NeedsLayout) -> Bool {
        switch rhs {
        case .reload:
            switch lhs {
            case .reload:
                return false
            default:
                return true
            }
        case .layout:
            switch lhs {
            case .reload, .layout:
                return false
            default:
                return true
            }
        case .none:
            return false
        }
    }
}

extension NeedsLayout.LayoutType {
    var matrix: ViewMatrix {
        switch self {
        case .all(let m), .horizontally(let m), .rotating(let m), .scaling(let m), .pinching(let m):
            return m
        }
    }
}

extension NeedsLayout.LayoutType: Equatable {
    static func ==(lhs: NeedsLayout.LayoutType, rhs: NeedsLayout.LayoutType) -> Bool {
        switch (lhs, rhs) {
        case (all, all), (horizontally, horizontally), (rotating, rotating), (scaling, scaling), (pinching, pinching):
            return true
        default:
            return false
        }
    }
}

extension NeedsLayout.LayoutType: Comparable {
    /// .pinching < .rotating < .horizontally < .all
    static func <(lhs: NeedsLayout.LayoutType, rhs: NeedsLayout.LayoutType) -> Bool {
        switch rhs {
        case .all:
            switch lhs {
            case .all:
                return false
            default:
                return true
            }
        case .horizontally:
            switch lhs {
            case .all, .horizontally:
                return false
            default:
                return true
            }
        case .rotating:
            switch lhs {
            case .all, .horizontally, .rotating:
                return false
            default:
                return true
            }
        case .scaling:
            switch lhs {
            case .all, .horizontally, .rotating, scaling:
                return false
            default:
                return true
            }
        case .pinching:
            return false
        }
    }
}
