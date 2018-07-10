//
//  ViewController.swift
//  meditation
//
//  Created by Grey Patterson on 2018-07-05.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var saveToHealthButton: UIButton!
    
    @IBOutlet weak var clockDisplay: UILabel!
    @IBOutlet weak var timeDisplay: UIView!
    
    @IBOutlet weak var timerMode: UILabel!
    @IBOutlet weak var stopwatchMode: UILabel!
    
    
    
    @IBAction func saveToHealth(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

