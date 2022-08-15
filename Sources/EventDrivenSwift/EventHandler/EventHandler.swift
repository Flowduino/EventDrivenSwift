//
// EventHandler.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation
import ThreadSafeSwift
import Observable

/**
 Abstract Base Type for all `EventHandler` Thread Types.
 - Author: Simon J. Stuart
 - Version: 1.0.0
 - Note: This is the Common Base Type for `EventDispatcher` and `EventReceiver` base types
 - Note: This class should not be instantiated directly
 - Note: `EventDispatcher` inherits from this
 - Note: `EventReceiver` inherits from this
 
 */
open class EventHandler: ObservableThread, EventHandling {
    /**
    A Map of `EventPriority` against an Array of `Eventable` in that corresponding Queue
     - Author: Simon J. Stuart
     - Version: 1.0.0
    */
    @ThreadSafeSemaphore internal var queues = [EventPriority:[any Eventable]]()
    
    /**
    A Map of `EventPriority` against an Array of `Eventable` in that corresponding Stack
     - Author: Simon J. Stuart
     - Version: 1.0.0
    */
    @ThreadSafeSemaphore internal var stacks = [EventPriority:[any Eventable]]()
    
    /**
     The number of Events currently pending in the Queue and Stack combined
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Returns: The number of Events currently pending in the Queue and Stack combined
     - Note: The result can be out of date by the time it is returned.
     */
    public var eventCount: Int {
        get {
            var stackCount: Int = 0
            var queueCount: Int = 0
            
            var snapStacks = [EventPriority:[any Eventable]]() // Snapshot of the current Stacks
            var snapQueues = [EventPriority:[any Eventable]]() // Snapshot of hte current Queues
            
            _stacks.withLock { stacks in // With the Lock
                snapStacks = stacks // Grab a Snapshot
            } // Lock releases
            
            _queues.withLock { queues in // With the Lock
                snapQueues = queues // Grab a Snapshot
            } // Lock releases
            
            for stack in snapStacks.values { // Iterate Stacks
                stackCount += stack.count // Increment Count
            }
            
            for queue in snapQueues.values { // Iterate Queues
                queueCount += queue.count // Increment Count
            }
            
            return stackCount + queueCount // Return the sum of Stack and Queue counts (total Event Count)
        }
    }
    
    /**
     We use this `DispatchSemaphore` to effectively awake the Thread whenever there are Events to process.
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    internal var eventsPending = DispatchSemaphore(value: 0)
    
    public func queueEvent(_ event: any Eventable, priority: EventPriority = .normal) {
        _queues.withLock { queues in
            if queues[priority] == nil { queues[priority] = [any Eventable]() } // Create the empty Array if it doesn't exist
            queues[priority]!.append(event)
        }
        eventsPending.signal()
    }
    
    public func stackEvent(_ event: any Eventable, priority: EventPriority = .normal) {
        _stacks.withLock { stacks in
            if stacks[priority] == nil { stacks[priority] = [any Eventable]() } // Create the empty Array if it doesn't exist
            stacks[priority]!.append(event)
        }
        eventsPending.signal()
    }
    
    /**
     Processes an Event
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - event: The Event to Process.
     */
    open func processEvent(_ event: any Eventable, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        preconditionFailure("processEvent must be overriden!")
    }
    
    /**
     Processes all of the Events in the given `Array` of `Eventable` objects
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - events: The `Array` of `Eventable` objects
     */
    @inline(__always) private func processEvents(_ events: [any Eventable], dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        for event in events {
            processEvent(event, dispatchMethod: dispatchMethod, priority: priority)
        }
    }
    
    /**
     Processes all of the Events in the Stacks in Priority-Stack-Order (highest-to-lowest, LiFo [Last-in-First-out])
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    private func processEventStacks() {
        // We need to take a snapshot of the Stacks and empty them
        var eventStacks = [EventPriority:[any Eventable]]()
        _stacks.withLock { stacks in
            eventStacks = stacks
            stacks.removeAll(keepingCapacity: true)
        }
        
        for priority in EventPriority.inOrder {
            let events = eventStacks[priority]
            if events == nil { continue } // If there is nothing, we can skip it
            processEvents(events!.reversed(), dispatchMethod: .stack, priority: priority) // It's a stack, so we must process them in reverse-order (LiFo)
        }
    }
    
    /**
     Processes all of the Events in the Queues in Priority-Queue-Order (highest-to-lowest, FiFo [First-in-First-out])
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    private func processEventQueues() {
        // We need to take a snapshot of the Queues and empty them
        var eventQueues = [EventPriority:[any Eventable]]()
        _queues.withLock { queues in
            eventQueues = queues
            queues.removeAll(keepingCapacity: true)
        }
        
        for priority in EventPriority.inOrder {
            let events = eventQueues[priority]
            if events == nil { continue } // If there is nothing, we can skip it
            processEvents(events!, dispatchMethod: .queue, priority: priority) // It's a queue, so we process them in-order (FiFo)
        }
    }
    
    /**
     Simple Macro to process first the Stacks, then the Queues
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    @inline(__always) internal func processAllEvents() {
        processEventStacks() // we process Stacks first
        processEventQueues() // we process Queues next
    }
    
    /**
     Overrides the `main` function from `Thread` to implement our Event Processor call
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    public override func main() {
        while isExecuting {
            eventsPending.wait() // This will make the Thread effectively "sleep" until there are Events pending
            processAllEvents() // Once there's at least one Event waiting, we will Process it/them.
        }
    }
    
    public override init() {
        super.init()
        start()
    }
}
