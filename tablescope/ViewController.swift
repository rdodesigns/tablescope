//
//  ViewController.swift
//  tablescope
//
//  Created by Ryan Orendorff on 6/2/15.
//  Copyright (c) 2015 cellscope. All rights reserved.
//

// TODO: Make this not backwards (specify start time as the start of the
// day mode instead of the start of the night mode).

// Taken from the tutorial at
// jamesonquave.com/blog/
// taking-control-of-the-iphone-camera-in-ios-8-with-swift-part-1/

import UIKit
import AVFoundation

let day_in_sec : NSTimeInterval = 86400

let sleepTimeStart = (hour: 17, minute: 30)
let sleepTimeStop = (hour: 8, minute: 30)

class ViewController: UIViewController {

    var startToday : NSDate?
    var stopToday : NSDate?

    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?


    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?

    override func viewDidLoad() -> Void {
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

                        var err : NSError? = nil
                        captureSession.sessionPreset =
                            AVCaptureSessionPresetPhoto
                        captureSession.addInput(
                            AVCaptureDeviceInput(device: captureDevice,
                                                 error: &err))

                        if err != nil {
                            println("error: \(err?.localizedDescription)")
                        }
                    }
                }
            }
        }

        // Disable the screen lock from occurring.
        UIApplication.sharedApplication().idleTimerDisabled = true

        assert(sleepTimeStart.hour > sleepTimeStop.hour ||
                  (sleepTimeStart.hour == sleepTimeStop.hour &&
                   sleepTimeStart.minute > sleepTimeStop.minute),
               "Sleep start and stop are in the wrong order!")

        // When starting the app, we are going to figure out if we are
        // in a night session time or a day session time.
        let now = NSDate()
        setStartStopDate(now)

        // TODO: If we switch to Swift 1.2+, use the late binding let
        // instead of var.
        //
        // Here we will start the manipulations of the [start/stop]Today
        // dates to reflect the correct days to trigger on. This case
        // corresponds to being in the morning night session.
        var startDate = startToday!
        var stopDate = stopToday!

        // Figure out if we are in a day or night session, and start the
        // app in the correct configuration when first launched.
        if now < startToday && now >= stopToday {
            daySession()

            // We are during the day so we need to move the stop date to
            // trigger tomorrow for the first time (today's time has passed)
            stopDate = stopToday!.dateByAddingTimeInterval(day_in_sec)
        } else {
            nightSession()

            // We are during the later night period so we need to move both
            // the start and the stop stop date to trigger tomorrow for the
            // first time (today's time has passed)
            if now >= startToday {
                startDate = startToday!.dateByAddingTimeInterval(day_in_sec)
                stopDate = stopToday!.dateByAddingTimeInterval(day_in_sec)
            }

        }

        // Finally set the timers.
        Timer.scheduledTimerWithTimeInterval(
            startDate, interval: day_in_sec,
            repeats: true, f: { self.nightSession() })

        Timer.scheduledTimerWithTimeInterval(
            stopDate, interval: day_in_sec,
            repeats: true, f: { self.daySession() })

        // If we press down on the screen for 2 seconds switch current
        // mode
        let longPressRecognizer = UILongPressGestureRecognizer(target: self,
            action: "longPress:")
        longPressRecognizer.minimumPressDuration = 2.0
        self.view.addGestureRecognizer(longPressRecognizer)

    } // end viewDidLoad

    // Session modes
    func daySession() -> Void {
        UIScreen.mainScreen().brightness = CGFloat(1)

        if !captureSession.running{
            previewLayer =
                AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.transform = CATransform3DMakeScale(-1, -1, 1)
            self.view.layer.addSublayer(previewLayer)
            previewLayer?.frame = self.view.layer.frame
            captureSession.startRunning()
        }
    }

    func nightSession() -> Void {
        UIScreen.mainScreen().brightness = CGFloat(0)

        if captureSession.running{
            self.previewLayer?.removeFromSuperlayer()
            captureSession.stopRunning()
        }
    }

    func switchSession() -> Void {
        if !captureSession.running{
            daySession()
        } else {
            nightSession()
        }
    }

    // Used by the long press to switch the session mode
    func longPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            switchSession()
        }
    }

    func modeWakeUpFromBackground(){
        let now = NSDate()

        if now < startToday && now >= stopToday {
            daySession()

        } else {
            nightSession()

        }
    }

    func setStartStopDate(now : NSDate) {
        let calendar = NSCalendar(
            calendarIdentifier: NSCalendarIdentifierGregorian)

        // The components and [start/stop]Today are specified for a start
        // and stop time that are both in the current day. This situation
        // only occurs if we are before the stop time on the current day.
        // Otherwise we will need to either add a day to the start or the
        // end dates in order to trigger them correctly.
        let start_components = calendar!.components(.CalendarUnitYear |
            .CalendarUnitMonth | .CalendarUnitDay, fromDate: now)
        start_components.hour = sleepTimeStart.hour
        start_components.minute = sleepTimeStart.minute

        self.startToday = calendar!.dateFromComponents(start_components)


        let stop_components = calendar!.components(.CalendarUnitYear |
            .CalendarUnitMonth | .CalendarUnitDay, fromDate: startToday!)
        stop_components.hour = sleepTimeStop.hour
        stop_components.minute = sleepTimeStop.minute

        self.stopToday = calendar!.dateFromComponents(stop_components)
    }


}
