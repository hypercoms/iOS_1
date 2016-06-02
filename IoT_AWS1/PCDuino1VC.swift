//
//  PCDuino1VC.swift
//  IoT_AWS1
//
//  Created by TKT_SS9_43 on 2/06/2016.
//  Copyright © 2016 Hyper. All rights reserved.
//

import UIKit

protocol PCDuino1VCDelegate {
    func vcDismissed()
}

class PCDuino1VC: UIViewController {
    
    var delegate : PCDuino1VCDelegate?

    
    override func viewDidLoad() {
        view.backgroundColor = UIColor (red: 0, green: 0, blue: 0, alpha: 0.9)
        view.opaque = false
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true) { 
            
            if self.delegate != nil {
                self.delegate?.vcDismissed()
            }

        }
    }
    
}


