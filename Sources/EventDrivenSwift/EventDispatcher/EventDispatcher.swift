//
// EventDispatcher.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation
import ThreadSafeSwift
import Observable

public class EventDispatcher: EventHandler, EventDispatchable {   
    struct ListenerContainer {
        weak var listener: (any EventReceivable)?
    }
    
    /**
    Stores all of the Listeners against the fully-qualified name of the corresponding `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    @ThreadSafeSemaphore private var listeners = [String:[ListenerContainer]]() //TODO: Make this a Revolving Door collection!
    
    public func addListener(_ listener: any EventReceivable, forEventType: Eventable.Type) {
        let eventTypeName = String(reflecting: forEventType)
        
        _listeners.withLock { listeners in
            var bucket = listeners[eventTypeName]
            let newBucket = bucket == nil
            if newBucket { bucket = [ListenerContainer]() } /// If there's no Bucket for this Event Type, create one
            
            /// If it's NOT a New Bucket, and the Bucket already contains this Listener...
            if !newBucket && bucket!.contains(where: { listenerContainer in
                listenerContainer.listener != nil && ObjectIdentifier(listenerContainer.listener!) == ObjectIdentifier(listener)
            }) {
                return // ... just Return!
            }
            
            /// If we reach here, the Listener is not already in the Bucket, so let's add it!
            bucket!.append(ListenerContainer(listener: listener))
            listeners[eventTypeName] = bucket!
        }
    }
    
    public func removeListener(_ listener: any EventReceivable, forEventType: Eventable.Type) {
        let eventTypeName = String(reflecting: forEventType)
        
        _listeners.withLock { listeners in
            var bucket = listeners[eventTypeName]
            if bucket == nil { return } /// Can't remove a Listener if there isn't even a Bucket for hte Event Type
            
            /// Remove any Listeners from this Event-Type Bucket for the given `listener` instance.
            bucket!.removeAll { listenerContainer in
                listenerContainer.listener != nil && ObjectIdentifier(listenerContainer.listener!) == ObjectIdentifier(listener)
            }
        }
    }
    
    public func removeListener(_ listener: any EventReceivable) {
        _listeners.withLock { listeners in
            for (eventTypeName, bucket) in listeners { /// Iterate every Event Type
                var newBucket = bucket // Copy the Bucket
                newBucket.removeAll { listenerContainer in /// Remove any occurences of the given Listener from the Bucket
                    listenerContainer.listener != nil && ObjectIdentifier(listenerContainer.listener!) == ObjectIdentifier(listener)
                }
                listeners[eventTypeName] = newBucket /// Update the Bucket for this Event Type
            }
        }
    }
       
    /**
     Dispatch the Event to all Subscribed Listeners
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    override internal func processEvent(_ event: any Eventable, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        let eventTypeName = String(reflecting: type(of: event))
        
        _listeners.withLock { listeners in
            let bucket = listeners[eventTypeName]
            if bucket == nil { return } /// No Listeners, so nothing more to do!
            
            var newBucket: [ListenerContainer]? = nil
            
            for listener in bucket! {
                if listener.listener == nil { /// If the Listener is `nil`...
                    if newBucket != nil { continue } /// ...If we've already removed all `nil` values, move on
                    ///... otherwise, remove the Listener from this bucket
                    newBucket = bucket
                    newBucket?.removeAll(where: { listenerContainer in
                        listenerContainer.listener == nil
                    })
                    continue
                }
                
                // so, we have a listener... let's deal with it!
                switch dispatchMethod {
                case .stack:
                    listener.listener!.stackEvent(event, priority: priority)
                case .queue:
                    listener.listener!.queueEvent(event, priority: priority)
                }
            }
            if newBucket != nil { listeners[eventTypeName] = newBucket }
        }
    }
}
