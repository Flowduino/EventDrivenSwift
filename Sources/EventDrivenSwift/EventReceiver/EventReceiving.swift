//
// EventReceiving.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Protocol describing anything that Receives Events
 - Author: Simon J. Stuart
 - Version: 1.0.0
 */
public protocol EventReceiving: AnyObject, EventHandling {
    /**
     Declares whether this Receiver is interested in `.all` Events, or `.latestOnly`
     - Author: Simon J. Stuart
     - Version: 4.3.0
     */
    var interestedIn: EventListenerInterest { get set }
}
