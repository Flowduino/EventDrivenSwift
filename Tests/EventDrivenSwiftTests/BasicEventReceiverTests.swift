//
// BasicEventReceiverTests.swift
// Copyright (c) 2022, Flowduino
// Authored by Simon J. Stuart on 4th August 2022
//
// Subject to terms, restrictions, and liability waiver of the MIT License
//

import XCTest
import ThreadSafeSwift
@testable import EventDrivenSwift

final class BasicEventReceiverTests: XCTestCase {
    struct TestEventTypeOne: Eventable {
        var foo: Int
    }
    
    class TestEventThread: EventReceiver {
        @ThreadSafeSemaphore var foo: Int = 0
        public var awaiter = DispatchSemaphore(value: 0)
        
        internal func eventOneCallback(_ event: TestEventTypeOne, _ priority: EventPriority) {
            foo = event.foo
            awaiter.signal()
        }
        
        override func registerEventListeners() {
            addEventCallback({ event, priority in
                self.callTypedEventCallback(self.eventOneCallback, forEvent: event, priority: priority)
            }, forEventType: TestEventTypeOne.self)
        }
    }

    let expectedTestOneFoo: Int = 1000
    
    func testEventDispatchQueueDirect() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread

        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        eventThread.queueEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
        
        let result = eventThread.awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }
    
    func testEventDispatchQueueCentral() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread
        
        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        EventCentral.shared.queueEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
        
        let result = eventThread.awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }

    func testEventDispatchQueueTransparent() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread
        
        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        testOne.queue() // Now let's dispatch our Event to change this value
        
        let result = eventThread.awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }
    
    func testEventDispatchStackDirect() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread

        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        eventThread.stackEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
        
        let result = eventThread.awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }
    
    func testEventDispatchStackCentral() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread
        
        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        EventCentral.shared.stackEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
        
        let result = eventThread.awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }

    func testEventDispatchStackTransparent() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread
        
        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        testOne.stack() // Now let's dispatch our Event to change this value
        
        let result = eventThread.awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }
}
