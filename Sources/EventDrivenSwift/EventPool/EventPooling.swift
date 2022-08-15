//
// EventPooling.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 13th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Protocol describing anything that Pools `EventThread`s
 - Author: Simon J. Stuart
 - Version: 4.0.0
 */
public protocol EventPooling: AnyObject, EventReceiving, EventDispatching {
    /**
     The Balancer to use when determining which `EventThread` should receive an Inbound `Eventable
     - Author: Simon J. Stuart
     - Version: 4.0.0
     - Returns: The Balancer to use when determining which `EventThread` should receive an Inbound `Eventable
     */
    var balancer: EventPoolBalancing { get set }
    
    /**
     The Scaler used to increase or reduce the number of Event Threads in response to load and performance.
     - Author: Simon J. Stuart
     - Version: 4.0.0
     - Returns: The Scaler used to increase or reduce the number of Event Threads in response to load and performance.
     */
    var scaler: EventPoolScaling { get set }
    
    var capacity: UInt8 { get }
}
