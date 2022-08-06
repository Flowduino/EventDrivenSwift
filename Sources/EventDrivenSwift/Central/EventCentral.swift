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
    private static var _shared: EventDispatchable = EventCentral()
    
    /**
     Returns the Central Event Dispatcher
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    @inline(__always) public static var shared: EventDispatchable {
        get {
            return _shared
        }
    }
    
    @inline(__always) public static subscript() -> EventDispatchable {
        get {
            return _shared
        }
    }
    
    /// This just makes it so that your code cannot initialise instances of `EventCentral`. It's a Singleton!
    override private init() {}
    
    @inline(__always) public static func addListener(_ listener: EventReceivable, forEventType: Eventable.Type) {
        _shared.addListener(listener, forEventType: forEventType)
    }
    
    @inline(__always) public static func removeListener(_ listener: EventReceivable, forEventType: Eventable.Type) {
        _shared.removeListener(listener, forEventType: forEventType)
    }
    
    @inline(__always) public static func removeListener(_ listener: EventReceivable) {
        _shared.removeListener(listener)
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
}
