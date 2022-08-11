//
// EventDispatchable.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

/**
 Protocol describing anything that Dispatches Events
 - Author: Simon J. Stuart
 - Version: 1.0.0
 */
public protocol EventDispatchable: EventHandlable {
    /**
     Registers the given `receiver` for the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    func addReceiver(_ receiver: any EventReceivable, forEventType: Eventable.Type)
    
    /**
     Unregisters the given `receiver` from the given `Eventable` Type
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    func removeReceiver(_ receiver: any EventReceivable, forEventType: Eventable.Type)
    
    /**
     Unregisters the given `receiver` from all `Eventable` Types
     - Author: Simon J. Stuart
     - Version: 1.0.0
     */
    func removeReceiver(_ receiver: any EventReceivable)
}
