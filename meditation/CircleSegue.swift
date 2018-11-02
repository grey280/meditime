//
//  CircleSegue.swift
//  meditation
//
//  Created by Grey Patterson on 11/2/18.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//  Based on [OHCircleSegue by Øyvind Hauge](https://github.com/oyvind-hauge/OHCircleSegue)
//

import Foundation

import UIKit

class CircleSegue: UIStoryboardSegue, CAAnimationDelegate {
    private static let stack = Stack()
    private static var isAnimating = false
    
    var origin = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    private var shouldUnwind = false
    
    override func perform() {
        if CircleSegue.isAnimating {
            return
        }
        
        if CircleSegue.stack.peek() !== destination {
            CircleSegue.stack.push(vc: source)
        } else {
            _ = CircleSegue.stack.pop()
            shouldUnwind = true
        }
        
        let sourceView = source.view
        let destView = destination.view
        
        let window = UIApplication.shared.keyWindow
        if !shouldUnwind {
            window?.insertSubview(destView!, aboveSubview: sourceView!)
        } else {
            window?.insertSubview(destView!, at:0)
        }
        
        let paths = startAndEndPaths(shouldUnwind: !shouldUnwind)
        
        // Create circle mask and apply it to the view of the destination controller
        let mask = CAShapeLayer()
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.position = origin
        mask.path = paths.start
        (shouldUnwind ? sourceView : destView)?.layer.mask = mask
        
        // Call method for creating animation and add it to the view's mask
        (shouldUnwind ? sourceView : destView)?.layer.mask?.add(scalingAnimation(destinationPath: paths.end), forKey: nil)
    }
    
    // MARK: Animation delegate
    
    func animationDidStart(_ anim: CAAnimation) {
        CircleSegue.isAnimating = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool)  {
        CircleSegue.isAnimating = false
        if shouldUnwind {
            source.dismiss(animated: false, completion: nil)
        } else {
            source.present(destination, animated: false, completion: nil)
        }
    }
    
    // MARK: Helper methods
    
    private func scalingAnimation(destinationPath: CGPath) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = destinationPath
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.both
        animation.duration = constants.transitionDuration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.delegate = self
        return animation
    }
    
    private func startAndEndPaths(shouldUnwind: Bool) -> (start: CGPath, end: CGPath) {
        
        // The hypothenuse is the diagonal of the screen. Further, we use this diagonal as
        // the diameter of the big circle. This way we are always certain that the big circle
        // will cover the whole screen.
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let rw = width + abs(width/2 - origin.x)
        let rh = height + abs(height/2 - origin.y)
        let h1 = hypot(width/2 - origin.x, height/2 - origin.y)
        let hyp = CGFloat(sqrtf(powf(Float(rw), 2) + powf(Float(rh), 2)))
        let dia = h1 + hyp
        
        // The two circle sizes we will animate to/from
        let path1 = UIBezierPath(ovalIn: CGRect.zero).cgPath
        let path2 = UIBezierPath(ovalIn: CGRect(x:-dia/2, y:-dia/2, width:dia, height:dia)).cgPath
        
        // If unwinding, shrink the circle; otherwise, grow it
        return shouldUnwind ? (path1, path2) : (path2, path1)
    }
    
    // MARK: Stack implementation
    
    // Simple stack implementation for keeping track of our view controllers
    private class Stack {
        
        private var stackArray = Array<UIViewController>()
        private var size: Int {
            get {
                return stackArray.count
            }
        }
        
        func push(vc: UIViewController) {
            stackArray.append(vc)
        }
        
        func pop() -> UIViewController? {
            if let last = stackArray.last {
                stackArray.removeLast()
                return last
            }
            return nil
        }
        
        func peek() -> UIViewController? {
            return stackArray.last
        }
    }
}
