//
// EventHandling.swift
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
public protocol EventHandling {
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
     Adds the given `event` to the Event Queue with the given `priority` retaining the original Dispatch Information
     - Author: Simon J. Stuart
     - Version: 4.3.0
     - Parameters:
        - event: The Event
        - priority: The Priority of the Event
     */
    func queueEvent(_ event: EventHandler.EventDispatchContainer, priority: EventPriority)
    
    /**
     Adds the given `event` to the Event Stack with the given `priority` retaining the original Dispatch Information
     - Author: Simon J. Stuart
     - Version: 4.3.0
     - Parameters:
        - event: The Event
        - priority: The Priority of the Event
     */
    func stackEvent(_ event: EventHandler.EventDispatchContainer, priority: EventPriority)
    
    /**
     Schedule the Event to be dispatched with the given `priority`
     - Author: Simon J. Stuart
     - Version: 4.2.0
     - Parameters:
        - at: The `DispatchTime` after which to dispatch the Event
        - priority: The `EventPriority` with which to process the Event
     */
    func scheduleQueue(_ event: any Eventable, at: DispatchTime, priority: EventPriority)
    
    /**
     Schedule the Event to be dispatched with the given `priority`
     - Author: Simon J. Stuart
     - Version: 4.2.0
     - Parameters:
        - at: The `DispatchTime` after which to dispatch the Event
        - priority: The `EventPriority` with which to process the Event
     */
    func scheduleStack(_ event: any Eventable, at: DispatchTime, priority: EventPriority)
    
    /**
     The number of Events currently pending in the Queue and Stack combined
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Returns: The number of Events currently pending in the Queue and Stack combined
     */
    var eventCount: Int { get }
}
