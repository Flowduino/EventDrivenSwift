//
//  BasicEventListenerTests.swift
//  
//
//  Created by Simon Stuart on 12/08/2022.
//

import XCTest
import ThreadSafeSwift
@testable import EventDrivenSwift

final class BasicEventListenerTests: XCTestCase {
    struct TestEventTypeOne: Eventable {
        var foo: Int
    }
    
    var myFoo = 0
    var listenerToken: UUID? = nil
    let testOne = TestEventTypeOne(foo: 1000) // Create the Event
    var awaiter = DispatchSemaphore(value: 0)

    func testEventListenerOnListenerThread() throws {
        XCTAssertEqual(myFoo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(myFoo)")
        
        listenerToken = TestEventTypeOne.addListener(self, { (event: TestEventTypeOne, priority) in
            self.myFoo = event.foo
            self.awaiter.signal()
        }, executeOn: .listenerThread)
        
        testOne.queue()
        
        let result = awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(self.myFoo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(self.myFoo)")
        
        TestEventTypeOne.removeListener(listenerToken!)
    }
    
    func testEventListenerOnTaskThread() throws {
        XCTAssertEqual(myFoo, 0, "Expect initial value of eventThread.foo to be 0, but it's \(myFoo)")
        
        listenerToken = TestEventTypeOne.addListener(self, { (event: TestEventTypeOne, priority) in
            self.myFoo = event.foo
            self.awaiter.signal()
        }, executeOn: .taskThread)
        
        testOne.queue()
        
        let result = awaiter.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(10)))
        XCTAssertEqual(result, .success, "The Event Handler was not invoked in time!")
        XCTAssertEqual(self.myFoo, testOne.foo, "Expect new value of eventThread.foo to be \(testOne.foo), but it's \(self.myFoo)")
        
        TestEventTypeOne.removeListener(listenerToken!)
    }
}