//
//  ViewController.swift
//  meditation
//
//  Created by Grey Patterson on 2018-07-05.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import UIKit
import HealthKit

/// The main view controller for the app.
class MainViewController: UIViewController {
    // MARK: Variables
    /// Does what it says on the tin.
    var healthStore: HKHealthStore?
    /// The 'save to health' button; should only be displayed if it's not automatically doing it
    @IBOutlet weak var saveToHealthButton: UIButton!
    /// The amount of time, in seconds, for the timer to run
    var time = 0{
        didSet{
            // Show which mode we're in
            if time == 0{
                timerMode.textColor = constants.colors.mindful ?? UIColor.clear
                stopwatchMode.textColor = constants.colors.darker ?? UIColor.black
            }else{
                timerMode.textColor = constants.colors.darker ?? UIColor.black
                stopwatchMode.textColor = constants.colors.mindful ?? UIColor.clear
            }
            // Format the amount of seconds and write it to the screen
            clockDisplay.text = formatter.string(from: TimeInterval(time))
        }
    }
    /// Locally-accessible connection to `UserDefaults.standard`
    let userDefaults = UserDefaults.standard
    
    /// Our date components formatter; configured during `viewDidLoad`, can then be used to get formatted strings in the way we want.
    private let formatter = DateComponentsFormatter()
    
    // MARK: - Outlets
    
    /// The time display, formatted as mm:ss
    @IBOutlet weak var clockDisplay: UILabel!
    /// The time display, in the hand-drawn analog style
    @IBOutlet weak var timeDisplay: UIView!
    
    /// 'Timer' label. Part of the timer/stopwatch dichotomy.
    @IBOutlet weak var timerMode: UILabel!
    /// 'Stopwatch' label. Part of the timer/stopwatch dichotomy.
    @IBOutlet weak var stopwatchMode: UILabel!
    
    // MARK: - User Functions
    
    /// Handle the user swiping to adjust the displayed time
    ///
    /// - Parameter sender: the pan gesture recognizer; used to determine how far and in which direction we've swiped
    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
    }
    
    /// Handle a double tap, either starting or stopping a mindfulness session.
    ///
    /// - Parameter sender: the tap gesture recognizer; ignored
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
    }
    
    /// Handle the 'save to health' button being pressed.
    ///
    /// - Parameter sender: the button that sent it; ignored
    @IBAction func saveToHealth(_ sender: Any? = nil) {
        
    }
    
    /// Whether or not the "save to health" button should be displayed.
    ///
    /// - Returns: True if HK is available and we haven't already got permission to save, false otherwise.
    private func shouldShowHealth() -> Bool{
        if HKHealthStore.isHealthDataAvailable(){
            healthStore = HKHealthStore()
            let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
            if healthStore?.authorizationStatus(for: mindfulType) != .notDetermined{
                return false
            }else{
                return true
            }
        }else{
            return false
        }
    }
    
    // MARK: - Internal Functions
    
    /// Set up! Checks if we've got HealthKit, and sets it up, if available.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide the 'save to health' button; it'll be displayed at the end of a session if we need to ask for permission to save it.
        saveToHealthButton.isHidden = true
        // Configure the date/time formatter, since it'll be used by setting the time, which is one of our next steps. Thanks go to [CrunchyBagel](https://crunchybagel.com/formatting-a-duration-with-nsdatecomponentsformatter/) for the how-to on this.
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]
        // Load the time from defaults; helpfully, we want 0 to be the default if we don't have something set
        time = userDefaults.integer(forKey: constants.timeKey)
    }
}

