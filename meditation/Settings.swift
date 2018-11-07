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
    }
    
    /// Keys for use with UserDefaults
    private struct keys{
        static let timerGranularity = "timerGranularity"
    }
    
    /// The granularity of timer adjustments, in seconds
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
}
