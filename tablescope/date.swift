//
//  date.swift
//  TableScope
//
//  Created by Ryan Orendorff on 29/4/15.
//  Copyright (c) 2015 cellscope. All rights reserved.
//

import Foundation

// Allows NSDate to be compared using the >, ==, etc operators. It makes
// the code much more readable versus determining whether the order of
// the dates is ascending or descending.

extension NSDate: Equatable {}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    // Naïve equality that uses string comparison rather than resolving equivalent selectors
    return lhs.isEqualToDate(rhs)
}


extension NSDate : Comparable {}


public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    
    if lhs.compare(rhs) == .OrderedAscending {
        return true
    } else {
        return false
    }
}