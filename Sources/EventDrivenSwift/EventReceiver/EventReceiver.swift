//
// EventReceiver.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation
import ThreadSafeSwift
import Observable

public class EventReceiver: EventHandler, EventReceivable {
    typealias EventCallback = (_ event: any Eventable, _ priority: EventPriority) -> ()
    
    @ThreadSafeSemaphore private var eventCallbacks = [String:EventCallback]() //TODO: Make this a Revolving Door collection!
    
    /**
     Invoke the appropriate Callback for the given Event
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    override internal func processEvent(_ event: any Eventable, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        let eventTypeName = String(reflecting: type(of: event))
        var callback: EventCallback? = nil
        
        _eventCallbacks.withLock { eventCallbacks in
            callback = eventCallbacks[eventTypeName]
        }
        
        if callback == nil { return } // If there is no Callback, we will just return!
        
        callback!(event, priority)
    }
    
    internal func addEventCallback(_ callback: @escaping EventCallback, forEventType: Eventable.Type) {
        let eventTypeName = String(reflecting: forEventType)
        
        _eventCallbacks.withLock { eventCallbacks in
            eventCallbacks[eventTypeName] = callback
        }
        
        /// We automatically register the Listener with the Central Event Dispatcher
        EventCentral.shared.addListener(self, forEventType: forEventType)
    }
    
    internal func removeEventCallback(forEventType: any Eventable) {
        let eventTypeName = String(reflecting: forEventType)
        
        _eventCallbacks.withLock { eventCallbacks in
            eventCallbacks.removeValue(forKey: eventTypeName)
        }
    }
    
    /**
     Override this to register your Event Callbacks and Listeners
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    internal func registerEventListeners() {
        // No default implementation
    }
    
    override init() {
        super.init()
        registerEventListeners()
    }
}
