//
//  BasicEventListenerTests.swift
//  
//
//  Created by Simon Stuart on 12/08/2022.
//

import XCTest
import ThreadSafeSwift
@testable import EventDrivenSwift

final class BasicEventListenerTests: XCTestCase, EventListening {
    struct TestEventTypeOne: Eventable {        
        var foo: Int
    }
    
    struct TestEventTypeTwo: Eventable {
        var bar: String
    }
       
    @EventMethod<BasicEventListenerTests, TestEventTypeOne>(executeOn: .taskThread) var event1 = { (self, event: TestEventTypeOne, priority: EventPriority, dispatchTime: DispatchTime)  in
        self.doTestEvent(event: event, priority: priority)
    }
    
    func doTestEvent(event: TestEventTypeOne, priority: EventPriority) {
        print("onTestEvent: foo = \(event.foo)")
    }
    
    @EventMethod<BasicEventListenerTests, TestEventTypeTwo>(executeOn: .taskThread) var event2 = { (self, event: TestEventTypeTwo, priority: EventPriority, dispatchTime: DispatchTime) in
        self.doTestEventTwo(event: event, priority: priority)
    }
    
    func doTestEventTwo(event: TestEventTypeTwo, priority: EventPriority) {
        print("doTestEventTwo: bar = \(event.bar)")
    }
    
    var myFoo = 0
    var listenerHandler: EventListenerHandling? = nil
    let testOne = TestEventTypeOne(foo: 1000) // Create the Event
    let testZero = TestEventTypeOne(foo: 2000) // Create the Event
    var awaiter = DispatchSemaphore(value: 0)
       
    func testEventListenerOnListenerThread() throws {
        registerListeners()
        XCTAssertEqual(myFoo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(myFoo)")
        
        listenerHandler = TestEventTypeOne.addListener(self, { (event: TestEventTypeOne, priority, dispatchTime) in
            self.myFoo = event.foo
            self.awaiter.signal()
        }, executeOn: .listenerThread)
        
        testOne.queue()
        
        TestEventTypeTwo(bar: "A simple test").queue()
        
        let result = awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(self.myFoo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(self.myFoo)")
        
        listenerHandler?.remove()
    }
    
    func testEventListenerOnTaskThread() throws {
//        registerListeners()
        XCTAssertEqual(myFoo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(myFoo)")
        
        listenerHandler = TestEventTypeOne.addListener(self, { (event: TestEventTypeOne, priority, dispatchTime) in
            self.myFoo = event.foo
            self.awaiter.signal()
        }, executeOn: .taskThread)
        
        testOne.queue()
        
        let result = awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(self.myFoo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(self.myFoo)")
        
        listenerHandler?.remove()
    }
    
    func testEventListenerCustomFilter() throws {
        XCTAssertEqual(myFoo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(myFoo)")
        
        listenerHandler = TestEventTypeOne.addListener(self, { (event: TestEventTypeOne, priority, dispatchTime) in
            self.myFoo = event.foo
            self.awaiter.signal()
        }, executeOn: .taskThread, interestedIn: .custom, customFilter: { (event: TestEventTypeOne, priority, dispatchTime) in
            if event.foo == 1000 {
                print("Accepting Event because foo = 1000")
                return true
            }
            print("Ignoring Event where foo = \(event.foo)")
            return false
        })
        
        testOne.queue()
        testZero.queue()
        
        let result = awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(self.myFoo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(self.myFoo)")
        
        listenerHandler?.remove()
    }
}
