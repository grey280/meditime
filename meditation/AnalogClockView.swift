//
//  AnalogClockView.swift
//  meditation
//
//  Created by Grey Patterson on 2018-07-14.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import UIKit

class AnalogClockView: UIView {
    
    /// Total time, in seconds, that the timer will be running
    public var totalTime = 0
    /// Amount of time, in seconds, that the timer has been running
    public var currentTime = 0
    
    var path = UIBezierPath()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        let center = CGPoint(x: frame.width/2, y: frame.height/2)
        let radius = frame.width < frame.height ? frame.width : frame.height
        let startPoint = CGFloat(Double.pi * 7 / 6)
        let endPoint = CGFloat(Double.pi * -1 / 6)
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        path.lineWidth = 5.0
        path.lineCapStyle = .butt
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        constants.colors.light?.setStroke()
        path.stroke()
        constants.colors.dark?.setStroke()
        
    }

}
