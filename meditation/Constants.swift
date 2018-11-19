//
//  Constants.swift
//  meditation
//
//  Created by Grey Patterson on 2018-07-10.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import Foundation
import UIKit

/// Constants for use in various places. No magic numbers, thanks.
struct constants{
    /// A formatter used to show minutes and seconds nicely.
    static let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        // Configure the date/time formatter, since it'll be used by setting the time, which is one of our next steps. Thanks go to [CrunchyBagel](https://crunchybagel.com/formatting-a-duration-with-nsdatecomponentsformatter/) for the how-to on this.
        f.unitsStyle = .positional
        f.allowedUnits = [ .minute, .second ]
        f.zeroFormattingBehavior = [ .pad ]
        return f
    }()
    
    /// Amount of time to wait after a session ends before resetting the timer
    static let resetDelay: TimeInterval = 1.5
    
    /// Duration for the animation of the start/stop of the timer
    static let animationDuration: TimeInterval = 0.75
    
    /// Duration for the transition animations
    static let transitionDuration: TimeInterval = 0.3
    
    /// Bits and pieces for the 'analog' clock view.
    struct analogClock{
        static let lineWidth: CGFloat = 5.0
        static let endCapStyle = CAShapeLayerLineCap.butt
    }
    
    /// Colors for use throughout the app
    struct colors{
        /// "Mindful" - the Health app's color for Mindful Minutes.
        static let mindful = UIColor(named: "Mindful")
        static let darkest = UIColor(named: "Darkest")
        static let darker = UIColor(named: "Darker")
        static let dark = UIColor(named: "Dark")
        static let light = UIColor(named: "Light")
        static let lighter = UIColor(named: "Lighter")
        static let lightest = UIColor(named: "Lightest")
    }
}
