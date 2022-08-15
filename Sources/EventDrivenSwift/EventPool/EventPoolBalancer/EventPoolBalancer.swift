//
// EventPoolBalancer.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 13th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Abstract Base Class for all Event Pool Balancers.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Note: Event Pool Balancers perform calculations to determine which `EventThread` should receive any inbound `Eventable`
 */
open class EventPoolBalancer: EventPoolBalancing {
    public func chooseEventThread(eventThreads: [EventThreadable]) -> EventThreadable? {
        preconditionFailure("chooseEventThread must be overriden!")
    }
}
