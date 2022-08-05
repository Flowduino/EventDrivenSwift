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

open class EventHandler: ObservableThread, EventHandlable {
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
            
            var snapStacks = [EventPriority:[any Eventable]]()
            var snapQueues = [EventPriority:[any Eventable]]()
            
            _stacks.withLock { stacks in
                snapStacks = stacks
            }
            _queues.withLock { queues in
                snapQueues = queues
            }
            
            for stack in snapStacks.values {
                stackCount += stack.count
            }
            
            for queue in snapQueues.values {
                queueCount += queue.count
            }
            
            return stackCount + queueCount
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
    internal func processEvent(_ event: any Eventable, dispatchMethod: EventDispatchMethod, priority: EventPriority) {
        preconditionFailure("processEvent must be overriden!")
    }
    
    /**
     Processes all of the Events in the given `Array` of `Eventable` objects
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Parameters:
        - events: The `Array` of `Eventable` objects
     */
    private func processEvents(_ events: [any Eventable], dispatchMethod: EventDispatchMethod, priority: EventPriority) {
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
    
    internal func processAllEvents() {
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
            eventsPending.wait()
            processAllEvents()
        }
    }
    
    override init() {
        super.init()
        for priority in EventPriority.allCases {
            queues[priority] = [any Eventable]()
            stacks[priority] = [any Eventable]()
        }
        start()
    }
}
