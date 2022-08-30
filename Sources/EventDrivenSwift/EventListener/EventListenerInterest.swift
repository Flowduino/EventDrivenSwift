//
// EventListenerInterest.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 11th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

public enum EventListenerInterest: CaseIterable {
    /**
     Receivers will receive all Events, regardless of age or whether they are the newest.
     */
    case all
    
    /**
     Receivers will ignore any Events older than the last one dispatched of the given `Eventable` type.
     */
    case latestOnly
    
    /**
     Receivers will ignore any Event that is older than a defined Delta (Maximum Age).
     - Author: Simon J. Stuart
     - Version: 5.0.0
     */
    case youngerThan
}
