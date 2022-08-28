//
// EventListenerHandling.swift
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
public protocol EventListenerHandling: AnyObject {
    /**
     Removes your Event Listener
     */
    func remove()
}
