//
//  ViewController.swift
//  tablescope
//
//  Created by Ryan Orendorff on 6/2/15.
//  Copyright (c) 2015 cellscope. All rights reserved.
//

// Taken from the tutorial at 
// jamesonquave.com/blog/
// taking-control-of-the-iphone-camera-in-ios-8-with-swift-part-1/

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        
                        var err : NSError? = nil
                        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice,
                            error: &err))
                        
                        if err != nil {
                            println("error: \(err?.localizedDescription)")
                        }
                        
                        beginSession()
                    }
                }
            }
        }
        
        Timer.scheduledTimerWithTimeInterval(
            NSDate().dateByAddingTimeInterval(5), interval: 1,
            repeats: false, f:
            {
                self.endSession()
                UIScreen.mainScreen().brightness = CGFloat(0)
                println("Setting the display to lowest brightness, " +
                        "disabling camera capture.")
            })
        
        Timer.scheduledTimerWithTimeInterval(
            NSDate().dateByAddingTimeInterval(10), interval: 1,
            repeats: false, f:
            {
                self.beginSession()
                UIScreen.mainScreen().brightness = CGFloat(1)
                println("Setting the display to full brightness, " +
                        "enabling camera capture.")
            })
        
    }
    
    func beginSession() {
        if !captureSession.running{
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.view.layer.addSublayer(previewLayer)
            previewLayer?.frame = self.view.layer.frame
            captureSession.startRunning()
        }
    }
    
    func endSession(){
        if captureSession.running{
            self.previewLayer?.removeFromSuperlayer()
            captureSession.stopRunning()
        }
    }
    
}