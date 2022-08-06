//
// EventCentralable.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

public protocol EventCentralable {
    /**
     Registers the given `listener` for the given `Eventable` Type with the Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    static func addListener(_ listener: any EventReceivable, forEventType: Eventable.Type)
    
    /**
     Unregisters the given `listener` from the given `Eventable` Type for the Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    static func removeListener(_ listener: any EventReceivable, forEventType: Eventable.Type)
    
    /**
     Unregisters the given `listener` from all `Eventable` Types from the Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    static func removeListener(_ listener: any EventReceivable)
    
    /**
     Adds the given `event` to the Central Event Queue with the given `priority`
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - event: The Event
        - priority: The Priority of the Event
     */
    static func queueEvent(_ event: any Eventable, priority: EventPriority)
    
    /**
     Adds the given `event` to the Central Event Stack with the given `priority`
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - event: The Event
        - priority: The Priority of the Event
     */
    static func stackEvent(_ event: any Eventable, priority: EventPriority)
    
    /**
     The number of Events currently pending in the Queue and Stack (combined) of the Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Returns: The number of Events currently pending in the Queue and Stack combined
     */
    static var eventCount: Int { get }
}
