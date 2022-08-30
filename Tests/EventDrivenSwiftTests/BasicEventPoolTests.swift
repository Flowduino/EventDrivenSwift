//
//  BasicEventPoolTests.swift
//  
//
//  Created by Simon Stuart on 15/08/2022.
//

import XCTest
import ThreadSafeSwift
@testable import EventDrivenSwift

class PoolTestStatic {
    @ThreadSafeSemaphore static var values = [String]()
    @ThreadSafeSemaphore static var awaiters = [DispatchSemaphore]()
    
    static func setValue(index: Int, value: String) {
        _values.withLock { values in
            values[index] = value
            awaiters[index].signal()
        }
    }
}

final class BasicEventPoolTests: XCTestCase {
    
    struct PoolTestingEvent: Eventable {
        var index: Int
        var value: String
    }
    
    class PoolTestingThread: EventThread {
        override func registerEventListeners() {
            addEventCallback(
                { (event: PoolTestingEvent, priority, dispatchTime) in
                    Thread.sleep(forTimeInterval: 5)
                    PoolTestStatic.setValue(index: event.index, value: event.value)
                    Thread.sleep(forTimeInterval: 5)
                },
                forEventType: PoolTestingEvent.self
            )
        }
    }

    override func setUpWithError() throws {
        PoolTestStatic.values = ["Initial 1", "Initial 2", "Initial 3", "Initial 4", "Initial 5"]
        PoolTestStatic.awaiters = [
            DispatchSemaphore(value: 0),
            DispatchSemaphore(value: 0),
            DispatchSemaphore(value: 0),
            DispatchSemaphore(value: 0),
            DispatchSemaphore(value: 0)
        ]
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEventPoolConcurrency() throws {
        let _ = EventPool<PoolTestingThread>(capacity: 5)
        
        // Confirm Initial Values
        var valueIndex: Int = 0
        while valueIndex < 5 {
            XCTAssertEqual(PoolTestStatic.values[valueIndex], "Initial \(valueIndex + 1)")
            valueIndex += 1
        }
        
        // Dispatch Events to the Pool
        var eventIndex: Int = 0
        while eventIndex < 5 {
            PoolTestingEvent(index: eventIndex, value: "Updated \(eventIndex + 1)").queue()
            eventIndex += 1
        }
    
        // Wait for everything (or timeouts, as the case might be)
        var results = [DispatchTimeoutResult]()
        var index: Int = 0
        while index < 5 {
            results.append(PoolTestStatic.awaiters[index].wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(6))))
            index += 1
        }
        
        let finalValues = PoolTestStatic.values
        var resultIndex: Int = 0
        while resultIndex < 5 {
            // Confirm that the Awaiter was Signalled
            XCTAssertEqual(results[resultIndex], .success)
            // Confirm that the Value has been updated
            XCTAssertEqual(finalValues[resultIndex], "Updated \(resultIndex + 1)")
            resultIndex += 1
        }
    }
}
