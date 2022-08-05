//
// EventCentral.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
Singleton for the Central Event Handler.
 - Author: Simon J. Stuart
 - Version: 1.0.0
 to access the Central Event Handler.
 - Note: This is a Singleton!
 - Note: This is used when invoking the `queue` and `stack` methods of `Eventable`.
 */
final public class EventCentral: EventDispatcher {
    private static var _shared: EventDispatcher = EventCentral()
    
    public static var shared: EventDispatchable {
        get {
            return _shared
        }
    }
    
    override private init() {}
    
    
}
