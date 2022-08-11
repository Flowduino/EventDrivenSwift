//
//  EventListenerTests.swift
//  
//
//  Created by Simon Stuart on 11/08/2022.
//

import XCTest
import ThreadSafeSwift
@testable import EventDrivenSwift

final class EventListenerTests: XCTestCase {
    struct TestEventTypeOne: Eventable {
        var foo: Int
    }
    let expectedTestOneFoo: Int = 1000
    var myFoo = 0
    var awaiter = DispatchSemaphore(value: 0)
  
    /// Need a reliable way of Unit Testing this! Anything I do to try to await a result causes this Execution Thread to lock, so the Callback won't occur until *after* the test returns!
    
//    func testCentralEventListener() throws {
//        let listenerToken = TestEventTypeOne.addListener(self) { (event: TestEventTypeOne, priority) in
//            self.myFoo = event.foo
//            self.awaiter.signal()
//        }
//        // Make sure our Initial Value is as expected
//        XCTAssertEqual(myFoo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(myFoo)")
//        let testOne = TestEventTypeOne(foo: expectedTestOneFoo) // Create the Event
//        testOne.queue() // Dispatch the Event
//
//        let result = awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
//
//        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
//
//        XCTAssertEqual(self.myFoo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(self.myFoo)")
//        TestEventTypeOne.removeListener(listenerToken)
//    }

}
