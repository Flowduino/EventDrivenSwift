//
// EventReceiver.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation
import ThreadSafeSwift
import Observable

/**
 Abstract Base Type for all `EventRecevier` Thread Types.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Note: Inherit from `EventThread` to implement a discrete unit of code designed specifically to operate upon specific `Eventable` types containing information useful to its operation(s)
 - Note: This class should not be instantiated directly
 - Note: `EventPool` inherits from this
 - Note: `EventThread` inherits from this
 */
open class EventReceiver: EventHandler, EventReceiving {
    public var interestedIn: EventListenerInterest = .all
}
