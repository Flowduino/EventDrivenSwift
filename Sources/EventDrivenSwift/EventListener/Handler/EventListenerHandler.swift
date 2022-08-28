//
// EventListenerHandler.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 28th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 A Handler for an `EventListener` your code has registered. You can use this to revoke your Event Listeners at any time.
 - Author: Simon J. Stuart
 - Version: 4.1.0
 */
public class EventListenerHandler: EventListenerHandling {
    /**
     `weak` reference to the `EventListenable` against which this Listener is registered.
     - Author: Simon J. Stuart
     - Version: 4.1.0
     */
    private weak var eventListenable: EventListenable?
    
    /**
     This is the Token Key assoicated with your Listener
     - Author: Simon J. Stuart
     - Version: 4.1.0
     */
    private var token: UUID
    
    public func remove() {
        eventListenable?.removeListener(token)
    }
    
    public init(eventListenable: EventListenable, token: UUID) {
        self.token = token
    }
}
