//
//  AnimatedLayer.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/08.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

protocol AnimatedLayerDelegate: CALayerDelegate {
    func animatedLayer(_ layer: AnimatedLayer, statusDidChange status: AnimatedLayer.Status)
}

extension AnimatedLayerDelegate {
    func animatedLayer(_ layer: AnimatedLayer, statusDidChange status: AnimatedLayer.Status) {
        // Do nothing
    }
}

class AnimatedLayer: CALayer {
    enum Status {
        case cancelled, finished
    }
    
    private static let animationkey = "progress"
    fileprivate struct Animation {
        let key = AnimatedLayer.animationkey
        let from: CGFloat = 0
        let to: CGFloat = 1
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == animationkey {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    private var isAnimating = false
    private var isAnimatingFinish: Bool {
        if isAnimating, let layer = presentation() {
            return layer.progress == animation.to
        } else {
            return false
        }
    }
    fileprivate var isProgressing: Bool {
        return isAnimating == true && isAnimatingFinish == false
    }
    fileprivate let animation = Animation()
    
    override func action(forKey event: String) -> CAAction? {
        if event == animation.key {
            isAnimating = false
            if let action = super.action(forKey: "opacity") as? CABasicAnimation {
                isAnimating = true
                
                action.keyPath = event
                action.fromValue = animation.from
                action.toValue = animation.to
                return action
            }
        }
        
        return super.action(forKey: event)
    }
    
    override func display() {
        super.display()
        
        if isProgressing == false {
            setCurrentProgress(animation.from, status: .finished)
        }
    }
}

extension AnimatedLayer {
    @NSManaged private(set) fileprivate var progress: CGFloat
    private var animatedDelegate: AnimatedLayerDelegate? {
        return delegate as? AnimatedLayerDelegate
    }
    
    fileprivate func setCurrentProgress(_ progress: CGFloat, status: Status? = nil) {
        if let status = status {
            animatedDelegate?.animatedLayer(self, statusDidChange: status)
        }
        
        if delegate != nil {
            self.progress = progress
        }
    }
}

extension AnimatedLayer {
    func animate() {
        if isProgressing {
            UIView.performWithoutAnimation {
                setCurrentProgress(animation.from, status: .cancelled)
            }
        }
        
        setCurrentProgress(animation.to)
    }
}
