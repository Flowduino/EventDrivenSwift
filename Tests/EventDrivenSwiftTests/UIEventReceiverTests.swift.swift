//
//  UIEventReceiverTests.swift.swift
//  
//
//  Created by Simon Stuart on 11/08/2022.
//

import XCTest
import ThreadSafeSwift
@testable import EventDrivenSwift

final class UIEventReceiverTests_swift: XCTestCase {
    struct TestEventTypeOne: Eventable {
        var foo: Int
    }
    
    class TestEventThread: UIEventReceiver {
        @ThreadSafeSemaphore var foo: Int = 0
        
        internal func eventOneCallback(_ event: TestEventTypeOne, _ priority: EventPriority) {
            foo = event.foo
        }
        
        override func registerEventListeners() {
            addEventCallback(self.eventOneCallback, forEventType: TestEventTypeOne.self)
        }
    }

    let expectedTestOneFoo: Int = 1000
    
    /**
     I need to find a way of Unit Testing the `UIEventReceiver`.
     It works, this I know, but Unit Tests operate on the UI Thread, which means they are blocking the `UIEventReceiver` callback until *after* the Test Method has already returned (thus failed)
     */
    
    /*
    func testEventDispatchQueueDirect() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread

        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        eventThread.queueEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
        
        sleep(5)
        
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }
    
    func testEventDispatchQueueCentral() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread
        
        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        EventCentral.queueEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
        
        sleep(5)
        
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }

    func testEventDispatchQueueTransparent() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread
        
        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        testOne.queue() // Now let's dispatch our Event to change this value
        
        sleep(5)
        
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }
    
    func testEventDispatchStackDirect() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread

        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        eventThread.stackEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
        
        sleep(5)
        
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }
    
    func testEventDispatchStackCentral() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread
        
        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        EventCentral.stackEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
        
        sleep(5)
        
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }

    func testEventDispatchStackTransparent() throws {
        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
        let eventThread = TestEventThread() // Create the Thread
        
        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
        
        testOne.stack() // Now let's dispatch our Event to change this value
        
        sleep(5)
        
        XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
    }
     */
}
