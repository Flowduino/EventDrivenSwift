//
// EventPoolScaler.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 13th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation
import ThreadSafeSwift

/**
 Abstract Base Class for all Event Pool Scalers.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Note: Event Pool Scalers perform calculations to increase or reduce the number of `EventThread`s in response to load and performance across the `EventPool`.
 */
open class EventPoolScaler: EventPoolScaling {
    @ThreadSafeSemaphore public var initialCapacity: UInt8
    @ThreadSafeSemaphore public var minimumCapacity: UInt8
    @ThreadSafeSemaphore public var maximumCapacity: UInt8
    
    init(
        initialCapacity: UInt8,
        minimumCapacity: UInt8,
        maximumCapacity: UInt8
    ) {
        self.initialCapacity = initialCapacity
        self.minimumCapacity = minimumCapacity
        self.maximumCapacity = maximumCapacity
    }
    
    public func calculateScaling(currentCapacity: UInt8, eventThreads: [EventThreadable], eventsPending: Int) -> EventPoolScalingResult {
        return EventPoolScalingResult(modifyCapacity: false, newCapacity: currentCapacity, cullOrKeepThreads: [Bool]())
    }
}
