//
//  ScopeProcessor.swift
//  VideoScopes
//
//  Created by Serge-Olivier Amega on 3/12/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

enum ScopeProcessorType {
    case Histogram
}

class ScopeProcessor: NSObject {
    
    class func getScopeProcessor(type : ScopeProcessorType) -> ScopeProcessor {
        return ScopeProcessor()
    }
    
    override init() {
    }
    
    func getScopeImage(image : UIImage) -> UIImage {
        return image
    }
}
