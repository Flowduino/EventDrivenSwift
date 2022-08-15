//
// EventPoolRoundRobinBalancer.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 13th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Simply delegates each request to the next `EventThread` in the `ThreadPool`, cycling back around to the first when passing the last.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 */
public class EventPoolRoundRobinBalancer: EventPoolBalancer {
    private var lastThreadIndex: Int? = nil
    
    override public func chooseEventThread(eventThreads: [EventThreadable]) -> EventThreadable? {
        if eventThreads.count == 0 { return nil } // If there are no Event Threads, we can't possibly return one!
        
        lastThreadIndex = lastThreadIndex == nil ? 0 : lastThreadIndex! > eventThreads.count ? 0 : lastThreadIndex! + 1 // Determine the Thread Index to use
        
        return eventThreads[lastThreadIndex!] // Return the selected Thread
    }
}
