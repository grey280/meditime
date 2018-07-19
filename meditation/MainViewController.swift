//
//  ViewController.swift
//  meditation
//
//  Created by Grey Patterson on 2018-07-05.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import UIKit
import HealthKit
import AudioToolbox

/// The main view controller for the app.
class MainViewController: UIViewController {
    // MARK: Variables
    /// Does what it says on the tin.
    var healthStore: HKHealthStore?
    /// The 'save to health' button; should only be displayed if it's not automatically doing it
    @IBOutlet weak var saveToHealthButton: UIButton!
    /// The amount of time, in seconds, for the session
    var time = 0{
        didSet{
            if time < 0{ // Don't allow values below zero! Things get weird.
                time = 0
            }
            // Format the amount of seconds and write it to the screen
            DispatchQueue.main.async {
                for clockDisplay in self.clockDisplays{
                    clockDisplay.text = self.formatter.string(from: TimeInterval(self.time))
                }
            }
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
    var timer: RepeatingTimer?
    /// Used to delay resetting the timer to the last-used value after the session ends
    var resetTimer: RepeatingTimer?
    /// Whether or not we're in 'timer' mode for the current session
    var isTimerMode = false
    /// The layer for animating the start/stop of the timer
    var animateBackLayer = CAShapeLayer()
    /// The path to animate `animateBackLayer` to when the timer ends
    var centerPointPath = UIBezierPath()
    
    /// Our date components formatter; configured during `viewDidLoad`, can then be used to get formatted strings in the way we want.
    private let formatter = DateComponentsFormatter()
    
    // MARK: - Outlets
    
    /// The time displays, formatted as mm:ss
    @IBOutlet var clockDisplays: [UILabel]!
    /// The time display, in the hand-drawn analog style
    @IBOutlet weak var timeDisplay: AnalogClockView!
    
    /// 'Timer' label. Part of the timer/stopwatch dichotomy.
    @IBOutlet weak var timerMode: UILabel!
    /// 'Stopwatch' label. Part of the timer/stopwatch dichotomy.
    @IBOutlet weak var stopwatchMode: UILabel!
    /// The button to go to the Privacy view
    @IBOutlet weak var privacyButton: UIButton!
    /// Shows the help text
    @IBOutlet weak var helpLabel: UILabel!
    /// The view to display while everything is running
    @IBOutlet weak var runningView: UIView!
    
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
            if sessionStart != nil && (currentTrans.y < 10 && currentTrans.y > -10) { // Don't want it to be *too* easy to mess up the time
                // TODO: Verify that 10 is the right number to use there, does that feel right?
                break
            }
            // If you manually set the time again before we've reset it, then forget about doing that.
            if resetTimer != nil{
                resetTimer?.suspend()
                resetTimer = nil
            }
            let addValue = Int((currentTrans.y - (previousTranslation?.y ?? 0.0))/2)
            // Subtract addValue, since it'll be negative if you're swiping upwards, and positive if you're swiping downwards.
            time = time - addValue
            if isTimerMode && sessionStart != nil{ // If we're in timer mode and adjust the time, we also want the total time available to be updated
                timeDisplay.totalTime = timeDisplay.totalTime - addValue
            }
            previousTranslation = currentTrans
            // Transform angle should be between 0 and +/- pi/3
            let transformAngle: CGFloat = (currentTrans.y / view.bounds.maxY) * CGFloat(Double.pi / 3)
            let newTransform = CATransform3DMakeRotation(transformAngle, 1.0, 0.0, 0.0)
            for clockDisplay in clockDisplays{
                clockDisplay.layer.transform = newTransform
            }
            timeChange()
        case .cancelled, .ended, .failed:
            feedbackGenerator = nil
            previousTranslation = nil
            for clockDisplay in clockDisplays{
                clockDisplay.layer.transform = CATransform3DIdentity
            }
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
            let loc = sender.location(in: self.view)
            let innerPath = UIBezierPath(arcCenter: loc, radius: 0.0, startAngle: 0.0, endAngle: CGFloat(2*Double.pi), clockwise: true)
            let outerPath = UIBezierPath(arcCenter: loc, radius: view.bounds.height > view.bounds.width ? view.bounds.height * 2 : view.bounds.width * 2, startAngle: 0.0, endAngle: CGFloat(2*Double.pi), clockwise: true)
            let anim = CABasicAnimation(keyPath: "path")
            anim.fromValue = innerPath.cgPath
            anim.toValue = outerPath.cgPath
            anim.duration = constants.animationDuration
            anim.isRemovedOnCompletion = true
            animateBackLayer.path = outerPath.cgPath
            animateBackLayer.add(anim, forKey: "path")
        }else{
            endSession(sender)
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
    @objc func tick(_ timer: Timer? = nil){
        if isTimerMode && time < 1{
            // We're in timer mode and are now done!
            endSession()
        }
        if isTimerMode{
            time = time - 1
            DispatchQueue.main.async {
                self.timeDisplay.currentTime = self.time
            }
        }else{
            time = time + 1
        }
    }
    
    /// Reset the timer to the last-used value
    @objc func timerReset(_ timer: Timer? = nil){
        // Helpfully, we want 0 to be the default if we don't have something set
        time = userDefaults.integer(forKey: constants.timeKey)
        resetTimer = nil
        timeChange()
    }
    
    /// Handles the session being started; store the time as the new default, and start the timer
    func startSession(){
        // Store the time value so that we default to it next time
        userDefaults.set(time, forKey: constants.timeKey)
        // Analog timer view
        if isTimerMode{
            timeDisplay.totalTime = time
            timeDisplay.bypassAnimation = true
            timeDisplay.currentTime = time
            timeDisplay.hideClock = false
        }else{
            timeDisplay.hideClock = true
        }
        sessionStart = Date()
        // Start the timer that'll run everything.
        timer = RepeatingTimer(timeInterval: 1.0)
        timer?.eventHandler = {
            self.tick()
        }
        timer?.resume()
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
    func endSession(_ sender: UITapGestureRecognizer? = nil){
        // Store the end time of the last session; if we don't have HK permission yet, we'll use this to log it once permission is granted
        lastSessionEnd = Date()
        // If we were in timer mode and ended because the timer ran out, buzz the phone to make it clear we're done
        if isTimerMode && time == 0{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        // Copy the start time, and then reset the session start so we know the timer isn't running anymore.
        lastSessionStart = sessionStart
        sessionStart = nil
        // Stop the timer, we don't need it anymore!
        timer?.suspend()
        timer = nil
        // Start the 'reset timer' timer; say *that* five times fast
        resetTimer = RepeatingTimer(timeInterval: constants.resetDelay)
        resetTimer?.eventHandler = {
            self.timerReset()
        }
        resetTimer?.resume()
        // Show the 'save to health' button, if we need to
        DispatchQueue.main.async {
            self.saveToHealthButton.isHidden = !self.shouldShowHealth()
        }
        // Store the session to HK, if we can
        logLastSession()
        // Animate the thing closing
        func animateLayer(_ to: UIBezierPath){
            let anim = CABasicAnimation(keyPath: "path")
            anim.duration = constants.animationDuration
            anim.fromValue = animateBackLayer.path
            anim.toValue = to.cgPath
            anim.isRemovedOnCompletion = true
            animateBackLayer.path = to.cgPath
            DispatchQueue.main.async {
                self.animateBackLayer.add(anim, forKey: "path")
            }
        }
        if sender != nil{
            guard let loc = sender?.location(in: self.view) else{
                animateLayer(centerPointPath)
                return
            }
            animateLayer(UIBezierPath(arcCenter: loc, radius: 0.0, startAngle: 0.0, endAngle: CGFloat(2*Double.pi), clockwise: true))
        }else{
            animateLayer(centerPointPath)
        }
    }
    
    
    /// Handle the time being changed, either by user interaction or on first load
    func timeChange(){
        // Show which mode we're in
        guard timer == nil else{
            return
        }
        DispatchQueue.main.async {
            if self.time == 0{
                self.timerMode.textColor = constants.colors.mindful ?? UIColor.clear
                self.stopwatchMode.textColor = constants.colors.darker ?? UIColor.black
                self.isTimerMode = false
            }else{
                self.timerMode.textColor = constants.colors.darker ?? UIColor.black
                self.stopwatchMode.textColor = constants.colors.mindful ?? UIColor.clear
                self.isTimerMode = true
                if self.time % 30 == 0{ // We want a nice tap every 60 seconds.
                    self.feedbackGenerator?.selectionChanged()
                }
            }
            self.timeDisplay.bypassAnimation = true
            self.timeDisplay.totalTime = self.time
        }
        
    }
    
    /// Configures `centerPointPath` based on current layout
    @objc func setCenterPath(){
        centerPointPath = UIBezierPath(arcCenter: view.convert(clockDisplays[0].center, from: timeDisplay), radius: 0.0, startAngle: 0.0, endAngle: CGFloat(2*Double.pi), clockwise: true)
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
        // Load the time from defaults
        timerReset()
        
        // Setup animation
        animateBackLayer.fillColor = UIColor.black.cgColor
        animateBackLayer.path = centerPointPath.cgPath
        runningView.layer.insertSublayer(animateBackLayer, below: runningView.layer.sublayers?.first)
        runningView.layer.mask = animateBackLayer
        
        // Make sure we handle rotation nicely
        NotificationCenter.default.addObserver(self, selector: #selector(setCenterPath), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
}

