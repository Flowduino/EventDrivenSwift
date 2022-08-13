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

/**
 An implementation of `EventHandler` designed to Queue/Stack outbound events, and Dispatch them to all registered `receivers`
 - Author: Simon J. Stuart
 - Version: 1.0.0
 - Note: While you can inherit from and even create instances of `EventDispatcher`, best practice would be to use `EventCentral.shared` as the central Event Dispatcher.
 */
open class EventDispatcher: EventHandler, EventDispatching {
    struct ReceiverContainer {
        weak var receiver: (any EventReceiving)?
    }
    
    /**
    Stores all of the Receivers against the fully-qualified name of the corresponding `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    @ThreadSafeSemaphore private var receivers = [String:[ReceiverContainer]]()
    
    public func addReceiver(_ receiver: any EventReceiving, forEventType: Eventable.Type) {
        let eventTypeName = String(reflecting: forEventType)
        
        _receivers.withLock { receivers in
            var bucket = receivers[eventTypeName]
            let newBucket = bucket == nil
            if newBucket { bucket = [ReceiverContainer]() } /// If there's no Bucket for this Event Type, create one
            
            /// If it's NOT a New Bucket, and the Bucket already contains this Receiver...
            if !newBucket && bucket!.contains(where: { receiverContainer in
                receiverContainer.receiver != nil && ObjectIdentifier(receiverContainer.receiver!) == ObjectIdentifier(receiver)
            }) {
                return // ... just Return!
            }
            
            /// If we reach here, the Receiver is not already in the Bucket, so let's add it!
            bucket!.append(ReceiverContainer(receiver: receiver))
            receivers[eventTypeName] = bucket!
        }
    }
    
    public func removeReceiver(_ receiver: any EventReceiving, forEventType: Eventable.Type) {
        let eventTypeName = String(reflecting: forEventType)
        
        _receivers.withLock { receivers in
            var bucket = receivers[eventTypeName]
            if bucket == nil { return } /// Can't remove a Receiver if there isn't even a Bucket for hte Event Type
            
            /// Remove any Receivers from this Event-Type Bucket for the given `receiver` instance.
            bucket!.removeAll { receiverContainer in
                receiverContainer.receiver != nil && ObjectIdentifier(receiverContainer.receiver!) == ObjectIdentifier(receiver)
            }
        }
    }
    
    public func removeReceiver(_ receiver: any EventReceiving) {
        _receivers.withLock { receivers in
            for (eventTypeName, bucket) in receivers { /// Iterate every Event Type
                var newBucket = bucket // Copy the Bucket
                newBucket.removeAll { receiverContainer in /// Remove any occurences of the given Receiver from the Bucket
                    receiverContainer.receiver != nil && ObjectIdentifier(receiverContainer.receiver!) == ObjectIdentifier(receiver)
                }
                receivers[eventTypeName] = newBucket /// Update the Bucket for this Event Type
            }
        }
    }
       
    /**
     Dispatch the Event to all Subscribed Receivers
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    override internal func processEvent(_ event: any Eventable, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        let eventTypeName = String(reflecting: type(of: event))
        
        var snapReceivers = [String:[ReceiverContainer]]()
        
        _receivers.withLock { receivers in
            // We should take this opportunity to remove any nil receivers
            receivers[eventTypeName]?.removeAll(where: { receiverContainer in
                receiverContainer.receiver == nil
            })
            snapReceivers = receivers
        }
        
        let bucket = snapReceivers[eventTypeName]
        if bucket == nil { return } /// No Receivers, so nothing more to do!
        
        for receiver in bucket! {
            if receiver.receiver == nil { /// If the Recevier is `nil`...
                continue
            }
            
            // so, we have a receiver... let's deal with it!
            switch dispatchMethod {
            case .stack:
                receiver.receiver!.stackEvent(event, priority: priority)
            case .queue:
                receiver.receiver!.queueEvent(event, priority: priority)
            }
        }
    }
}
