//
// EventPoolLowestLoadBalancer.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 15th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Simply delegates each request to the first `EventThread` in the `ThreadPool` to have the lowest number of pending `Eventable`s to process
 - Author: Simon J. Stuart
 - Version: 4.0.0
 */
public class EventPoolLowestLoadBalancer: EventPoolBalancer {
    override public func chooseEventThread(eventThreads: [EventThreadable]) -> EventThreadable? {
        if eventThreads.count == 0 { return nil } // If there are no Event Threads, we can't possibly return one!
        
        let sorted = eventThreads.sorted { lhs, rhs in
            lhs.eventCount > rhs.eventCount
        }
        
        return sorted.first
    }
}
