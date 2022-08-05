//
// EventDispatchMethod.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Specifies the Dispatch Method of a given Event
 - Author: Simon J. Stuart
 - Version: 1.0.0
 */
public enum EventDispatchMethod: CaseIterable {
    /// The Event was dispatched through the Queue
    case queue
    /// The Event was dispatched through the Stack
    case stack
}
