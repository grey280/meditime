//
//  Settings.swift
//  meditation
//
//  Created by Grey Patterson on 11/6/18.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import Foundation

class Settings{
    /// A single shared instance of UserDefaults
    private static let UD = UserDefaults.standard // good to have this in one place, in case we need to switch to a custom suite later
    
    /// Default values for settings
    private struct defaults{
        static let timerGranularity = 5
        static let time = 0
        static let lastTimer = 60*5
    }
    
    /// Keys for use with UserDefaults
    private struct keys{
        static let timerGranularity = "timerGranularity"
        static let time = "net.twoeighty.meditation.time"
        static let lastTimer = "lastTimer"
    }
    
    /// The granularity of timer adjustments, in seconds.
    static var timerGranularity: Int{
        get{
            let stored = UD.integer(forKey: keys.timerGranularity)
            if stored == 0{
                UD.set(defaults.timerGranularity, forKey: keys.timerGranularity)
                return defaults.timerGranularity
            }
            return stored
        }
        set{
            UD.set(newValue, forKey: keys.timerGranularity)
        }
    }
    
    /// Last-used time, in seconds.
    static var time: Int{
        get{
            return UD.integer(forKey: keys.time)
        }
        set{
            UD.set(newValue, forKey: keys.time)
            if newValue > 0{
                UD.set(newValue, forKey: keys.lastTimer)
            }
        }
    }
    
    /// Last-used timer, in seconds. Cannot be 0. Automatically stored when saving `time`
    static var lastTimer: Int{
        get{
            let current = UD.integer(forKey: keys.lastTimer)
            return current > 0 ? current : defaults.lastTimer
        }
    }
}
