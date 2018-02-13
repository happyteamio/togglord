//
//  KeyboardEnabledTextField.swift
//  togglord
//
//  Created by Maciej Woźniak on 13.02.2018.
//  Copyright © 2018 happyteam.io. All rights reserved.
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
    private let commandKey = NSEvent.ModifierFlags.command.rawValue
    
    private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return true }
                case "z":
                    if NSApp.sendAction(#selector(UndoActionRespondable.undo(sender:)), to:nil, from:self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return true }
                default:
                    break
                }
            }
            else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(#selector(RedoActionRespondable.redo(sender:)), to:nil, from:self) { return true }
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}
