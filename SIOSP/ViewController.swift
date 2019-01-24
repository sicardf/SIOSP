//
//  ViewController.swift
//  SIOSP
//
//  Created by Flavien SICARD on 1/19/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var idLabel: UITextField!
    // let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround() 
        
        PJSIPIntegration.sharedInstance().configureIncomingCall {
            DispatchQueue.main.async {
                self.presentIncomingCall()
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func touchButton(_ sender: Any) {
        guard let id = idLabel.text, PJSIPIntegration.sharedInstance().makeCall(id) else {
            return
        }
        
        PJSIPIntegration.sharedInstance().activateSoundDevice()
        if let vc = storyboard?.instantiateViewController(withIdentifier: CallViewController.identifier) as? CallViewController {
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func touchSpeaker(_ sender: Any) {
        PJSIPIntegration.sharedInstance().changeOutputAudioPort(.speaker)
    }
    
    internal func presentCall(animated: Bool = true) {
        PJSIPIntegration.sharedInstance().activateSoundDevice()
        if let vc = storyboard?.instantiateViewController(withIdentifier: CallViewController.identifier) as? CallViewController {
            present(vc, animated: animated, completion: nil)
        }
    }
    
    internal func presentIncomingCall() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: IncomingViewController.identifier) as? IncomingViewController {
            vc.vcvc = self
            present(vc, animated: true, completion: nil)
        }
    }
    
}
