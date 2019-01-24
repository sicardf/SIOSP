//
//  CallViewController.swift
//  SIOSP
//
//  Created by Flavien SICARD on 1/23/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

import UIKit

class CallViewController: UIViewController {

    @IBOutlet weak var informationLabel: UILabel!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PJSIPIntegration.sharedInstance().configureEndCall {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func endCallButtonPressed(_ sender: Any) {
        PJSIPIntegration.sharedInstance().stopCall()
        dismiss(animated: true, completion: nil)
    }
}
