//
// EventPoolBalancing.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 13th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Protocol describing anything that Balances `EventPooling`
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Note: Event Pool Balancers perform calculations to determine which `EventThread` should receive any inbound `Eventable`
 */
public protocol EventPoolBalancing {
    /**
     Invoked by `EventPool` to determine which `EventThreadable` should be used to process an inbound `Eventable`
     - Author: Simon J. Stuart
     - Version: 4.0.0
     - Parameters:
        - eventThreads: Reference to all of the `EventThreadable`s currently in the `EventPool`
     - Returns: The `EventThreadable` selected to process an inbound `Eventable`
     */
    func chooseEventThread(eventThreads: [EventThreadable]) -> EventThreadable?
}
