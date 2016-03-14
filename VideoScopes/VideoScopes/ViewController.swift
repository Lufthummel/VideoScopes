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
    var timer : NSTimer?
    var previousConnection : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipTextField.text = ""
        
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "checkStatus", userInfo: nil, repeats: true)
        
        imageReciever.updateImg = {(img : UIImage) in
            print("updating.")
            dispatch_async(dispatch_get_main_queue()) {
                self.scopeView.updateImage(img)
            }
        }
    }
    
    func checkStatus() {
        if let status = imageReciever.iStream?.streamStatus {
            if status == NSStreamStatus.Error {
                //try to reconnect:
                print("ERROR: attempting to reconnect")
                imageReciever.connectTo(previousConnection, port: 8000)
            }
        }
    }

    @IBAction func connect(sender: AnyObject) {
        if let ip = ipTextField.text {
            previousConnection = ip
            imageReciever.connectTo(ip, port: 8000)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

