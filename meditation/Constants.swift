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
    /// `UserDefaults.standard` key for storing the default duration on the timer. `Int`.
    static let timeKey = "net.twoeighty.meditation.time"
    
    /// Colors for use throughout the app
    struct colors{
        /// "Mindful" - the Health app's color for Mindful Minutes.
        static let mindful = UIColor(named: "Mindful")
        static let darker = UIColor(named: "Darker")
        static let dark = UIColor(named: "Dark")
        static let light = UIColor(named: "Light")
        static let lighter = UIColor(named: "Lighter")
        static let lighterSemiTransparent = UIColor(named: "Lighter - Semitransparent")
    }
}
