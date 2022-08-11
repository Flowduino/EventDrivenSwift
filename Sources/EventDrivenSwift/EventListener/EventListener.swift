//
// EventListener.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 11th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation
import ThreadSafeSwift
import Observable

/**
 Abstract Base Type for all `SimpleEventRecevier` Thread Types.
 - Author: Simon J. Stuart
 - Version: 3.0.0
 - Note: Inherit from this to implement a discrete unit of code designed specifically to operate upon specific `Eventable` types containing information useful to its operation(s)
 */
open class EventListener: EventHandler, EventListenable {
    /**
     Container for Event Listeners
     - Author: Simon J. Stuart
     - Version: 3.0.0
     */
    public struct EventListenerContainer {
        var token: UUID = UUID() // Randomly-generated
        weak var requester: AnyObject?
        var callback: EventCallback
        var dispatchQueue: DispatchQueue?
    }
    
    /**
     Map of `Eventable` qualified Type Names against `EventListenerContainer`s.
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Note: We use the Qualified Type Name as the Key because Types are not Hashable in Swift
     */
    @ThreadSafeSemaphore private var eventListeners = [String:[EventListenerContainer]]()
    
    /**
     Invoke the appropriate Listener Callback for the given Event
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - event: The Event to be Processed
        - dispatchMethod: The Means by which the Event was Dispatched
        - priority: The Priority given to the Event at the point of Dispatch
     */
    override internal func processEvent(_ event: any Eventable, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        let eventTypeName = String(reflecting: type(of: event))
        var listeners: [EventListenerContainer]? = nil

        _eventListeners.withLock { eventListeners in
            listeners = eventListeners[eventTypeName]
        }

        if listeners == nil { return } // If there is no Callback, we will just return!

        for listener in listeners! {
            if listener.requester == nil { // If the Requester no longer exists...
                removeListener(listener.token, typeOf: type(of: event)) // ... Unregister this Listener
                continue // Skip this one
            }
            // Execute the Callback on the Listener's own Dispatch Queue
            let dispatchQueue = listener.dispatchQueue ?? DispatchQueue.main
            dispatchQueue.async {
                listener.callback(event, priority)
            }
        }
    }
    
    public func addListener<TEvent: Eventable>(_ requester: AnyObject, _ callback: @escaping TypedEventCallback<TEvent>, forEventType: Eventable.Type) -> UUID {
        let eventTypeName = String(reflecting: forEventType)
        let method: EventCallback = { event, priority in
            self.callTypedEventCallback(callback, forEvent: event, priority: priority)
        }
        let eventListenerContainer = EventListenerContainer(requester: requester, callback: method, dispatchQueue: OperationQueue.current?.underlyingQueue)
        _eventListeners.withLock { eventCallbacks in
            var bucket = eventCallbacks[eventTypeName]
            if bucket == nil { bucket = [EventListenerContainer]() } // Create a new bucket if there isn't already one!
            bucket!.append(eventListenerContainer)
            eventCallbacks[eventTypeName] = bucket!
        }
        
        /// We automatically register the Listener with the Central Event Dispatcher
        EventCentral.shared.addReceiver(self, forEventType: forEventType)
        return eventListenerContainer.token
    }
    
    public func removeListener(_ token: UUID) {
        var listeners: [String:[EventListenerContainer]]? = nil

        _eventListeners.withLock { eventListeners in
            listeners = eventListeners
        }
        
        for eventTypeName in listeners!.keys {
            removeListener(token, eventTypeName: eventTypeName)
        }
    }
    
    public func removeListener(_ token: UUID, typeOf: Eventable.Type) {
        let eventTypeName = String(reflecting: typeOf)
        
        removeListener(token, eventTypeName: eventTypeName)
    }
    
    /**
     Physically locates and removes the given `token` from the collection of Listeners if it exists.
     - Author: Simon J. Stuart
     - Version: 3.0.0
     - Parameters:
        - token: The Token of the Listener you wish to remove
        - eventTypeName: The Event Type Name for which the Listener identified by the given `token` is interested
     */
    @inline(__always) internal func removeListener(_ token: UUID, eventTypeName: String) {
        _eventListeners.withLock { eventListeners in
            var bucket = eventListeners[eventTypeName]
            if bucket == nil { return } // Proceed no further if there is no "bucket" for this Event Type
            
            bucket!.removeAll { eventCallbackContainer in // Remove the eventCallbackContainer where the `token` matches
                eventCallbackContainer.token == token
            }
            
            if bucket!.isEmpty { // If there's nothing in the bucket...
                eventListeners.removeValue(forKey: eventTypeName) // ... then we might as well remove it!
                return
            }
            
            eventListeners[eventTypeName] = bucket // If the bucket is not empty, let's put the updated version back.
        }
    }
    
    /**
     Performs a Transparent Type Test, Type Cast, and Method Call via the `callback` Closure.
     - Author: Simon J. Stuart
     - Version: 3.0.0
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
     Initializes an `EventListener`
     - Author: Simon J. Stuart
     - Version: 3.0.0
     */
    public override init() {
        super.init()
    }
}
