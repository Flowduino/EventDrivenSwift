//
// EventMethod.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 21st August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

public typealias EventMethodTypedEventCallback<TOwner: AnyObject, TEvent: Any> = (_ sender: TOwner, _ event: TEvent, _ priority: EventPriority, _ dispatchTime: DispatchTime) -> ()

/**
 Any Property wrapped with `EventMethod` will automatically conform to `EventMethodContainer`
 - Author: Simon J. Stuart
 - Version: 4.1.0
 - Note: This is used to conformity-test decorated `var`s to automatically register Event Listeners
 */
public protocol EventMethodContainer {
    associatedtype TEventType: Eventable
    associatedtype TOwner: AnyObject
    
    var wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType>? { get set }
    
    mutating func prepare(owner: AnyObject)
}

/**
 Decorate Typed Event Callback Closures as `var` with `@EventMethod<TEventType>` to automatically register them.
 - Author: Simon J. Stuart
 - Version: 5.0.0
 */
@propertyWrapper
public struct EventMethod<TOwner: AnyObject, TEventType: Eventable>: EventMethodContainer {
    public var wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType>?
    public var executeOn: ExecuteEventOn
    
    private weak var owner: AnyObject? = nil
    
    private func callback(event: TEventType, priority: EventPriority, dispatchTime: DispatchTime) {
        if let typedOwner = owner as? TOwner {
            wrappedValue?(typedOwner, event, priority, dispatchTime)
        }
    }
    
    public init(wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType>?, executeOn: ExecuteEventOn = .requesterThread) {
        self.wrappedValue = wrappedValue
        self.executeOn = executeOn
    }
    
    mutating public func prepare(owner: AnyObject) {
        if let typedOwner = owner as? TOwner {
            self.owner = owner
            TEventType.addListener(
                typedOwner,
                callback,
                executeOn: executeOn)
        }
    }
}
