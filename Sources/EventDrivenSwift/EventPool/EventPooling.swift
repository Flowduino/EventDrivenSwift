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
 - Version: 3.1.0
 */
public protocol EventPooling: AnyObject, EventReceiving, EventDispatching {
    
}
