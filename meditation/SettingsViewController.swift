//
//  ModalViewController.swift
//  meditation
//
//  Created by Grey Patterson on 2018-07-13.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import os
import UIKit
import Intents
import IntentsUI

class SettingsViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var privacyTextView: UITextView!
    @IBOutlet weak var timerSetting: UISegmentedControl!
    @IBOutlet weak var siriStack: UIStackView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - Interactions
    
    @IBAction func granularityAdjusted(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            Settings.timerGranularity = 1
        case 1:
            Settings.timerGranularity = 5
        case 2:
            Settings.timerGranularity = 30
        default:
            // We'll assume 5 seconds if we somehow get a value that shouldn't happen. Yay, defaults!
            Settings.timerGranularity = 5
        }
    }
    
    // MARK: - SiriKit
    
    @objc func addStopwatch(){
        let stopwatchIntent = StartStopwatchIntent()
        guard let stopwatchShortcut = INShortcut(intent: stopwatchIntent) else{
            os_log("Failed to create shortcut from StartStopwatchIntent", log: Log.shortcuts, type: .error)
            return
        }
        add(shortcut: stopwatchShortcut)
    }
    
    @objc func addStop(){
        let stopIntent = EndSessionIntent()
        guard let stopShortcut = INShortcut(intent: stopIntent) else{
            os_log("Failed to create shortcut from EndSessionIntent", log: Log.shortcuts, type: .error)
            return
        }
        add(shortcut: stopShortcut)
    }
    
    func add(shortcut: INShortcut){
        let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
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
        case 30:
            timerSettingSelected = 2
        default:
            // We'll assume 5 seconds, if we get a weird number that shouldn't happen.
            timerSettingSelected = 1
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let shortcuts = appDelegate.activeShortcuts{
            if let stopShortcut = INShortcut(intent: EndSessionIntent()){
                if shortcuts.filter({ $0.shortcut == stopShortcut }).count > 0{
                    // TODO: The shortcut already exists! Show an 'edit' button instead of an 'add' button
                }else{
                    // TODO: Shortcut doesn't exist, show 'add' button
                }
            }
            if let stopwatchShortcut = INShortcut(intent: StartStopwatchIntent()){
                if shortcuts.filter({ $0.shortcut == stopwatchShortcut }).count > 0{
                    // TODO: The shortcut already exists! Show an 'edit' button instead of an 'add' button
                }else{
                    // TODO: Shortcut doesn't exist, show 'add' button
                }
            }
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
