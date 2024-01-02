//  LogstashDestinationSendingSchedulerTests.swift

import Foundation
import XCTest

@testable import JustLog

class LogstashDestinationSendingSchedulerTests: XCTestCase {
    let sut = LogstashDestinationSendingScheduler()
    
    func test_givenScheduler_whenSendSuccessful_thenNoErrorsReturned() async {
        let log = ["Testing": "Testing"]
        let logs = [1: log]
        
        let result = await sut.scheduleSend(logs) { _ in }
        
        XCTAssertEqual(result.isEmpty, true)
    }
    
    func test_givenScheduler_whenSendFails_thenErrorsReturned() async throws {
        let log = ["Testing": "Testing"]
        let logs = [1: log]
        
        let result = await sut.scheduleSend(logs) { _ in
            throw SendError.generalError
        }
        
        XCTAssertEqual(result.isEmpty, false)
        let error = try XCTUnwrap(result.first?.value as? SendError)
        XCTAssertEqual(error, SendError.generalError)
    }
    
    func test_givenScheduler_whenOneSendFails_thenOtherLogSent() async {
        let log = ["Testing": "Testing"]
        let logs = [1: log, 2: log, 3: log]
        let sendCounter = SendCounter()
        
        let result = await sut.scheduleSend(logs) { _ in
            let count = await sendCounter.count
            if count >= 2 {
                throw SendError.generalError
            } else {
                await sendCounter.increment()
            }
        }
        
        XCTAssertEqual(result.isEmpty, false)
        XCTAssertEqual(result.count, 1)
        let finalCount = await sendCounter.count
        XCTAssertEqual(finalCount, 2)
    }
}

actor SendCounter {
    var count = 0
    func increment() {
        count += 1
    }
}

enum SendError: Error {
    case generalError
}
