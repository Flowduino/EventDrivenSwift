//
// UIEventReceiver.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 11th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Abstract Base Type for all `UIEventRecevier` Thread Types.
 - Author: Simon J. Stuart
 - Version: 2.1.0
 - Note: Inherit from this to implement a discrete unit of code designed specifically to operate upon specific `Eventable` types containing information useful to its operation(s)
 - Note: Your Event Handlers/Listeners/Callbacks will be executed on the UI Thread every time.
 */
open class UIEventReceiver: EventReceiver, UIEventReceivable {
    private static var _shared: UIEventReceivable? = nil
    
    public static var shared: UIEventReceivable {
        get {
            if _shared == nil { _shared = UIEventReceiver() }
            return _shared!
        }
    }
    
    override internal func callTypedEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEvent: Eventable, priority: EventPriority) {
        Task { /// Have to use a Task because this method is not `async`
            await MainActor.run { /// Forces the call to be invoked on the `MainActor` (UI Thread)
                super.callTypedEventCallback(callback, forEvent: forEvent, priority:  priority)
            }
        }
    }
}
