//
// EventPool.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 13th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation
import ThreadSafeSwift

/**
 Concrete Implementation for an `EventPool`.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Parameters:
    - TEventThread: The `EventThreadable`-conforming Type to be managed by this `EventPool`
 - Note: Event Pools own and manage all instances of the given `TEventThread` type
 */
open class EventPool<TEventThread: EventThreadable>: EventHandler, EventPooling {
    @ThreadSafeSemaphore public var balancer: EventPoolBalancing
    @ThreadSafeSemaphore public var scaler: EventPoolScaling
    @ThreadSafeSemaphore public var capacity: UInt8
    
    private var eventThreads = [TEventThread]()
    
    struct ThreadContainer {
        weak var thread: (any EventThreadable)?
    }
    @ThreadSafeSemaphore private var pools = [String:[ThreadContainer]]()
    
    public func addReceiver(_ receiver: EventReceiving, forEventType: Eventable.Type) {
        if let eventThread = receiver as? EventThreadable { /// We must cast the `receiver` to `EventThreadable` safely
            let eventTypeName = String(reflecting: forEventType)
            
            // We need to add the Thread into the Pool for this Event Type
            _pools.withLock { pools in
                var bucket = pools[eventTypeName]
                let newBucket = bucket == nil
                if newBucket { bucket = [ThreadContainer]() } /// If there's no Bucket for this Event Type, create one
                
                /// If it's NOT a New Bucket, and the Bucket already contains this Receiver...
                if !newBucket && bucket!.contains(where: { threadContainer in
                    threadContainer.thread != nil && ObjectIdentifier(threadContainer.thread!) == ObjectIdentifier(eventThread)
                }) {
                    return // ... just Return!
                }
                
                /// If we reach here, the Receiver is not already in the Bucket, so let's add it!
                bucket!.append(ThreadContainer(thread: eventThread))
                
                if bucket!.count == 1 { EventCentral.shared.addReceiver(self, forEventType: forEventType) } /// If this is the *first* registered Thread for this Event Type, we need to register with Central Dispatch
                
                pools[eventTypeName] = bucket!
            }
        }
    }
    
    public func removeReceiver(_ receiver: EventReceiving, forEventType: Eventable.Type) {
        if let eventThread = receiver as? EventThreadable { /// We must cast the `receiver` to `EventThreadable` safely
            let eventTypeName = String(reflecting: forEventType)
            
            _pools.withLock { pools in
                var bucket = pools[eventTypeName]
                if bucket == nil { return } /// Can't remove a Receiver if there isn't even a Bucket for hte Event Type
                
                /// Remove any Receivers from this Event-Type Bucket for the given `receiver` instance.
                bucket!.removeAll { threadContainer in
                    threadContainer.thread != nil && ObjectIdentifier(threadContainer.thread!) == ObjectIdentifier(eventThread)
                }
                
                if bucket!.count == 0 { EventCentral.shared.removeReceiver(self, forEventType: forEventType) } /// If there are none left in the Bucket, unregister this `EventPool` from Central Dispatch
                
                pools[eventTypeName] = bucket // Update the Bucket for this Event Type
            }
        }
    }
    
    public func removeReceiver(_ receiver: EventReceiving) {
        if let eventThread = receiver as? EventThreadable { /// We must cast the `receiver` to `EventThreadable` safely
            
            _pools.withLock { pools in
                for (eventTypeName, bucket) in pools { /// Iterate every Event Type
                    var newBucket = bucket // Copy the Bucket
                    newBucket.removeAll { threadContainer in /// Remove any occurences of the given Receiver from the Bucket
                        threadContainer.thread != nil && ObjectIdentifier(threadContainer.thread!) == ObjectIdentifier(eventThread)
                    }
                    
                    if bucket.count == 0 { EventCentral.shared.removeReceiver(self) } /// If there are none left in the Bucket, unregister this `EventPool` from Central Dispatch
                    
                    pools[eventTypeName] = newBucket /// Update the Bucket for this Event Type
                }
            }
        }
    }
    
    internal func scalePool() {
        let scalingResult = scaler.calculateScaling(currentCapacity: capacity, eventThreads: eventThreads, eventsPending: eventCount)
        if !scalingResult.modifyCapacity { return } // If there's no scaling to perform, let's return
        //TODO: Implement Scaling + Culling here
    }
    
    override open func processEvent(_ event: any Eventable, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        let eventTypeName = String(reflecting: type(of: event))
        
        var snapPools = [String:[ThreadContainer]]()
        
        _pools.withLock { pools in
            // We should take this opportunity to remove any nil receivers
            pools[eventTypeName]?.removeAll(where: { threadContainer in
                threadContainer.thread == nil
            })
            snapPools = pools
        }
        
        let bucket = snapPools[eventTypeName]
        if bucket == nil { return } /// No Receivers, so nothing more to do!
        
        /// Now we need to determine the appropriate `EventThread` to receive this `Eventable`
        var bucketThreads = [EventThreadable]()
        for threadContainer in bucket! {
            if threadContainer.thread == nil { continue } //Can't consider this Thread if it doesn't exist!
            bucketThreads.append(threadContainer.thread!)
        }
        let targetThread = balancer.chooseEventThread(eventThreads: bucketThreads)
        
        if targetThread != nil {
            switch dispatchMethod {
            case .stack:
                targetThread!.stackEvent(event, priority: priority)
            case .queue:
                targetThread!.queueEvent(event, priority: priority)
            }
        }

        scalePool()
    }
    
    /**
     Create a new `EventPool`
     - Author: Simon J. Stuart
     - Version: 4.0.0
     - Parameters:
        - capacity: The number of Threads to spawn
        - balancer: The Load Balancer to use (directs `Eventable` instances to the most appropriate `EventThread` at any given time) - Default is `nil`, uses the `EventPoolRoundRobinBalancer` if `nil`
        - scaler: The Scaler to use (increases and/or decreases the number of `EventThread` instances managed by the `EventPool` in response to rules defined by the `scaler` - Default is `nil`, uses the `EventPoolStaticScaler` if `nil`
     */
    public init(
        capacity: UInt8,
        balancer: EventPoolBalancing? = nil,
        scaler: EventPoolScaling? = nil
    ) {
        self.capacity = capacity
        self.balancer = balancer != nil ? balancer! : EventPoolRoundRobinBalancer()
        self.scaler = scaler != nil ? scaler! : EventPoolStaticScaler(initialCapacity: capacity, minimumCapacity: capacity, maximumCapacity: capacity)
        
        super.init()
        // Now we create all of our Event Threads
        var current = 0
        while current < capacity {
            let eventThread = TEventThread(eventPool: self)
            eventThreads.append(eventThread)
            current += 1
        }
    }
}
