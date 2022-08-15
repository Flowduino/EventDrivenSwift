//
// EventPoolStaticScaler.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 13th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 This Static Scaler  does not increase or decrease the scale beyond the static value defined by your code.
 - Author: Simon J. Stuart
 - Version: 4.0.0
 - Note: This is the **default** Event Pool Scaler used if you don't explicitly define one for an `EventPool`
 */
public class EventPoolStaticScaler: EventPoolScaler {
    /**
     The `EventPoolStaticScaler` simply returns what is ncessary to inform the `EventPool` that it must not change its `capacity` or cull any Threads
     */
    override public func calculateScaling(currentCapacity: UInt8, eventThreads: [EventThreadable], eventsPending: Int) -> EventPoolScalingResult {
        return EventPoolScalingResult(modifyCapacity: false, newCapacity: currentCapacity, cullOrKeepThreads: [Bool]())
    }
}
