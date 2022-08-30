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
 Any Property wrapped with `EventMethod` will automatically conform to `ThreadEventMethodContainer`
 - Author: Simon J. Stuart
 - Version: 4.1.0
 - Note: This is used to conformity-test decorated `var`s to automatically register Event Listeners
 */
public protocol ThreadEventMethodContainer {
    associatedtype TEventType: Eventable
    associatedtype TOwner: EventThread
    
    var wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType>? { get set }
    
    mutating func prepare(owner: AnyObject)
}

/**
 Abstract Base Type for all `EventThread` Thread Types.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Note: Inherit from this to implement a discrete unit of code designed specifically to operate upon specific `Eventable` types containing information useful to its operation(s)
 */
open class EventThread: EventReceiver, EventThreadable {
    public typealias EventMethodTypedEventCallback<TOwner: EventThread, TEvent: Any> = (_ sender: TOwner, _ event: TEvent, _ priority: EventPriority) -> ()
    
    /**
     Property Wrapper to simplify the registration of Event Callbacks in `EventThread`-inheriting types.
     - Author: Simon J. Stuart
     - Version: 4.1.0
     - Note: Any Event Callback implemented this way will be automatically registered for you.
     - Note: You cannot unregister or modify the Callback in any way. They are immutable.
     ````
     @EventMethod<MyEventThreadType, MyEventType>
     private var onMyEvent = {
        (self, event: MyEventType, priority: EventPriority) in
            /// Do something with `MyEventType` via its `event` reference here
     }
     ````
     */
    @propertyWrapper
    public struct EventMethod<TOwner: EventThread, TEventType: Eventable>: ThreadEventMethodContainer {
        public var wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType>?
        
        private weak var owner: AnyObject? = nil
        
        @inline(__always) private func callback(event: TEventType, priority: EventPriority) {
            if let typedOwner = owner as? TOwner {
                wrappedValue?(typedOwner, event, priority)
            }
        }

        public init(wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType>?) {
            self.wrappedValue = wrappedValue
        }
        
        mutating public func prepare(owner: AnyObject) {
            if let typedOwner = owner as? TOwner {
                self.owner = owner
                typedOwner.addEventCallback(callback, forEventType: TEventType.self)
            }
        }
    }
    
    open class EventCallbackHandler {
        /**
         `weak` reference to the `EventThread` against which this Callback is registered.
         - Author: Simon J. Stuart
         - Version: 4.1.0
         */
        private weak var eventThread: EventThread?
        
        /**
         This is the Token Key assoicated with your Callback
         - Author: Simon J. Stuart
         - Version: 4.1.0
         */
        private var token: UUID
        
        public func remove() {
            eventThread?.removeEventCallback(token: token)
        }
        
        public init(eventThreadable: EventThread, token: UUID) {
            self.eventThread = eventThreadable
            self.token = token
        }
    }
    
    /**
     If this `EventThread` was spawned by an `EventPool`, this is a `weak` reference to that `EventPool`.
     */
    weak var eventPool: EventPooling?
    
    /**
     Callback Container to associate a unique `token` with each `callback` (so we can register multiple callbacks per Event Type if we want to)
     - Author: Simon J. Stuart
     - Version: 4.1.0
     */
    public struct EventCallbackContainer {
        var token: UUID = UUID() // Randomly-generated
        var callback: EventCallback
        var eventType: Eventable.Type
    }
    
    /**
     Map of `Eventable` qualified Type Names against `EventCallbackContainer` objects.
     - Author: Simon J. Stuart
     - Version: 4.0.0
     - Note: We use the Qualified Type Name as the Key because Types are not Hashable in Swift
     */
    @ThreadSafeSemaphore private var eventCallbacks = [String:[EventCallbackContainer]]()
    @ThreadSafeSemaphore private var tokens = [UUID]()
    
