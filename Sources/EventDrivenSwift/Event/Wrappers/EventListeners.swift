//
// EventListeners.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 21st August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

public protocol EventListenerCallbackContainer {
    associatedtype TEventType: Eventable
    
    static func buildBlock(_ callback: @escaping ((_ event: TEventType, _ priority: EventPriority) -> ()), _ owner: AnyObject, _ executeOn: ExecuteEventOn) -> EventListenerHandling
}

@resultBuilder
public struct EventListenerCallback<TEventType: Eventable>: EventListenerCallbackContainer {
    public static func buildBlock(_ callback: @escaping ((_ event: TEventType, _ priority: EventPriority) -> ()), _ owner: AnyObject, _ executeOn: ExecuteEventOn = .requesterThread) -> EventListenerHandling {
        return TEventType.addListener(owner, callback, executeOn: executeOn)
    }
   
    init() {
        print("Init called")
    }
}

@resultBuilder
public struct EventListeners<TOwner: AnyObject> {
    public static func buildBlock(_ owner: TOwner, _ executeOn: ExecuteEventOn = .requesterThread, _ eventType: Eventable.Type, _ events: EventCallback...) -> [EventListenerHandling] {
        var results = [EventListenerHandling]()
        for event in events {
//            results.append(EventCentral.addListener(owner, event, forEventType: eventType))
        }
        return results
    }
}
