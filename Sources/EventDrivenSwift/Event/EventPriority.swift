//
// EventPriority.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Specifies the Priority of a given Event
 - Author: Simon J. Stuart
 - Version: 1.0.0
 */
public enum EventPriority: CaseIterable {
    case lowest
    case low
    case normal
    case high
    case highest
    
    /**
     Returns all of the `EventPriority` cases in order of `highest` to `lowest` (reverse order).
     - Author: Simon J. Stuart
     - Version: 1.0.0
     - Note: This is necessary because we always process Events in priority-order from `highest` to `lowest`
     */
    public static let inOrder = Self.allCases.reversed()
}
