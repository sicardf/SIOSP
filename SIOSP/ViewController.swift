//
//  ViewController.swift
//  SIOSP
//
//  Created by Flavien SICARD on 1/19/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func touchButton(_ sender: Any) {
        let pjsipIntegration: PJSIPIntegration = PJSIPIntegration()
        pjsipIntegration.testSIP()
    }
}

