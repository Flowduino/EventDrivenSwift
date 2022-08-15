//
// UIEventThread.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 11th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Abstract Base Type for all `UIEventThread` Types.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Note: Inherit from this to implement a discrete unit of code designed specifically to operate upon specific `Eventable` types containing information useful to its operation(s)
 - Note: Your Event Handlers/Listeners/Callbacks will be executed on the UI Thread every time.
 */
open class UIEventThread: EventThread, UIEventThreadable {
    private static var _shared: UIEventThreadable? = nil
    
    public static var shared: UIEventThreadable {
        get {
            if _shared == nil { _shared = UIEventThread() }
            return _shared!
        }
    }
    
    override open func callTypedEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEvent: Eventable, priority: EventPriority) {
        Task { /// Have to use a Task because this method is not `async`
            await MainActor.run { /// Forces the call to be invoked on the `MainActor` (UI Thread)
                super.callTypedEventCallback(callback, forEvent: forEvent, priority:  priority)
            }
        }
    }
}
