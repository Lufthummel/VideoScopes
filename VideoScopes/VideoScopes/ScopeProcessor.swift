//
//  ScopeProcessor.swift
//  VideoScopes
//
//  Created by Serge-Olivier Amega on 3/12/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

enum ScopeMode {
    case Abstract,Histogram
}

enum ColorChannel : UInt8 {
    case Red, Green, Blue, Alpha, Luma
}

class ScopeProcessor: NSObject {
    
    let mode : ScopeMode
    var scopeHeight : Int = 800
    var scopeWidth : Int = 600
    
    class func getScopeProcessor(mode : ScopeMode) -> ScopeProcessor {
        switch mode {
        case .Histogram :
            return HistogramProcessor()
        case _:
            return ScopeProcessor()
        }
    }
    
    override init() {
        mode = .Abstract
    }
    
    func getScopeImage(image : UIImage, params : [String:Int]) -> UIImage {
        return image
    }
}

private class HistogramProcessor: ScopeProcessor {
    
    var width : Int = 800
    var height : Int = 600
    
    private override func getScopeImage(image: UIImage, params: [String : Int]) -> UIImage {
        guard let cgImg = image.CGImage else {
            return UIImage()
        }
        
        let arr = readImgValues(cgImg, channels: [.Red, .Green, .Blue])
        let resCgImg = drawHistogram(arr)
        
        return UIImage(CGImage: resCgImg)
        
        //return UIImage.init(CGImage: thing(cgImg))
    }
    
    /**
     returns arrays [r,g,b,l]
     */
    private func readImgValues(cgImg : CGImage, channels : [ColorChannel]) -> Array<Array<UInt>> {
        
        var (rRed,rGreen,rBlue,rLuma) = (false,false,false,false)
        for channel in channels {
            switch channel {
            case .Red:
                rRed = true
            case .Green:
                rGreen = true
            case .Blue:
                rBlue = true
            case .Luma:
                rLuma = true
            default:
                 true
            }
        }
        
        //[0,1,2,3] -> [r,g,b,l]
        var colorArrays = Array<Array<UInt>>(count: 4, repeatedValue: Array<UInt>(count: 256, repeatedValue: 0))
        
        let w = CGImageGetWidth(cgImg)
        let h = CGImageGetWidth(cgImg)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * w
        let bitsPerComponent = 8
        
        let pixels = Array<UInt32>(count: w * h, repeatedValue: 0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGBitmapContextCreate(UnsafeMutablePointer(pixels), w, h, bitsPerComponent, bytesPerRow,
            colorSpace, CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: w, height: h), cgImg)
        
        let pixCount = pixels.count

        
        var arrRed = colorArrays[0]
        if rRed {
            for var i = 0; i < pixCount; i++ {
                let r = pixels[i] % 256
                arrRed[Int(r)]++
            }
        }
        
        var arrGreen = colorArrays[1]
        if rGreen {
            for var i = 0; i < pixCount; i++ {
                let g = (pixels[i] >> 8) % 256
                arrGreen[Int(g)]++
            }
        }
        
        var arrBlue = colorArrays[2]
        if rBlue {
            for var i = 0; i < pixCount; i++ {
                let b = (pixels[i] >> 16) % 256
                arrBlue[Int(b)]++
            }
        }
        
        var arrLuma = colorArrays[3]
        if rLuma {
            for var i = 0; i < pixCount; i++ {
                let pix = pixels[i]
                let (r,g,b) = (Float(pix % 256),
                               Float((pix >> 8) % 256),
                               Float((pix >> 16) % 256))
                
                let val = 0.2126 * r + 0.7152 * g + 0.0722 * b
                arrLuma[Int(val)]++
            }
        }
        
        colorArrays[0] = arrRed
        colorArrays[1] = arrGreen
        colorArrays[2] = arrBlue
        
        return colorArrays
    }
    
    private func drawHistogram(values : Array<Array<UInt>>) -> CGImage {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixels = Array<UInt32>(count: width * height, repeatedValue: 0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGBitmapContextCreate(UnsafeMutablePointer(pixels), width, height, bitsPerComponent, bytesPerRow,
            colorSpace, CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        let valuesCount = values[0].count
        
        for var i = 0; i < width; i++ {
            let indexForI = Int( (Float(i)/Float(width)) * Float(valuesCount) )
            //red
            for var y = Int(height - 1); (y >= 0 && (height - y) <= Int(values[0][indexForI])); y-- {
                pixels[y*width+i] = pixels[y*width+i] | 0xff_00_00_ff
            }
            
            //green
            for var y = Int(height - 1); (y >= 0 && (height - y) <= Int(values[1][indexForI])); y-- {
                pixels[y*width+i] = pixels[y*width+i] | 0xff_00_ff_00
            }
            //blue
            for var y = Int(height - 1); (y >= 0 && (height - y) <= Int(values[2][indexForI])); y-- {
                pixels[y*width+i] = pixels[y*width+i] | 0xff_ff_00_00
            }
            
        }

        let resultImage = CGBitmapContextCreateImage(context)
        return resultImage!
    }
}