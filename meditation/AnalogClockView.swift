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
            let newEnd = CGFloat(currentTime)/CGFloat(totalTime)
            frontLayer.strokeEnd = newEnd
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
        let center = CGPoint(x: frame.width/2, y: frame.height*3/4)
        let radiusStart = frame.width < frame.height ? frame.width : frame.height
        let radius = radiusStart * 0.6666
        let startPoint = CGFloat(Double.pi * 7 / 6)
        let endPoint = CGFloat(Double.pi * -1 / 6)
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startPoint, endAngle: endPoint, clockwise: true)
    }
    
    /// Prep the layers to have the right colors and stuff
    func setupLayers(){
        backLayer.path = path.cgPath
        backLayer.strokeColor = constants.colors.light?.cgColor
        backLayer.fillColor = UIColor.clear.cgColor
        backLayer.lineWidth = constants.analogClock.lineWidth
        backLayer.lineCap = constants.analogClock.endCapStyle
        frontLayer.path = path.cgPath
        frontLayer.strokeColor = constants.colors.dark?.cgColor
        frontLayer.fillColor = UIColor.clear.cgColor
        frontLayer.strokeEnd = 0.0
        frontLayer.lineWidth = constants.analogClock.lineWidth
        frontLayer.lineCap = constants.analogClock.endCapStyle
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