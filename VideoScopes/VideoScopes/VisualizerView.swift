//
//  VisualizerView.swift
//  VideoScopes
//
//  Created by Serge-Olivier Amega on 3/12/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

class VisualizerView: UIView {
    
    var imageView : UIImageView
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: frame)
        super.init(frame: frame)
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        let margins = layoutMarginsGuide
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        
        imageView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        imageView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        imageView.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
        imageView.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(image : UIImage) {
        imageView.image = image
    }

    /*
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
