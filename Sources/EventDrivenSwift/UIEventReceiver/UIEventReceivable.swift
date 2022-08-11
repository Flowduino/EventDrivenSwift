//
// UIEventReceivable.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 11th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Protocol describing anything that Receives Events on the UI Thread
 - Author: Simon J. Stuart
 - Version: 2.1.0
 - Note: Inherits from `EventReceivable`
 */
public protocol UIEventReceivable: AnyObject, EventReceivable {

}
