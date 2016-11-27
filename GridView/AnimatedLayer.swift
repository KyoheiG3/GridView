//
//  AnimatedLayer.swift
//  GridView
//
//  Created by Kyohei Ito on 2016/11/08.
//  Copyright © 2016年 Kyohei Ito. All rights reserved.
//

import UIKit

class AnimatedLayer: CALayer {
    private static let animationkey = "progress"
    private struct Animation {
        let key = AnimatedLayer.animationkey
        let from: CGFloat = 0
        let to: CGFloat = 1
    }
    
    private let animation = Animation()
    private var isAnimating = false
    @NSManaged private var progress: CGFloat
    
    var isAnimatedFinish: Bool {
        if isAnimating, let layer = presentation() {
            return layer.progress == animation.to
        } else {
            return progress == animation.to
        }
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == animationkey {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        progress = animation.to
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == animation.key {
            isAnimating = false
            if let action = super.action(forKey: "backgroundColor") as? CAAnimation {
                isAnimating = true
                
                let anim = CABasicAnimation()
                anim.fromValue = animation.from
                anim.beginTime = CACurrentMediaTime() + action.beginTime
                anim.duration = action.duration
                anim.delegate = action.delegate
                
                return anim
            }
        }
        
        return super.action(forKey: event)
    }
    
    override func display() {
        super.display()
        
        if isAnimatedFinish {
            progress = animation.from
        }
    }
}
