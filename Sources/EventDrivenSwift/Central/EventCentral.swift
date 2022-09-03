//
// EventCentral.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
Singleton for the Central Event Dispatcher.
 - Author: Simon J. Stuart
 - Version: 1.0.0
 - Note: This is a Singleton!
 - Note: This is used when invoking the `queue` and `stack` methods of `Eventable`.
 */
final public class EventCentral: EventDispatcher, EventCentralable {
    
    /**
     Singleton Instance of our Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    private static var _shared: EventCentral = EventCentral()
    
    /**
     Returns the Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    @inline(__always) public static var shared: EventDispatching {
        @inline(__always) get {
            return _shared
        }
    }
    
    @inline(__always) public static subscript() -> EventDispatching {
        @inline(__always) get {
            return _shared
        }
    }
    
    @inline(__always) public static func addReceiver(_ receiver: EventReceiving, forEventType: Eventable.Type) {
        _shared.addReceiver(receiver, forEventType: forEventType)
    }
    
    @inline(__always) public static func removeReceiver(_ receiver: EventReceiving, forEventType: Eventable.Type) {
        _shared.removeReceiver(receiver, forEventType: forEventType)
    }
    
    @inline(__always) public static func removeReceiver(_ receiver: EventReceiving) {
        _shared.removeReceiver(receiver)
    }
    
    @inline(__always) public static func queueEvent(_ event: Eventable, priority: EventPriority) {
        _shared.queueEvent(event, priority: priority)
    }
    
    @inline(__always) public static func stackEvent(_ event: Eventable, priority: EventPriority) {
        _shared.stackEvent(event, priority: priority)
    }
    
    @inline(__always) public static var eventCount: Int {
        get {
            return _shared.eventCount
        }
    }
       
    private var _eventListener: EventListenable?
    internal var eventListener: EventListenable {
        get {
            if _eventListener == nil { _eventListener = EventListener() }
            return _eventListener!
        }
    }
    
    @discardableResult @inline(__always) public static func addListener<TEvent>(_ requester: AnyObject?, _ callback: @escaping TypedEventCallback<TEvent>, forEventType: Eventable.Type, executeOn: ExecuteEventOn = .requesterThread, interestedIn: EventListenerInterest = .all, maximumAge: UInt64 = 0, customFilter: TypedEventFilterCallback<TEvent>? = nil) -> EventListenerHandling where TEvent : Eventable {
        return _shared.eventListener.addListener(requester, callback, forEventType: forEventType, executeOn: executeOn, interestedIn: interestedIn, maximumAge: maximumAge, customFilter: customFilter)
    }
    
    @inline(__always) public static func removeListener(_ token: UUID) {
        _shared.eventListener.removeListener(token)
    }
    
    @inline(__always) public static func removeListener(_ token: UUID, typeOf: Eventable.Type) {
        _shared.eventListener.removeListener(token, typeOf: typeOf)
    }
    
    @inline(__always) public static func scheduleQueue(_ event: Eventable, at: DispatchTime, priority: EventPriority) {
        _shared.scheduleQueue(event, at: at, priority: priority)
    }
    
    @inline(__always) public static func scheduleStack(_ event: Eventable, at: DispatchTime, priority: EventPriority) {
        _shared.scheduleStack(event, at: at, priority: priority)
    }
    
    /// This just makes it so that your code cannot initialise instances of `EventCentral`. It's a Singleton!
    override private init() {}
}
