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
    public var currentTime = 0{
        didSet{
            frontLayer.strokeEnd = CGFloat(currentTime/totalTime)
        }
    }
    
    /// A single shared bezier path, configured by `setupPath`
    var path = UIBezierPath()
    /// The layer in back, used to show the fill percentage possible
    var backLayer = CAShapeLayer()
    /// The layer in front, used to show the current fill percentage
    var frontLayer = CAShapeLayer()
    
    /// Prep the path for use
    func setupPath(){
        let center = CGPoint(x: frame.width/2, y: frame.height/2)
        let radius = frame.width < frame.height ? frame.width : frame.height
        let startPoint = CGFloat(Double.pi * 7 / 6)
        let endPoint = CGFloat(Double.pi * -1 / 6)
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        path.lineWidth = 5.0
        path.lineCapStyle = .butt
    }
    
    /// Prep the layers to have the right colors and stuff
    func setupLayers(){
        backLayer.path = path.cgPath
        backLayer.strokeColor = constants.colors.light?.cgColor
        frontLayer.path = path.cgPath
        frontLayer.strokeColor = constants.colors.dark?.cgColor
        frontLayer.strokeEnd = 0.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPath()
        setupLayers()
        self.layer.addSublayer(backLayer)
        self.layer.addSublayer(frontLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPath()
        setupLayers()
        self.layer.addSublayer(backLayer)
        self.layer.addSublayer(frontLayer)
    }
}
