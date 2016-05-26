//
//  KeyboardEnabledTextField.swift
//  togglord
//
//  Created by Maciej Woźniak on 21.05.2016.
//  Copyright © 2016 Happy Team. All rights reserved.
//

import Foundation
import Cocoa

@objc protocol UndoActionRespondable {
    func undo(sender: AnyObject)
}

@objc protocol RedoActionRespondable {
    func redo(sender: AnyObject)
}

class KeyboardEnabledTextField : NSTextField {
    private let commandKey = NSEventModifierFlags.CommandKeyMask.rawValue
    
    private let commandShiftKey = NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.ShiftKeyMask.rawValue
    
    override func performKeyEquivalent(event: NSEvent) -> Bool {
        if event.type == NSEventType.KeyDown {
            if (event.modifierFlags.rawValue & NSEventModifierFlags.DeviceIndependentModifierFlagsMask.rawValue) == commandKey {
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return true }
                case "z":
                    if NSApp.sendAction(#selector(UndoActionRespondable.undo(_:)), to:nil, from:self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return true }
                default:
                    break
                }
            }
            else if (event.modifierFlags.rawValue & NSEventModifierFlags.DeviceIndependentModifierFlagsMask.rawValue) == commandShiftKey {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(#selector(RedoActionRespondable.redo(_:)), to:nil, from:self) { return true }
                }
            }
        }
        return super.performKeyEquivalent(event)
    }
}