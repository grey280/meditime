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
    }
    
    @IBAction func timerDoneChanged(_ sender: UISegmentedControl) {
    }
    
    // MARK: - Navigation
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // We have to do this because, for some reason, the UITextView defaults to being scrolled down
        DispatchQueue.main.async {
            self.privacyTextView.scrollRangeToVisible(NSMakeRange(0, 1))
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
