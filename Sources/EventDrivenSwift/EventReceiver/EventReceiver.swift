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

/**
 Abstract Base Type for all `EventRecevier` Thread Types.
 - Author: Simon J. Stuart
 - Version: 1.0.0
 - Note: Inherit from this to implement a discrete unit of code designed specifically to operate upon specific `Eventable` types containing information useful to its operation(s)
 */
open class EventReceiver: EventHandler, EventReceivable {
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
    @ThreadSafeSemaphore private var eventCallbacks = [String:EventCallback]()
    
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
    
    /**
     Performs a Transparent Type Test, Type Cast, and Method Call via the `callback` Closure.
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - callback: The code (Closure or Callback Method) to execute for the given `forEvent`, typed generically using `TEvent`
        - forEvent: The instance of the `Eventable` type to be processed
        - priority: The `EventPriority` with which the `forEvent` was dispatched
     */
    internal func callTypedEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEvent: Eventable, priority: EventPriority) {
        if let typedEvent = forEvent as? TEvent {
            callback(typedEvent, priority)
        }
    }
    
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
    
    /**
     Initializes an `EventReciever` decendant and invokes `registerEventListeners()` to register your Event Listeners within your `EventReceiver` type.
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    override init() {
        super.init()
        registerEventListeners()
    }
}
