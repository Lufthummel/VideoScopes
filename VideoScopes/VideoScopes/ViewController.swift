//
//  ViewController.swift
//  VideoScopes
//
//  Created by Serge-Olivier Amega on 3/11/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var imageReciever = ImageReciever()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipTextField.text = ""
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageReciever.updateImg = {(img : UIImage) in
            print("updating.")
            dispatch_async(dispatch_get_main_queue()) {
                self.imageView.image = img
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

