//
//  ViewController.swift
//  meditation
//
//  Created by Grey Patterson on 2018-07-05.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import UIKit
import HealthKit

class MainViewController: UIViewController {
    var healthStore: HKHealthStore?
    @IBOutlet weak var saveToHealthButton: UIButton!
    
    @IBOutlet weak var clockDisplay: UILabel!
    @IBOutlet weak var timeDisplay: UIView!
    
    @IBOutlet weak var timerMode: UILabel!
    @IBOutlet weak var stopwatchMode: UILabel!
    
    @IBAction func swipe(_ sender: UIPanGestureRecognizer) {
    }
    
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
    }
    
    @IBAction func saveToHealth(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if HKHealthStore.isHealthDataAvailable(){
            healthStore = HKHealthStore()
        }else{
            saveToHealthButton.isHidden = true
        }
        
    }
}

