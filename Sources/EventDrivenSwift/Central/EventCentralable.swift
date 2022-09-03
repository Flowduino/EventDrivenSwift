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
     Registers the given `receiver` for the given `Eventable` Type with the Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    static func addReceiver(_ receiver: any EventReceiving, forEventType: Eventable.Type)
    
    /**
     Unregisters the given `receiver` from the given `Eventable` Type for the Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    static func removeReceiver(_ receiver: any EventReceiving, forEventType: Eventable.Type)
    
    /**
     Unregisters the given `receiver` from all `Eventable` Types from the Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    static func removeReceiver(_ receiver: any EventReceiving)
    
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
    
    /**
     Registers an Event Listner Callback for the given `Eventable` Type with the Central Event Listener
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - requester: The Object owning the Callback Method
        - callback: The code to invoke for the given `Eventable` Type
        - forEventType: The `Eventable` Type for which to Register  the Callback
     - Returns: A `UUID` value representing the `token` associated with this Event Callback
     */
    @discardableResult static func addListener<TEvent: Eventable>(_ requester: AnyObject?, _ callback: @escaping TypedEventCallback<TEvent>, forEventType: Eventable.Type, executeOn: ExecuteEventOn, interestedIn: EventListenerInterest, maximumAge: UInt64, customFilter: TypedEventFilterCallback<TEvent>?) -> EventListenerHandling
    
    /**
     Locates and removes the given Listener `token` (if it exists) from the Central Event Listener
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - token: The Token of the Listener you wish to remove
     - Note: Using this method is far slower than if you provide the `typeOf` Parameter to satisfy the more-specific overloaded version of this method
     */
    static func removeListener(_ token: UUID)
    
    /**
     Locates and removes the given Listener `token` (if it exists) from the Central Event Listener
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - token: The Token of the Listener you wish to remove
        - typeOf: The Event Type for which the Listener identified by the given `token` is interested
     */
    static func removeListener(_ token: UUID, typeOf: Eventable.Type)
    
    /**
     Schedule the Event to be dispatched through the Central Queue with the given `priority`
     - Author: Simon J. Stuart
     - Version: 4.2.0
     - Parameters:
        - at: The `DispatchTime` after which to dispatch the Event
        - priority: The `EventPriority` with which to process the Event
     */
    static func scheduleQueue(_ event: Eventable, at: DispatchTime, priority: EventPriority)
    
    /**
     Schedule the Event to be dispatched through the Central Stack with the given `priority`
     - Author: Simon J. Stuart
     - Version: 4.2.0
     - Parameters:
        - at: The `DispatchTime` after which to dispatch the Event
        - priority: The `EventPriority` with which to process the Event
     */
    static func scheduleStack(_ event: Eventable, at: DispatchTime, priority: EventPriority)
}
