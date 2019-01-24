//
//  CallViewController.swift
//  SIOSP
//
//  Created by Flavien SICARD on 1/23/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

import UIKit

class IncomingViewController: UIViewController {
    
    weak var homeViewController: HomeViewController?
    
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
    
    @IBAction func acceptedButtonPressed(_ sender: Any) {
        if PJSIPIntegration.sharedInstance().acceptCall() {
            self.dismiss(animated: true) {
                self.homeViewController?.presentCall(animated: false)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func declinedButtonPressed(_ sender: Any) {
        if PJSIPIntegration.sharedInstance().declineCall() {
            self.dismiss(animated: true, completion: nil)
        } else {
            alertView(title: "Error", message: "An error has occurred. Please try again")
        }
    }
}
