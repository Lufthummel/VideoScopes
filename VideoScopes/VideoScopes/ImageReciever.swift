//
//  ImageReciever.swift
//  VideoScopes
//
//  Created by Serge-Olivier Amega on 3/11/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

class ImageReciever: NSObject, NSStreamDelegate {
    var iStream : NSInputStream?
    var oStream : NSOutputStream?
    var updateImg : ((UIImage) -> Void)?
    
    func connectTo(host : String, port : Int) {
        print("attempting to connect to \(host):\(port)")
        
        NSStream.getStreamsToHostWithName(host, port: port, inputStream: &iStream, outputStream: &oStream)
        
        if (iStream != nil && oStream != nil) {
            iStream!.delegate = self
            oStream!.delegate = self
            
            iStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            oStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            
            iStream!.open()
            oStream!.open()
        }
    }
    
    var buffer = [UInt8](count: 1, repeatedValue: 0)
    var readingSize : Bool = true
    var size : Int = 0
    var ptrIndex : Int = 0
    
    func readStream() {
        print("reading stream")
        if readingSize {
            print("---size")
            //read size of image
            var sizeBuffer = Array<UInt8>(count: 4, repeatedValue: 0)
            iStream!.read(&sizeBuffer, maxLength: 4)
            let ptr = UnsafeMutablePointer<UInt32>(sizeBuffer)
            let num : UInt32 = ptr.memory
            size =  min(Int(num),350_000)
            print("expecting image with size : \(size)")
            
            readingSize = false
            
            buffer = Array<UInt8>(count: size, repeatedValue: 0)
        } else {
            print("---data")
            ptrIndex += iStream!.read(&(buffer[ptrIndex]), maxLength: size)
            let data = NSData(bytes: &buffer, length: size)
            
            if (ptrIndex >= size - 1) {
                
                ptrIndex = 0
                
                if let img = UIImage(data: data) {
                    updateImg?(img)
                }
                
                readingSize = true
            }
        }
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if aStream == iStream && eventCode == NSStreamEvent.HasBytesAvailable {
            readStream()
            /*
            var x = 0
            while (iStream!.hasBytesAvailable) {
                x++
                var arr = Array<UInt8>(count: 3317760, repeatedValue: 0)
                let len = 3317760
                
                iStream!.read(&arr, maxLength: len)
                
                let data = NSData(bytes: &arr, length: len)
                
                print("call")
                if let img = UIImage(data: data) {
                    print("imgGot")
                    updateImg?(img)
                }
            }
            print(x)
            */
        }
    }
}
