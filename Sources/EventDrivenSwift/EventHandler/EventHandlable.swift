//
// EventHandlable.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Protocol describing anything that Handles Events (both Dispatchers and Receivers are also Handlers)
 - Author: Simon J. Stuart
 - Version: 1.0.0
 */
public protocol EventHandlable {
    /**
     Adds the given `event` to the Event Queue with the given `priority`
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - event: The Event
        - priority: The Priority of the Event
     */
    func queueEvent(_ event: any Eventable, priority: EventPriority)
    
    /**
     Adds the given `event` to the Event Stack with the given `priority`
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - event: The Event
        - priority: The Priority of the Event
     */
    func stackEvent(_ event: any Eventable, priority: EventPriority)
    
    /**
     The number of Events currently pending in the Queue and Stack combined
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Returns: The number of Events currently pending in the Queue and Stack combined
     */
    var eventCount: Int { get }
}