    /**
     Invoke the appropriate Callback for the given Event
     - Author: Simon J. Stuart
     - Version: 4.1.0
     - Note: Version 4.1.0 adds support for multiple Callbacks per Event Type
     */
    override open func processEvent(_ event: EventDispatchContainer, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        let eventTypeName = event.event.getEventTypeName()
        var callbackContainer: [EventCallbackContainer]? = nil

        _eventCallbacks.withLock { eventCallbacks in
            callbackContainer = eventCallbacks[eventTypeName]
        }

        if callbackContainer == nil { return } // If there is no Callback, we will just return!

        for callback in callbackContainer! {
            callback.callback(event.event, priority)
        }
    }
    
    /**
     Registers an Event Callback for the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 4.1.0
     - Parameters:
        - callback: The code to invoke for the given `Eventable` Type
        - forEventType: The `Eventable` Type for which to Register  the Callback
     - Returns: An `EventCallbackHandler` so that you can safely remove the Callback whenever you require.
     - Note: Version 4.1.0 adds support for multiple Callbacks per Event Type
     */
    @discardableResult open func addEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEventType: Eventable.Type) -> EventCallbackHandler {
        let eventTypeName = forEventType.getEventTypeName()
        var callbackContainer: EventCallbackContainer? = nil
        
        _eventCallbacks.withLock { eventCallbacks in
            var bucket = eventCallbacks[eventTypeName]
            if bucket == nil {
                bucket = [EventCallbackContainer]()
            }
            
            callbackContainer = EventCallbackContainer(callback: { event, priority in
                self.callTypedEventCallback(callback, forEvent: event, priority: priority)
            }, eventType: forEventType)
            
            bucket!.append(callbackContainer!)
            
            eventCallbacks[eventTypeName] = bucket
        }
        
        let dispatcher: EventDispatching = eventPool == nil ? EventCentral.shared : eventPool!
        
        dispatcher.addReceiver(self, forEventType: forEventType)
        
        _tokens.withLock { tokens in
            tokens.append(callbackContainer!.token)
        }
        
        return EventCallbackHandler(eventThreadable: self, token: callbackContainer!.token)
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
    @inline(__always) open func callTypedEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEvent: Eventable, priority: EventPriority) {
        if let typedEvent = forEvent as? TEvent {
            callback(typedEvent, priority)
        }
    }
    
    /**
     Removes an Event Callback for the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 4.0.2
     - Parameters:
        - token: The `token` assigned to the Callback when it was registered.
     - Note: Version 4.1.0 adds support for multiple Callbacks per Event Type
     */
    open func removeEventCallback(token: UUID) {
        _eventCallbacks.withLock { eventCallbacks in
            for key in eventCallbacks.keys {
                var bucket = eventCallbacks[key]
                // Get the container if it is here
                let container = bucket?.first(where: { container in
                    container.token == token
                })
                
                if container == nil { continue } // If there is no container with this Token, skip the rest!
                
                bucket!.removeAll { container in // Remove any Containers with this Token
                    container.token == token
                }
                eventCallbacks[key] = bucket
                
                if bucket!.count == 0 { // If there are no more listeners in the Bucket for this Event Type...
                    let dispatcher: EventDispatching = self.eventPool == nil ? EventCentral.shared : self.eventPool!
                    dispatcher.removeReceiver(self, forEventType: container!.eventType) // ...Remove the Listener registration for this Event Type for this Thread
                }
                
                return // If we've gotten here, there's no reason to go further!
            }
        }
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
     Automatically registers any Event Callbacks decorated with `@EventMethod`
     - Author: Simon J. Stuart
     - Version: 4.1.0
     */
    internal func registerWrappedListeners() {
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            if var typedValue = child.value as? (any ThreadEventMethodContainer) {
                typedValue.prepare(owner: self)
            }
        }
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
        registerWrappedListeners()
        registerEventListeners()
    }
    
    override private init() {}
    
    /**
     Automatically unregisters every Listener on destruction of the Thread
     - Author: Simon J. Stuart
     - Version: 4.1.0
     */
    open func unregisterWrappedListeners() {
        var snapTokens = [UUID]()
        _tokens.withLock { tokens in
            snapTokens = tokens
            tokens.removeAll()
        }
        for token in snapTokens {
            removeEventCallback(token: token)
        }
    }
    
    deinit {
        unregisterWrappedListeners()
    }
}
