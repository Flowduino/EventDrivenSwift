//
// EventListening.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Apply `EventListening` to any `Class` intent on listening for `Eventable`s to register `@EventMethod`-decorated (immutable) Listeners via Reflection.
 - Author: Simon J. Stuart
 - Version: 4.1.0
 */
public protocol EventListening: AnyObject {
    /**
     Invoke this method to automatically register any Event Listener callback bearing the `@EventMethod` wrapper.
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
    func registerListeners()
}

/**
 Universal implementations to automatically Register and Unregister `@EventMethod`-decorated Event Listener Callbacks using Reflection
 - Author: Simon J. Stuart
 - Version: 4.1.0
 */
public extension EventListening {
    func registerListeners() {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if var child = child.value as? (any EventMethodContainer) {
                child.prepare(owner: self)
            }
        }
    }
}
