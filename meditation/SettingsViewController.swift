//
//  ModalViewController.swift
//  meditation
//
//  Created by Grey Patterson on 2018-07-13.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var privacyTextView: UITextView!
    @IBOutlet weak var timerSetting: UISegmentedControl!
    @IBOutlet weak var timerDoneSetting: UISegmentedControl!
    
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - Interactionos
    
    @IBAction func granularityAdjusted(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            Settings.timerGranularity = 1
        case 1:
            Settings.timerGranularity = 5
        case 2:
            Settings.timerGranularity = 60
        default:
            // We'll assume 5 seconds if we somehow get a value that shouldn't happen. Yay, defaults!
            Settings.timerGranularity = 5
        }
    }
    
    @IBAction func timerDoneChanged(_ sender: UISegmentedControl) {
    }
    
    // MARK: - Navigation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let timerGranularity = Settings.timerGranularity
        let timerSettingSelected: Int
        switch timerGranularity{
        case 1:
            timerSettingSelected = 0
        case 5:
            timerSettingSelected = 1
        case 60:
            timerSettingSelected = 2
        default:
            // We'll assume 5 seconds, if we get a weird number that shouldn't happen.
            timerSettingSelected = 1
        }
        
        DispatchQueue.main.async {
            // We have to do this because, for some reason, the UITextView defaults to being scrolled down
            self.privacyTextView.scrollRangeToVisible(NSMakeRange(0, 1))
            
            self.timerSetting.selectedSegmentIndex = timerSettingSelected
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let button = sender as? UIButton, let segue = segue as? CircleSegue else{
            return
        }
        segue.origin = button.center
        segue.button = button
    }
}
