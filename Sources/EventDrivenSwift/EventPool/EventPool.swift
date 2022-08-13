//
// EventPool.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 13th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Concrete Implementation for an `EventPool`.
 - Author: Simon J. Stuart
 - Version: 3.1.0
 - Parameters:
    - TEventThread: The `EventThreadable`-conforming Type to be managed by this `EventPool`
 - Note: Event Pools own and manage all instances of the given `TEventThread` type
 */
open class EventPool<TEventThread: EventThreadable>: EventHandler, EventPooling {
    
    public func addReceiver(_ receiver: EventReceiving, forEventType: Eventable.Type) {
        
    }
    
    public func removeReceiver(_ receiver: EventReceiving, forEventType: Eventable.Type) {
        
    }
    
    public func removeReceiver(_ receiver: EventReceiving) {
        
    }
}
