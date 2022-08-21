//
// EventMethod.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 21st August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import Foundation

public typealias EventMethodTypedEventCallback<TOwner: AnyObject, TEvent: Any> = (_ sender: TOwner, _ event: TEvent, _ priority: EventPriority) -> ()

/**
 Any Property wrapped with `EventMethod` will automatically conform to `EventMethodContainer`
 - Author: Simon J. Stuart
 - Version: 4.1.0
 - Note: This is used to conformity-test decorated `var`s to automatically register Event Listeners
 */
public protocol EventMethodContainer {
    associatedtype TEventType: Eventable
    associatedtype TOwner: AnyObject
    
    var wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType> { get set }
    
    var owner: AnyObject? { get set }
    
    mutating func unregister()
}

/**
 Decorate Typed Event Callback Closures as `var` with `@EventMethod<TEventType>` to automatically register them.
 - Author: Simon J. Stuart
 - Version: 4.1.0
 */
@propertyWrapper
public struct EventMethod<TOwner: AnyObject, TEventType: Eventable>: EventMethodContainer {
    mutating public func unregister() {
        lock.wait()
        if token != nil {
            TEventType.removeListener(token!)
            token = nil
        }
        lock.signal()
    }
    
    private var token: UUID? = nil
    private var lock = DispatchSemaphore(value: 1)
    
    public var wrappedValue: EventMethodTypedEventCallback<TOwner, TEventType> {
        didSet {
            reRegsiterListener()
        }
    }
    public var executeOn: ExecuteEventOn {
        didSet {
            reRegsiterListener()
        }
    }
    
    public var owner: AnyObject? {
        didSet {
            reRegsiterListener()
        }
    }
    
    private func callback(event: TEventType, priority: EventPriority) {
        if let typedOwner = owner as? TOwner {
            wrappedValue(typedOwner, event, priority)
        }
    }
    
    mutating private func reRegsiterListener() {
        lock.wait()
        if token != nil {
            TEventType.removeListener(token!)
        }
        if owner != nil {
            token = TEventType.addListener(
                owner,
                callback,
                executeOn: executeOn)
        }
        lock.signal()
    }
    
    public init(wrappedValue: @escaping EventMethodTypedEventCallback<TOwner, TEventType>, executeOn: ExecuteEventOn = .requesterThread) {
        self.wrappedValue = wrappedValue
        self.executeOn = executeOn
    }
}
