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
    }
    
    @IBAction func endCallButtonPressed(_ sender: Any) {
        if PJSIPIntegration.sharedInstance().stopCall() {
            self.dismiss(animated: true, completion: nil)
        } else {
            alertView(title: "Error", message: "An error has occurred. Please try again")
        }
    }
}
