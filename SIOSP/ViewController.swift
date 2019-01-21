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
        PJSIPIntegration.sharedInstance().activateSoundDevice()
        PJSIPIntegration.sharedInstance().makeCall()
    }
    
    func incomingCall() {
        let viewController = IncomingCallViewController()
        
        present(viewController, animated: true, completion: nil)
    }
}

