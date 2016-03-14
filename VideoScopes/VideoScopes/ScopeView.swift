//
//  ScopeView.swift
//  VideoScopes
//
//  Created by Serge-Olivier Amega on 3/12/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

class ScopeView: UIView {
    var visualizerView : VisualizerView?
    var buttonView : ButtonView?
    var processor : ScopeProcessor = ScopeProcessor()
    var parameters : [String : Int] = [:]
    var scopeMode : ScopeMode {
        get {
            return processor.mode
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        
        visualizerView = VisualizerView(frame: frame)
        
        visualizerView?.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(visualizerView!)
        
        visualizerView?.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        visualizerView?.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        visualizerView?.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
        visualizerView?.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
        
        buttonView = ButtonView()
        processor = ScopeProcessor.getScopeProcessor(ScopeMode.Waveform)
        self.backgroundColor = UIColor.blackColor()
    }
    
    func updateImage(image : UIImage) {
        let scopeImg = processor.getScopeImage(image, params: [:])
        visualizerView?.display(scopeImg)
    }
    
    /*
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

class ButtonView: UIView {
    
}