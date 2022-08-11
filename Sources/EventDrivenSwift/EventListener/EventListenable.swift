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
typealias EventCallback = (_ event: any Eventable, _ priority: EventPriority) -> ()

/**
 Convienience `typealias` used for Typed Event Callbacks
 - Author: Simon J. Stuart
 - Version: 3.0.0
 */
public typealias TypedEventCallback<TEvent: Any> = (_ event: TEvent, _ priority: EventPriority) -> ()

/**
 Provides a simple means of Receiving Events and invoking appropriate Callbacks
 - Author: Simon J. Stuart
 - Version: 3.0.0
 */
public protocol EventListenable: AnyObject, EventReceivable {
    /**
     Registers an Event Callback for the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - requester: The Object owning the Callback Method
        - callback: The code to invoke for the given `Eventable` Type
        - forEventType: The `Eventable` Type for which to Register  the Callback
     - Returns: A `UUID` value representing the `token` associated with this Event Callback
     */
    @discardableResult func addListener<TEvent: Eventable>(_ requester: AnyObject, _ callback: @escaping TypedEventCallback<TEvent>, forEventType: Eventable.Type) -> UUID
    
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
