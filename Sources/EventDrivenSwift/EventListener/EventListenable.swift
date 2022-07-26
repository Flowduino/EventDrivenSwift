//
// EventListenable.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 11th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Convienience `typealias` used for Event Callbacks
 - Author: Simon J. Stuart
 - Version: 3.0.0
 */
public typealias EventCallback = (_ event: any Eventable, _ priority: EventPriority, _ dispatchTime: DispatchTime) -> ()
public typealias EventFilterCallback = (_ event: any Eventable, _ priority: EventPriority, _ dispatchTime: DispatchTime) -> Bool

/**
 Convienience `typealias` used for Typed Event Callbacks
 - Author: Simon J. Stuart
 - Version: 3.0.0
 */
public typealias TypedEventCallback<TEvent: Any> = (_ event: TEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) -> ()

public enum ExecuteEventOn {
    /**
     Callback will execute on the context of the Requester's own Thread
     - Author: Simon J. Stuart
     - Version: 3.1.0
     */
    case requesterThread
    /**
     Callback will execute on the context of the Listener's Thread
     - Author: Simon J. Stuart
     - Version: 3.1.0
     - Note: You must ensure your Callback (and all resources it uses) are Thread-Safe!
     */
    case listenerThread
    /**
     Callback will execute on the context of an ad-hoc Task
     - Author: Simon J. Stuart
     - Version: 3.1.0
     - Note: You must ensure your Callback (and all resources it uses) are Thread-Safe!
     */
    case taskThread
}
/**
 Provides a simple means of Receiving Events and invoking appropriate Callbacks
 - Author: Simon J. Stuart
 - Version: 3.0.0
 */
public protocol EventListenable: AnyObject, EventReceiving {
    /**
     Registers an Event Callback for the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 5.1.0
     - Parameters:
        - requester: The Object owning the Callback Method
        - callback: The code to invoke for the given `Eventable` Type
        - forEventType: The `Eventable` Type for which to Register  the Callback
        - executeOn: Tells the `EventListenable` whether to execute the Callback on the `requester`'s Thread, or the Listener's.
        - interestedIn: Defines the conditions under which the Listener is interested in an Event (anything outside of the given condition will be ignored by this Listener)
        - maximumAge: If `interestedIn` == `.youngerThan`, this is the number of nanoseconds between the time of dispatch and the moment of processing where the Listener will be interested in the Event. Any Event older will be ignored
     - Returns: A `UUID` value representing the `token` associated with this Event Callback
     */
    @discardableResult func addListener<TEvent: Eventable>(_ requester: AnyObject?, _ callback: @escaping TypedEventCallback<TEvent>, forEventType: Eventable.Type, executeOn: ExecuteEventOn, interestedIn: EventListenerInterest, maximumAge: UInt64, customFilter: TypedEventFilterCallback<TEvent>?) -> EventListenerHandling
    
    /**
     Locates and removes the given Listener `token` (if it exists)
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - token: The Token of the Listener you wish to remove
     - Note: Using this method is far slower than if you provide the `typeOf` Parameter to satisfy the more-specific overloaded version of this method
     */
    func removeListener(_ token: UUID)
    
    /**
     Locates and removes the given Listener `token` (if it exists)
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - token: The Token of the Listener you wish to remove
        - typeOf: The Event Type for which the Listener identified by the given `token` is interested
     */
    func removeListener(_ token: UUID, typeOf: Eventable.Type)
}
