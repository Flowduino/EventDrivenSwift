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
    
    var wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType> { get set }
    
    var owner: AnyObject? { get set }
    
    mutating func unregister()
}

/**
 Abstract Base Type for all `EventThread` Thread Types.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Note: Inherit from this to implement a discrete unit of code designed specifically to operate upon specific `Eventable` types containing information useful to its operation(s)
 */
open class EventThread: EventReceiver, EventThreadable {
    /**
     Property Wrapper to simplify the registration of Event Callbacks in `EventThread`-inheriting types.
     - Author: Simon J. Stuart
     - Version: 4.1.0
     - Note: Any Event Callback implemented this way will be automatically registered for you.
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
        public typealias EventMethodTypedEventCallback<TOwner: EventThread, TEvent: Any> = (_ sender: TOwner, _ event: TEvent, _ priority: EventPriority) -> ()
        
        mutating public func unregister() {
            if token == nil { return }
            if let typedOwner = owner as? TOwner {
                typedOwner.removeEventCallback(token: token!)
            }
        }
        
        private var token: UUID? = nil
        private var lock = DispatchSemaphore(value: 1)
        
        public var wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType> {
            didSet {
                reRegsiterListener()
            }
        }
        
        public var owner: AnyObject? {
            didSet {
                reRegsiterListener()
            }
        }
        
        @inline(__always) private func callback(event: TEventType, priority: EventPriority) {
            if let typedOwner = owner as? TOwner {
                wrappedValue(typedOwner, event, priority)
            }
        }
        
        mutating private func reRegsiterListener() {
            lock.wait()
            if let typedOwner = owner as? TOwner {
                unregister()
                token = typedOwner.addEventCallback(callback, forEventType: TEventType.self)
            }
            lock.signal()
        }
        
        public init(wrappedValue: @escaping EventMethodTypedEventCallback<TOwner, TEventType>) {
            self.wrappedValue = wrappedValue
        }
    }
    
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
    
    /**
     Invoke the appropriate Callback for the given Event
     - Author: Simon J. Stuart
     - Version: 4.1.0
     - Note: Version 4.1.0 adds support for multiple Callbacks per Event Type
     */
    override open func processEvent(_ event: any Eventable, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        let eventTypeName = String(reflecting: type(of: event))
        var callbackContainer: [EventCallbackContainer]? = nil

        _eventCallbacks.withLock { eventCallbacks in
            callbackContainer = eventCallbacks[eventTypeName]
        }

        if callbackContainer == nil { return } // If there is no Callback, we will just return!

        for callback in callbackContainer! {
            callback.callback(event, priority)
        }
    }
    
    /**
     Registers an Event Callback for the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 4.1.0
     - Parameters:
        - callback: The code to invoke for the given `Eventable` Type
        - forEventType: The `Eventable` Type for which to Register  the Callback
     - Returns: A `UUID` representing a unique `token` for this Event Callback. This can be used with `removeEventCallback`
     - Note: Version 4.1.0 adds support for multiple Callbacks per Event Type
     */
    @discardableResult open func addEventCallback<TEvent: Eventable>(_ callback: @escaping TypedEventCallback<TEvent>, forEventType: Eventable.Type) -> UUID {
        let eventTypeName = String(reflecting: forEventType)
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
        
        return callbackContainer!.token
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
            if var child = child.value as? (any ThreadEventMethodContainer) {
                child.owner = self
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
    deinit {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if var child = child.value as? (any ThreadEventMethodContainer) {
                child.unregister()
            }
        }
    }
}
