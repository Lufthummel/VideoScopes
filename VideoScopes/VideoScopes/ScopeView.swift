//
//  ScopeView.swift
//  VideoScopes
//
//  Created by Serge-Olivier Amega on 3/12/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

private let buttonSpace : CGFloat = 30.0
private let buttonSmallSpace : CGFloat = 5.0

typealias ParameterMap = [ParameterName : Parameter]

enum ParameterName : UInt8 {
    case ColorChannelParam, ModeParam, ScaleParam
}

struct Parameter {
    let list : [UInt8]
    let item : UInt8
    let floNum : Float
}

class ScopeView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    var visualizerView : VisualizerView?
    var buttonView : ButtonView?
    var processor : ScopeProcessor = ScopeProcessor()
    var parameters : ParameterMap = [:]
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
    
    func changeMode(newMode : ScopeMode) {
        //change processor
        processor = ScopeProcessor.getScopeProcessor(newMode)
        
        //update buttonView
        buttonView?.changeToMode(newMode)
        
        print("didChangeToMode:\(newMode.name())")
        
    }
    
    func initialize() {
        
        //VIEW INITIALIZATIONS ==========================================
        visualizerView = VisualizerView(frame: CGRect(x: buttonSpace,
                                                      y: buttonSpace,
                                                  width: frame.width - 2 * buttonSpace,
                                                 height: frame.height - 2 * buttonSpace))
        buttonView = ButtonView(frame: CGRect(x: 0, y: frame.height - buttonSpace, width: frame.width, height: buttonSpace),
            mode: ScopeMode.Abstract) {
                self.toggleModeChooser()
        }
        addSubview(visualizerView!)
        addSubview(buttonView!)
        visualizerView?.translatesAutoresizingMaskIntoConstraints = false
        buttonView?.translatesAutoresizingMaskIntoConstraints = false
        
        
        //VISUALIZER VIEW ================================================
        visualizerView?.backgroundColor = UIColor.blackColor()
        
        visualizerView?.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        visualizerView?.bottomAnchor.constraintEqualToAnchor(buttonView?.topAnchor).active = true
        visualizerView?.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        visualizerView?.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        
        
        //BUTTON VIEW ====================================================
        buttonView?.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        buttonView?.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        buttonView?.topAnchor.constraintEqualToAnchor(visualizerView?.bottomAnchor).active = true
        buttonView?.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        buttonView?.heightAnchor.constraintEqualToConstant(buttonSpace).active = true
        
        changeMode(.Histogram)
    }
    
    func updateImage(image : UIImage) {
        let scopeImg = processor.getScopeImage(image, params: [:])
        visualizerView?.display(scopeImg, params: [ .ScaleParam : Parameter(list: [], item: 0, floNum: 1.0) ])
    }
    
    // DISPLAY MODE PICKER ========================================
    let arrayOfModes = ScopeMode.listOfNames()
    lazy var pickerView : UIPickerView = {
        
        let visViewFrame = self.visualizerView!.frame
        let pickerViewHeight = min(200,visViewFrame.height)
        
        var ret = UIPickerView(frame: CGRect(x: visViewFrame.origin.x,
                                   y: visViewFrame.origin.y + visViewFrame.height/2 - pickerViewHeight/2,
                               width: visViewFrame.width,
                              height: pickerViewHeight))
        
        ret.dataSource = self
        ret.delegate = self
        ret.showsSelectionIndicator = true
        
        ret.backgroundColor = UIColor(white: 0.5, alpha: 0.3)
        
        return ret
    }()
    var isDisplayingPicker : Bool = false
    
    func toggleModeChooser() {
        if isDisplayingPicker {
            hideModeChooser()
            isDisplayingPicker = false
        } else {
            showModeChooser()
            isDisplayingPicker = true
        }
    }
    
    func hideModeChooser() {
        pickerView.removeFromSuperview()
        
        let selectedRow = pickerView.selectedRowInComponent(0)
        let rowName = arrayOfModes[selectedRow]
        let newMode = ScopeMode.modeForName(rowName)
        changeMode(newMode)
        
    }
    
    func showModeChooser() {
        addSubview(pickerView)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayOfModes.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let plainTitle = arrayOfModes[row]
        let result = NSAttributedString(string: plainTitle, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        return result
    }
    
    /*
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

class ButtonView: UIView {
    
    let buttonColor = UIColor(red: 0.75, green: 1.0, blue: 0.5, alpha: 1.0)
    let borderColor = UIColor.whiteColor()
    let ctrlState = UIControlState.Normal
    let chooseScopeMode : ((Void) -> Void)
    
    var selectionButton : UIButton = UIButton()
    var paramButtons : [UIButton] = []
    
    init(frame: CGRect, mode: ScopeMode, chooseModeCallback : ()->Void ) {
        
        chooseScopeMode = chooseModeCallback
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = 1.0
        
        //chooser button
        selectionButton = UIButton(type: UIButtonType.InfoLight)
        selectionButton.tintColor = buttonColor
        selectionButton.addTarget(self, action: "chooseScope", forControlEvents: UIControlEvents.TouchUpInside)
        
        selectionButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionButton)
        selectionButton.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: buttonSmallSpace).active = true
        selectionButton.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        selectionButton.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        selectionButton.widthAnchor.constraintEqualToConstant(buttonSpace)
        
        changeToMode(mode)
    }
    
    func chooseScope() {
        chooseScopeMode()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeToMode(mode : ScopeMode) {
        
        for button in paramButtons {
            button.removeFromSuperview()
        }
        paramButtons.removeAll()
        
        switch mode {
        case ScopeMode.Histogram :
            setupHistogramButtons()
        case _ :
            true
        }
    }
    
    //PRECONDITION : there are no param buttons in the view
    func setupHistogramButtons() {
        
        print("setup")
        
        //order [L R G B]
        for i in 0..<4 {
            let button = UIButton(type: UIButtonType.System)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            
            let buttonStrs = ["B","G","R","L"]
            button.setTitle(buttonStrs[i], forState: UIControlState.Normal)
            button.tintColor = buttonColor
            
            addSubview(button)
            
            button.rightAnchor.constraintEqualToAnchor(rightAnchor,
                constant: buttonSmallSpace - buttonSmallSpace - CGFloat(i) * (buttonSpace + buttonSmallSpace)).active = true
            button.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
            button.topAnchor.constraintEqualToAnchor(topAnchor).active = true
            button.widthAnchor.constraintEqualToConstant(buttonSpace).active = true
            
            paramButtons.append(button)
        }
        
        
    }
    
}

