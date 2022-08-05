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
    /**
     Convienience `typealias` used for Event Callbacks
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    typealias EventCallback = (_ event: any Eventable, _ priority: EventPriority) -> ()
    
    /**
     Convienience `typealias` used for Typed Event Callbacks
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    typealias TypedEventCallback<TEvent: Any> = (_ event: TEvent, _ priority: EventPriority) -> ()
    
    /**
     Map of `Eventable` qualified Type Names against `EventCallback` methods.
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Note: We use the Qualified Type Name as the Key because Types are not Hashable in Swift
     */
    @ThreadSafeSemaphore private var eventCallbacks = [String:EventCallback]() //TODO: Make this a Revolving Door collection!
    
//    @ThreadSafeSemaphore private var typedEventCallbacks = [String:Any]() //TODO: Find an implementation that works for strong-typed Event Callbacks (P.S. limitations of Swift Generics are very annoying!)
    
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
    
    /**
     Registers an Event Callback for the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - callback: The code to invoke for the given `Eventable` Type
        - forEventType: The `Eventable` Type for which to Register  the Callback
     */
    internal func addEventCallback(_ callback: @escaping EventCallback, forEventType: Eventable.Type) {
        let eventTypeName = String(reflecting: forEventType)
        
        _eventCallbacks.withLock { eventCallbacks in
            eventCallbacks[eventTypeName] = callback
        }
        
        /// We automatically register the Listener with the Central Event Dispatcher
        EventCentral.shared.addListener(self, forEventType: forEventType)
    }
    
    internal func callTypedEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEvent: Eventable, priority: EventPriority) {
        if let typedEvent = forEvent as? TEvent {
            callback(typedEvent, priority)
        }
    }
    
    //TODO: Find an implementation that works for strong-typed Event Callbacks (P.S. limitations of Swift Generics are very annoying!)
//    internal func addEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEventType: Eventable.Type) {
//        let eventTypeName = String(reflecting: forEventType)
//
//        _typedEventCallbacks.withLock { typedEventCallbacks in
//            typedEventCallbacks[eventTypeName] = callback
//        }
//
//        /// We automatically register the Listener with the Central Event Dispatcher
//        EventCentral.shared.addListener(self, forEventType: forEventType)
//    }
    
    /**
     Removes an Event Callback for the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - forEventType: The `Eventable` Type for which to Remove the Callback
     */
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
