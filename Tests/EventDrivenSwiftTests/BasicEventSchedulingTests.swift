//
//  BasicEventSchedulingTests.swift
//  
//
//  Created by Simon Stuart on 28/08/2022.
//

import XCTest
import ThreadSafeSwift
@testable import EventDrivenSwift

final class BasicEventSchedulingTests: XCTestCase {
    private struct TestEvent: Eventable {
        public var foo: String
    }
    
    @ThreadSafeSemaphore private var testValue: String = "Hello"
    private var exp: XCTestExpectation? = nil
    private var executed: DispatchTime? = nil
    
    func testScheduling() throws {
        TestEvent.addListener(self, { (event: TestEvent, priority, dispatchTime) in
            self.testValue = event.foo
            self.executed = DispatchTime.now()
            print("TestEvent where foo = \(event.foo), dispatched at \(dispatchTime.uptimeNanoseconds)ns, executed at \(self.executed!.uptimeNanoseconds)ns... Delta is \(DispatchTime(uptimeNanoseconds: self.executed!.uptimeNanoseconds - dispatchTime.uptimeNanoseconds).uptimeNanoseconds)ns")
            self.exp?.fulfill()
        }, executeOn: .taskThread)
        
        exp = expectation(description: "Event Executed")
        
        XCTAssertEqual(testValue, "Hello")
        let scheduledFor = DispatchTime.now() + TimeInterval().advanced(by: 4)  // Schedule for T+5 seconds
        TestEvent(foo: "World").scheduleQueue(at: scheduledFor)
        
        let result = XCTWaiter.wait(for: [exp!], timeout: 5.0)
        
        XCTAssertNotEqual(result, .timedOut)
        
        XCTAssertEqual(testValue, "World")
        XCTAssertNotNil(executed)
        if executed != nil {
            XCTAssertLessThan(scheduledFor, executed!)
            XCTAssertLessThan(executed!, scheduledFor + TimeInterval().advanced(by: 4.00001))
        }
    }

}
