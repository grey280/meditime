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
    
    // MARK: - Outlets
    
    @IBOutlet weak var clockDisplay: UILabel!
    @IBOutlet weak var timeDisplay: UIView!
    
    @IBOutlet weak var timerMode: UILabel!
    @IBOutlet weak var stopwatchMode: UILabel!
    
    // MARK: - User Functions
    
    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
    }
    
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func saveToHealth(_ sender: Any) {
    }
    
    // MARK: - Internal Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if HKHealthStore.isHealthDataAvailable(){
            healthStore = HKHealthStore()
            let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
            if healthStore?.authorizationStatus(for: mindfulType) != .notDetermined{
                saveToHealthButton.isHidden = true
            }
        }else{
            saveToHealthButton.isHidden = true
        }
        
    }
}

