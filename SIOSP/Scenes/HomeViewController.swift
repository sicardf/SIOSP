//
//  HomeViewController.swift
//  SIOSP
//
//  Created by Flavien SICARD on 1/19/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var idLabel: UITextField!
    
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
        guard let callViewController = storyboard?.instantiateViewController(withIdentifier: CallViewController.identifier) as? CallViewController else {
            return
        }
        
        PJSIPIntegration.sharedInstance().activateSoundDevice()
        present(callViewController, animated: animated, completion: nil)
    }
    
    internal func presentIncomingCall() {
        guard let incomingViewController = storyboard?.instantiateViewController(withIdentifier: IncomingViewController.identifier) as? IncomingViewController else {
            return
        }
        
        incomingViewController.homeViewController = self
        present(incomingViewController, animated: true, completion: nil)
    }
}
