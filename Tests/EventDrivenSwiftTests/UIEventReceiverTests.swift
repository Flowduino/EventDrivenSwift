//
//  UIEventReceiverTests.swift
//  
//
//  Created by Simon Stuart on 11/08/2022.
//

import XCTest
import ThreadSafeSwift
@testable import EventDrivenSwift

final class UIEventReceiverTests: XCTestCase {
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
    
    /// Need a reliable way of Unit Testing this! Anything I do to try to await a result causes this Execution Thread to lock, so the Callback won't occur until *after* the test returns!
    
//    func testEventDispatchQueueDirect() throws {
//        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
//        let eventThread = TestEventThread() // Create the Thread
//
//        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
//        
//        eventThread.queueEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
//        
//        let seconds = 1.0
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//            XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
//        }
//    }
//    
//    func testEventDispatchQueueCentral() throws {
//        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
//        let eventThread = TestEventThread() // Create the Thread
//        
//        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
//        EventCentral.queueEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
//        
//        let seconds = 1.0
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//            XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
//        }
//    }
//
//    func testEventDispatchQueueTransparent() throws {
//        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
//        let eventThread = TestEventThread() // Create the Thread
//        
//        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
//        
//        testOne.queue() // Now let's dispatch our Event to change this value
//        
//        let seconds = 1.0
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//            XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
//        }
//    }
//    
//    func testEventDispatchStackDirect() throws {
//        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
//        let eventThread = TestEventThread() // Create the Thread
//
//        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
//        
//        eventThread.stackEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
//        
//        let seconds = 1.0
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//            XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
//        }
//    }
//    
//    func testEventDispatchStackCentral() throws {
//        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
//        let eventThread = TestEventThread() // Create the Thread
//        
//        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
//        
//        EventCentral.stackEvent(testOne, priority: .normal) // Now let's dispatch our Event to change this value
//        
//        let seconds = 1.0
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//            XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
//        }
//    }
//
//    func testEventDispatchStackTransparent() throws {
//        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
//        let eventThread = TestEventThread() // Create the Thread
//        
//        XCTAssertEqual(eventThread.foo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(eventThread.foo)")
//        
//        testOne.stack() // Now let's dispatch our Event to change this value
//        
//        let seconds = 1.0
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//            XCTAssertEqual(eventThread.foo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(eventThread.foo)")
//        }
//    }
}
