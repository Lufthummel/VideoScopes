//
//  ViewController.swift
//  VideoScopes
//
//  Created by Serge-Olivier Amega on 3/11/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scopeView: ScopeView!
    @IBOutlet weak var ipTextField: UITextField!
    var imageReciever = ImageReciever()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipTextField.text = ""
        
        imageReciever.updateImg = {(img : UIImage) in
            print("updating.")
            dispatch_async(dispatch_get_main_queue()) {
                self.scopeView.updateImage(img)
            }
        }
    }

    @IBAction func connect(sender: AnyObject) {
        if let ip = ipTextField.text {
            imageReciever.connectTo(ip, port: 8000)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

