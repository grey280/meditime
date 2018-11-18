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
    
    func createAddButton(for shortcut: INShortcut? = nil) -> INUIAddVoiceShortcutButton{
        let button = INUIAddVoiceShortcutButton(style: .black)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.shortcut = shortcut
        button.delegate = self
        return button
    }
    
    var addStopButton: INUIAddVoiceShortcutButton?
    var addWatchButton: INUIAddVoiceShortcutButton?
    
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
                
                let filtered = shortcuts.filter({ $0.shortcut == stopShortcut })
                if filtered.count > 0{
                    addStopButton = createAddButton(for: filtered[0].shortcut)
                }else{
                    addStopButton = createAddButton(for: stopShortcut)
                }
            }
            if let stopwatchShortcut = INShortcut(intent: StartStopwatchIntent()){
                
                let filtered = shortcuts.filter({ $0.shortcut == stopwatchShortcut })
                if filtered.count > 0{
                    addWatchButton = createAddButton(for: filtered[0].shortcut)
                }else{
                    addWatchButton = createAddButton(for: stopwatchShortcut)
                }
            }
        }
        
        if siriStack.arrangedSubviews.count < 2{
            siriStack.addArrangedSubview(addWatchButton!)
            siriStack.addArrangedSubview(addStopButton!)
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

extension SettingsViewController: INUIAddVoiceShortcutButtonDelegate{
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.modalPresentationStyle = .formSheet
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
}

extension SettingsViewController: INUIAddVoiceShortcutViewControllerDelegate{
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        // TODO: Better implement this?
//        addWatchButton?.shortcut = voiceShortcut?.shortcut
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension SettingsViewController: INUIEditVoiceShortcutViewControllerDelegate{
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        // TODO: Properly implement this
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        // TODO: Properly implement this
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
