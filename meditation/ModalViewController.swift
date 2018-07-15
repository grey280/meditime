//
//  ModalViewController.swift
//  meditation
//
//  Created by Grey Patterson on 2018-07-13.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Appeared")
    }
}
