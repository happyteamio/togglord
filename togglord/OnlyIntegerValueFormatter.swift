//
//  OnlyIntegerValueFormatter.swift
//  togglord
//
//  Created by Maciej Woźniak on 13.02.2018.
//  Copyright © 2018 happyteam.io. All rights reserved.
//

import Cocoa

class OnlyIntegerValueFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        // Ability to reset your field (otherwise you can't delete the content)
        // You can check if the field is empty later
        if partialString.isEmpty {
            newString?.pointee = "0"
            return true
        }
        
        // Optional: limit input length
        /*
         if partialString.characters.count>3 {
         return false
         }
         */
        
        let intValue = Int(partialString) ?? -1
        // Actual check
        if intValue < 0 {
            return false
        } else {
            return true
        }
    }
}
