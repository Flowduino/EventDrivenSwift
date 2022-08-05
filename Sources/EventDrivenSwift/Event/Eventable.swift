//
// Eventable.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Protocol describing anything that can be dispatched as an Event
 - Author: Simon J. Stuart
 - Version: 1.0.0
 - Note: You should **never** pass any `class` instance references along in an `Eventable` type.
 - Note: `Eventable` types **must** always be **immutable**
 */
public protocol Eventable {
    /**
     Dispatch the Event to the Central Queue with the given `priority`
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - priority: The Priority with which to process this Event
     */
    func queue(priority: EventPriority)
    
    /**
     Dispatch the Event to the Central Stack with the given `priority`
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - priority: The Priority with which to process this Event
     */
    func stack(priority: EventPriority)
}

/**
 Extension to provide Operator Overrides for `Eventable` types
 - Author: Simon J. Stuart
 - Version: 1.0.0
 */
extension Eventable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return String(reflecting: lhs) == String(reflecting: rhs)
    }
}

/**
 Extension to provide transparent `queue` and `stack` dispatch via `EventCentral`
 - Author: Simon J. Stuart
 - Version: 1.0.0
 */
extension Eventable {
    public func queue(priority: EventPriority = .normal) {
        EventCentral.shared.queueEvent(self, priority: priority)
    }
    
    public func stack(priority: EventPriority = .normal) {
        EventCentral.shared.stackEvent(self, priority: priority)
    }
}
