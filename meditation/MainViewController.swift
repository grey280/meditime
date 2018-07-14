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
            if time < 0{ // Don't allow values below zero! Things get weird.
                time = 0
            }
            // Show which mode we're in
            if time == 0{
                timerMode.textColor = constants.colors.mindful ?? UIColor.clear
                stopwatchMode.textColor = constants.colors.darker ?? UIColor.black
                isTimerMode = false
            }else{
                timerMode.textColor = constants.colors.darker ?? UIColor.black
                stopwatchMode.textColor = constants.colors.mindful ?? UIColor.clear
                isTimerMode = true
                if time % 30 == 0{ // We want a nice tap every 60 seconds.
                    feedbackGenerator?.selectionChanged()
                }
            }
            // Format the amount of seconds and write it to the screen
            clockDisplay.text = formatter.string(from: TimeInterval(time))
        }
    }
    /// Locally-accessible connection to `UserDefaults.standard`
    let userDefaults = UserDefaults.standard
    /// Used for providing haptic feedback when the user adjusts the time
    var feedbackGenerator: UISelectionFeedbackGenerator?
    /// Used to create deltas during `swipe(_:)`
    var previousTranslation: CGPoint?
    /// The timestamp of when the current session started. If this is nil, we know a timer *isn't* running.
    var sessionStart: Date? = nil
    /// The timestamp of when the last session started. Use to allow `sessionStart` to be reset without losing useful data.
    var lastSessionStart: Date? = nil
    /// The timestamp of when the last session ended. Used to allow the 'save to health' button to save the session; otherwise, not necessary
    var lastSessionEnd: Date? = nil
    /// The global timer, used for running the clock
    var timer = Timer()
    /// Whether or not we're in 'timer' mode for the current session
    var isTimerMode = false
    
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
        switch sender.state {
        case .began:
            feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator?.prepare()
            previousTranslation = sender.translation(in: sender.view)
        case .changed:
            let currentTrans = sender.translation(in: sender.view)
            if sessionStart != nil && currentTrans.y < 10{ // Don't want it to be *too* easy to mess up the time
                // TODO: Verify that 10 is the right number to use there, does that feel right?
                break
            }
            let addValue = Int((currentTrans.y - (previousTranslation?.y ?? 0.0))/2)
            // Subtract addValue, since it'll be negative if you're swiping upwards, and positive if you're swiping downwards.
            time = time - addValue
            previousTranslation = currentTrans
        case .cancelled, .ended, .failed:
            feedbackGenerator = nil
            previousTranslation = nil
        default:
            break
        }
    }
    
    /// Handle a double tap, either starting or stopping a mindfulness session.
    ///
    /// - Parameter sender: the tap gesture recognizer; ignored
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
        // TODO: Animation in here?
        if sessionStart == nil{
            startSession()
        }else{
            endSession()
        }
    }
    
    /// Handle the 'save to health' button being pressed.
    ///
    /// - Parameter sender: the button that sent it; ignored
    @IBAction func saveToHealth(_ sender: Any? = nil) {
        let catType = HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
        healthStore?.requestAuthorization(toShare: [catType], read: nil, completion: { (success, err) in
            if success{
                self.logLastSession()
                DispatchQueue.main.async {
                    self.saveToHealthButton.isHidden = !self.shouldShowHealth()
                }
            }
        })
    }
    
    /// Whether or not the "save to health" button should be displayed.
    ///
    /// - Returns: True if HK is available and we haven't already got permission to save, false otherwise.
    private func shouldShowHealth() -> Bool{
        if HKHealthStore.isHealthDataAvailable(){
            if healthStore == nil{
                healthStore = HKHealthStore()
            }
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
    
    /// Run every 'tick' of the timer
    @objc func tick(){
        if isTimerMode && time == 1{
            // We're in timer mode and are now done!
            endSession()
        }
        if isTimerMode{
            time = time - 1
        }else{
            time = time + 1
        }
    }
    
    /// Handles the session being started; store the time as the new default, and start the timer
    func startSession(){
        sessionStart = Date()
        // Start the timer that'll run everything.
        timer = Timer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        // Store the time value so that we default to it next time
        userDefaults.set(time, forKey: constants.timeKey)
    }
    
    /// Log the last session to HealthKit, if possible
    func logLastSession(){
        guard lastSessionStart != nil, lastSessionEnd != nil, let catType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else{
            // Something went horribly wrong!
            return
        }
        if healthStore?.authorizationStatus(for: catType) != .sharingAuthorized{
            // Whoops, we don't have permission yet; since everything is still stored, though, we can just let the 'save to Health' button handle it instead
            return
        }
        let sample = HKCategorySample(type: catType, value: 0, start: lastSessionStart!, end: lastSessionEnd!)
        healthStore?.save(sample, withCompletion: { (success, err) in
            // Honestly we're not gonna handle errors here, because what else can we do if it fails? I'm not writing caching or anything, so whatever.
        })
    }
    
    /// Handles the session being ended; logs to Health, if available, and cleans things up to run again.
    func endSession(){
        // Store the end time of the last session; if we don't have HK permission yet, we'll use this to log it once permission is granted
        lastSessionEnd = Date()
        // Copy the start time, and then reset the session start so we know the timer isn't running anymore.
        lastSessionStart = sessionStart
        sessionStart = nil
        // Stop the timer, we don't need it anymore!
        timer.invalidate()
        // Show the 'save to health' button, if we need to
        DispatchQueue.main.async {
            self.saveToHealthButton.isHidden = !self.shouldShowHealth()
        }
        // Store the session to HK, if we can
        logLastSession()
    }
    
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

