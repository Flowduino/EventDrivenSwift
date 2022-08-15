//
// EventPoolScaling.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 13th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Contains information necessary for an `EventPool` to act on the results provided by `EventPoolScaling` calculations
 - Author: Simon J. Stuart
 - Version: 4.0.0
 */
public struct EventPoolScalingResult {
    /// Defines whether or not the `EventPool` needs to modify its `capacity`
    var modifyCapacity: Bool
    
    /// Defines the new `capacity` the `EventPool` should switch to
    var newCapacity: UInt8
    
    /// Defines which (if any) existing `EventThread` instances should be culled (index-corresponsive, where `true` means to cull the Thread, `false` means to retain it)
    var cullOrKeepThreads: [Bool]
}

/**
 Event Pool Scalers perform calculations to increase or reduce the number of `EventThread`s in response to load and performance across the `EventPool`.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 */
public protocol EventPoolScaling: AnyObject {
    var initialCapacity: UInt8 { get }
    var minimumCapacity: UInt8 { get }
    var maximumCapacity: UInt8 { get }
    
    /**
     Invoked by an `EventPool` to determine whether to scale, and (if applicable) *how* to scale
     - Author: Simon J. Stuart
     - Version: 4.0.0
     - Parameters:
        - currentCapacity: The number of `EventThreadble`s currently in the `EventPool`
        - eventThreads: `Array` of references to all of the current `EventThread`s in the `EventPool`
        - eventsPending: The number of `Eventable` objects currently pending against the `EventPool`
     - Returns: An `EventPoolScalingResult` containing details on whether to scale, and which `EventThreadable`s to cull (if any)
     */
    func calculateScaling(
        currentCapacity: UInt8,
        eventThreads: [EventThreadable],
        eventsPending: Int
    ) -> EventPoolScalingResult
}
