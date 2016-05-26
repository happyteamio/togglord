//
//  OnlyIntegerValueFormatter.swift
//  togglord
//
//  Created by Maciej Woźniak on 26.05.2016.
//  Copyright © 2016 Happy Team. All rights reserved.
//

import Cocoa

class OnlyIntegerValueFormatter: NSNumberFormatter {
    override func isPartialStringValid(partialString: String,
        newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        
        if partialString.isEmpty {
            newString.memory = "0"
            return true
        }
        
        if Int(partialString) < 0 {
            NSBeep()
            return false
        } else {
            return true
        }
    }
    
    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, range rangep: UnsafeMutablePointer<NSRange>) throws {
        let _ = try? super.getObjectValue(obj, forString: string, range: rangep)
        if obj.memory == nil {
            obj.memory = minimum ?? 0
        }
    }
}
