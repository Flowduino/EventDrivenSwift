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
    
    /**
     Schedule the Event to be dispatched through the Central Queue with the given `priority`
     - Author: Simon J. Stuart
     - Version: 4.2.0
     - Parameters:
        - at: The `DispatchTime` after which to dispatch the Event
        - priority: The `EventPriority` with which to process the Event
     */
    func scheduleQueue(at: DispatchTime, priority: EventPriority)
    
    /**
     Schedule the Event to be dispatched through the Central Stack with the given `priority`
     - Author: Simon J. Stuart
     - Version: 4.2.0
     - Parameters:
        - at: The `DispatchTime` after which to dispatch the Event
        - priority: The `EventPriority` with which to process the Event
     */
    func scheduleStack(at: DispatchTime, priority: EventPriority)
    
    /**
     Registers an Event Listner Callback for the given `Eventable` Type with the Central Event Listener
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - requester: The Object owning the Callback Method
        - callback: The code to invoke for the given `Eventable` Type
     - Returns: A `UUID` value representing the `token` associated with this Event Callback
     */
    @discardableResult static func addListener<TEvent: Eventable>(_ requester: AnyObject?, _ callback: @escaping TypedEventCallback<TEvent>, executeOn: ExecuteEventOn, interestedIn: EventListenerInterest, maximumAge: UInt64) -> EventListenerHandling
    
    /**
     Locates and removes the given Listener `token` (if it exists) from the Central Event Listener
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - token: The Token of the Listener you wish to remove
     */
    static func removeListener(_ token: UUID)
    
    /**
     Returns the Fully-Qualified Type Name for this Eventable Type
     - Author: Simon J. Stuart
     - Version: 4.3.0
     */
    func getEventTypeName() -> String
    
    /**
     Returns the Fully-Qualified Type Name for this Eventable Type
     - Author: Simon J. Stuart
     - Version: 4.3.0
     */
    static func getEventTypeName() -> String
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
    @inline(__always) public func queue(priority: EventPriority = .normal) {
        EventCentral.queueEvent(self, priority: priority)
    }
    
    @inline(__always) public func stack(priority: EventPriority = .normal) {
        EventCentral.stackEvent(self, priority: priority)
    }
    
    @inline(__always) public func scheduleQueue(at: DispatchTime, priority: EventPriority = .normal) {
        EventCentral.scheduleQueue(self, at: at, priority: priority)
    }
    
    @inline(__always) public func scheduleStack(at: DispatchTime, priority: EventPriority = .normal) {
        EventCentral.scheduleStack(self, at: at, priority: priority)
    }
    
    @discardableResult static public func addListener<TEvent: Eventable>(_ requester: AnyObject?, _ callback: @escaping TypedEventCallback<TEvent>, executeOn: ExecuteEventOn = .requesterThread, interestedIn: EventListenerInterest = .all, maximumAge: UInt64 = 0) -> EventListenerHandling {
        return EventCentral.addListener(requester, callback, forEventType: Self.self, executeOn: executeOn, interestedIn: interestedIn, maximumAge: maximumAge)
    }
       
    public static func removeListener(_ token: UUID) {
        EventCentral.removeListener(token, typeOf: Self.self)
    }
}

/**
 Extension to provide central access to Event Type Names
 - Author: Simon J. Stuart
 - Version: 4.3.0
 */
extension Eventable {
    @inline(__always) public func getEventTypeName() -> String {
        return String(reflecting: type(of: self))
    }
    
    @inline(__always) public static func getEventTypeName() -> String {
        return String(reflecting: self)
    }
}
