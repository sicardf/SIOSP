//
//  CallViewController.swift
//  SIOSP
//
//  Created by Flavien SICARD on 1/23/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

import UIKit
import AVFoundation

class IncomingViewController: UIViewController {
    
    var player: AVAudioPlayer?
    weak var vcvc: ViewController?
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        PJSIPIntegration.sharedInstance().activateSoundDevice()
    }
    
    @IBAction func accept(_ sender: Any) {
        if PJSIPIntegration.sharedInstance().acceptCall() {
            self.dismiss(animated: true) {
                self.vcvc?.presentCall(animated: false)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func declineTouch(_ sender: Any) {
        PJSIPIntegration.sharedInstance().declineCall()
        self.dismiss(animated: true, completion: nil)
    }
}
