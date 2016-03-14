//
//  ScopeProcessor.swift
//  VideoScopes
//
//  Created by Serge-Olivier Amega on 3/12/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

enum ScopeMode : UInt8 {
    case Abstract, Histogram, Waveform, Vectorscope
}

enum ColorChannel : UInt8 {
    case Red, Green, Blue, Luma
}

class ScopeProcessor: NSObject {
    
    let mode : ScopeMode
    var scopeHeight : Int = 800
    var scopeWidth : Int = 600
    
    class func getScopeProcessor(mode : ScopeMode) -> ScopeProcessor {
        switch mode {
        case .Histogram :
            return HistogramProcessor()
        case .Waveform :
            return WaveformProcesor()
        case .Vectorscope :
            return VectorscopeProcessor()
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

private class VectorscopeProcessor : ScopeProcessor {
    var destWidth : Int = 800
    var destHeight : Int = 600
    
    private override func getScopeImage(image: UIImage, params: [String : Int]) -> UIImage {
        guard let cgImg = image.CGImage else {
            return image
        }
        let scopeImg = drawVectorscope(cgImg)
        return UIImage(CGImage: scopeImg )
    }
    
    private func drawVectorscope(cgImg: CGImage) -> CGImage {
        let srcWidth = CGImageGetWidth(cgImg)
        let srcHeight = CGImageGetHeight(cgImg)
        let bytesPerPixel = 4
        var bytesPerRow = bytesPerPixel * srcWidth
        let bitsPerComponent = 8
        
        let srcPixels = Array<UInt32>(count: srcWidth * srcHeight, repeatedValue: 0)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let srcContext = CGBitmapContextCreate(UnsafeMutablePointer(srcPixels), srcWidth, srcHeight, bitsPerComponent, bytesPerRow,
            colorSpace, CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        CGContextDrawImage(srcContext, CGRect(x: 0, y: 0, width: srcWidth, height: srcHeight), cgImg)
        
        bytesPerRow = bytesPerPixel * destWidth
        var destPixels = Array<UInt32>(count: destWidth * destHeight, repeatedValue: 0)
        let destContext = CGBitmapContextCreate(UnsafeMutablePointer(destPixels), destWidth, destHeight, bitsPerComponent, bytesPerRow,
            colorSpace, CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let scopeIntensity : UInt32 = 30
        let pxCount = srcPixels.count
        
        for var i = 0; i < pxCount; i++ {
            let px = srcPixels[i]
            let r = Float( px % 256 ) / 256.0
            let g = Float( (px >> 8) % 256 ) / 256.0
            let b = Float( (px >> 16) % 256 ) / 256.0
            
            //[-.5,.5]
            let pb = -0.168736*r - 0.331264*g + 0.5*b
            let pr = 0.5*r - 0.418688*g - 0.081312*b
            
            let x_index = Int( Float(destWidth) * (pb+0.5)   )
            let y_index = Int( Float(destHeight) * (-pr+0.5) )
            
            destPixels[y_index*destWidth+x_index] = 0xff_ff_ff_ff
        }
        
        let resultImage = CGBitmapContextCreateImage(destContext)
        return resultImage!
    }
}

private class WaveformProcesor: ScopeProcessor {
    
    var destWidth : Int = 800
    var destHeight : Int = 600
    
    private override func getScopeImage(image: UIImage, params: [String : Int]) -> UIImage {
        
        guard let cgImg = image.CGImage else {
            return UIImage()
        }
        
        let resImg = readAndDrawWaveform(cgImg, channels: [.Red,.Green,.Blue])
        return UIImage(CGImage: resImg)
    }
    
    private func readAndDrawWaveform(cgImg : CGImage, channels : [ColorChannel]) -> CGImage {
        
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
        
        let sourceWidth = CGImageGetWidth(cgImg)
        let sourceHeight = CGImageGetWidth(cgImg)
        let bytesPerPixel = 4
        var bytesPerRow = bytesPerPixel * sourceWidth
        let bitsPerComponent = 8
        
        let sourcePixels = Array<UInt32>(count: sourceWidth * sourceHeight, repeatedValue: 0)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let sourceContext = CGBitmapContextCreate(UnsafeMutablePointer(sourcePixels), sourceWidth, sourceHeight, bitsPerComponent, bytesPerRow,
            colorSpace, CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        CGContextDrawImage(sourceContext, CGRect(x: 0, y: 0, width: sourceWidth, height: sourceHeight), cgImg)
        
        bytesPerRow = bytesPerPixel * destWidth
        var destPixels = Array<UInt32>(count: destWidth * destHeight, repeatedValue: 0)
        let destContext = CGBitmapContextCreate(UnsafeMutablePointer(destPixels), destWidth, destHeight, bitsPerComponent, bytesPerRow, colorSpace,
            CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let scopeIntensity : UInt32 = 30
        
        //red
        if rRed {
            for var i = 0; i < sourceWidth; i++ {
                let destX = Int(Float(i)/Float(sourceWidth)*Float(destWidth))
                for var j = 0; j < sourceHeight; j++ {
                    let redValue = (sourcePixels[j*sourceWidth+i] % 256) // [0,255]
                    let destIndex = (destHeight-1-Int(redValue))*destWidth + destX
                    
                    var destRedVal = destPixels[destIndex] % 256
                    destRedVal = min(destRedVal + scopeIntensity, 255)
                    
                    destPixels[destIndex] = destPixels[destIndex] & 0xff_ff_ff_00
                    destPixels[destIndex] = destPixels[destIndex] | destRedVal
                }
            }
        }
        
        //green
        if rGreen {
            for var i = 0; i < sourceWidth; i++ {
                let destX = Int(Float(i)/Float(sourceWidth)*Float(destWidth))
                for var j = 0; j < sourceHeight; j++ {
                    let greenValue = ((sourcePixels[j*sourceWidth+i] >> 8) % 256) // [0,255]
                    let destIndex = (destHeight-1-Int(greenValue))*destWidth + destX
                    
                    var destGreenVal = (destPixels[destIndex] >> 8) % 256
                    destGreenVal = min(destGreenVal + scopeIntensity, 255)
                    
                    destPixels[destIndex] = destPixels[destIndex] & 0xff_ff_00_ff
                    destPixels[destIndex] = destPixels[destIndex] | (destGreenVal << 8)
                }
            }
        }
        
        //blue
        if rBlue {
            for var i = 0; i < sourceWidth; i++ {
                let destX = Int(Float(i)/Float(sourceWidth)*Float(destWidth))
                for var j = 0; j < sourceHeight; j++ {
                    let blueValue = ((sourcePixels[j*sourceWidth+i] >> 16) % 256) // [0,255]
                    let destIndex = (destHeight-1-Int(blueValue))*destWidth + destX
                    
                    var destBlueVal = (destPixels[destIndex] >> 16) % 256
                    destBlueVal = min(destBlueVal + scopeIntensity, 255)
                    
                    destPixels[destIndex] = destPixels[destIndex] & 0xff_00_ff_ff
                    destPixels[destIndex] = destPixels[destIndex] | (destBlueVal << 16)
                }
            }
        }
        
        let resultImage = CGBitmapContextCreateImage(destContext)
        return resultImage!
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
