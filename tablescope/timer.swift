//
//  timer.swift
//
//  Simple scheduling of closures, based off NSTimer.
//
//  Created by Ryan Orendorff on 7/2/15.


import Foundation

/**
A class that calls some function at some specified interval.

This class allows you to easily call some closure at a regular
frequency, potentially starting at some date. This makes it very simple
to schedule functions to run at a certain time.

The design of this class is designed to match NSTimer.

:param: fireDate The date to start firing. If not given, this defaults
                 to now.
:param: interval The amount of time, in seconds, between triggering.
:param: repeats Whether to keep repeating the firing or not.
:param: f The function to call when triggering.
:returns: Timer object
*/
class Timer {

    private var timer : NSTimer? = nil

    private let fireDate : NSDate
    private let timeInvterval : NSTimeInterval
    private let f : () -> ()

    var valid  = true


    convenience init(interval : NSTimeInterval,
                     repeats : Bool,
                     f : () -> ())
    {
        self.init(fireDate: NSDate(), interval: interval,
            repeats: repeats, f: f)
    }


    init(fireDate : NSDate,
         interval : NSTimeInterval,
         repeats : Bool,
         f : () -> ())
    {
        self.f = f
        self.fireDate = fireDate
        self.timeInvterval = interval

        self.timer = NSTimer(fireDate: fireDate, interval: interval,
            target: self, selector: "fire",
            userInfo: nil, repeats: repeats)
    }

    /**
    Creates and returns a new Timer object and schedules it on the current
    run loop in the default mode.

    :param: interval The number of seconds between firings of the timer. If
                     seconds is less than or equal to 0.0, this method
                     chooses the nonnegative value of 0.1 milliseconds
                     instead.
    :param: repeats If true, the timer will repeatedly reschedule itself
                    until invalidated. If false, the timer will be
                    invalidated after it fires.
    :param: f The function to call each time the timer triggers.
    :returns: A new Timer object.
    */
    class func scheduledTimerWithTimeInterval(interval : NSTimeInterval,
                                              repeats : Bool,
                                              f : () -> ())
    {
        let t = Timer(interval: interval, repeats: repeats, f: f)
        NSRunLoop.mainRunLoop().addTimer(t.timer!,
            forMode: NSRunLoopCommonModes)
    }

    /**
    Creates and returns a new Timer object and schedules it on the current
    run loop in the default mode.

    :param: fireDate The time at which the timer should first fire.
    :param: interval The number of seconds between firings of the timer. If
                     seconds is less than or equal to 0.0, this method
                     chooses the nonnegative value of 0.1 milliseconds
                     instead.
    :param: repeats If true, the timer will repeatedly reschedule itself
                    until invalidated. If false, the timer will be
                    invalidated after it fires.
    :param: f The function to call each time the timer triggers.
    :returns: A new Timer object.
    */
    class func scheduledTimerWithTimeInterval(fireDate : NSDate,
                                              interval : NSTimeInterval,
                                              repeats : Bool,
                                              f : () -> ())
    {
        let t = Timer(fireDate: fireDate, interval: interval,
            repeats: repeats, f: f)
        NSRunLoop.mainRunLoop().addTimer(t.timer!,
            forMode: NSRunLoopCommonModes)
    }

    /**
    Creates and returns a new Timer object and schedules it on the current
    run loop in the default mode.
    */
    @objc func fire() {
        f()
    }

    /**
    Stop the triggered function from firing again.
    */
    func invalidate(){
        timer!.invalidate()
        valid = false
    }

    deinit {
        self.invalidate()
    }
}
