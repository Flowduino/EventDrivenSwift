//
// EventThread.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation
import ThreadSafeSwift
import Observable

/**
 Abstract Base Type for all `EventThread` Thread Types.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Note: Inherit from this to implement a discrete unit of code designed specifically to operate upon specific `Eventable` types containing information useful to its operation(s)
 */
open class EventThread: EventReceiver, EventThreadable {
    weak var eventPool: EventPooling?
    
    /**
     Map of `Eventable` qualified Type Names against `EventCallback` methods.
     - Author: Simon J. Stuart
     - Version: 4.0.0
     - Note: We use the Qualified Type Name as the Key because Types are not Hashable in Swift
     */
    @ThreadSafeSemaphore private var eventCallbacks = [String:EventCallback]()
    
    /**
     Invoke the appropriate Callback for the given Event
     - Author: Simon J. Stuart
     - Version: 4.0.0
     */
    override open func processEvent(_ event: any Eventable, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
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
     - Version: 4.0.0
     - Parameters:
        - callback: The code to invoke for the given `Eventable` Type
        - forEventType: The `Eventable` Type for which to Register  the Callback
     */
    open func addEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEventType: Eventable.Type) {
        let eventTypeName = String(reflecting: forEventType)
        
        _eventCallbacks.withLock { eventCallbacks in
            eventCallbacks[eventTypeName] = { event, priority in
                self.callTypedEventCallback(callback, forEvent: event, priority: priority)
            }
        }
        
        let dispatcher: EventDispatching = eventPool == nil ? EventCentral.shared : eventPool!
        
        dispatcher.addReceiver(self, forEventType: forEventType)
    }
    
    /**
     Performs a Transparent Type Test, Type Cast, and Method Call via the `callback` Closure.
     - Author: Simon J. Stuart
     - Version: 4.0.0
     - Parameters:
        - callback: The code (Closure or Callback Method) to execute for the given `forEvent`, typed generically using `TEvent`
        - forEvent: The instance of the `Eventable` type to be processed
        - priority: The `EventPriority` with which the `forEvent` was dispatched
     */
    open func callTypedEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEvent: Eventable, priority: EventPriority) {
        if let typedEvent = forEvent as? TEvent {
            callback(typedEvent, priority)
        }
    }
    
    /**
     Removes an Event Callback for the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 4.0.2
     - Parameters:
        - forEventType: The `Eventable` Type for which to Remove the Callback
     */
    open func removeEventCallback(forEventType: Eventable.Type) {
        let eventTypeName = String(reflecting: forEventType)
        
        _eventCallbacks.withLock { eventCallbacks in
            eventCallbacks.removeValue(forKey: eventTypeName)
        }
        
        let dispatcher: EventDispatching = eventPool == nil ? EventCentral.shared : eventPool!
        
        dispatcher.removeReceiver(self, forEventType: forEventType)
    }
    
    /**
     Override this to register your Event Listeners/Callbacks
     - Author: Simon J. Stuart
     - Version: 4.0.0
     */
    open func registerEventListeners() {
        // No default implementation
    }
    
    /**
     Initializes an `EventReciever` decendant and invokes `registerEventListeners()` to register your Event Listeners/Callbacks within your `EventThread` type.
     - Author: Simon J. Stuart
     - Version: 4.0.0
     - Parameters:
        - eventPool: Reference to the `EventPool` which owns this `EventThread` (default is `nil` which means there is no `EventPooling` for this Thread)
     */
    required public init(eventPool: EventPooling? = nil) {
        self.eventPool = eventPool
        super.init()
        registerEventListeners()
    }
    
    override private init() {}
}
