//
//  CustomDestinationTests.swift
//  JustLog_Tests
//
//  Created by Antonio Strijdom on 02/02/2021.
//  Copyright © 2021 Just Eat. All rights reserved.
//

import XCTest
@testable import JustLog

class MockCustomDestinationSender: CustomDestinationSender {
    let expectation: XCTestExpectation
    var logs: [String]
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
        self.logs = []
    }
    
    func log(_ string: String) {
        expectation.fulfill()
        logs.append(string)
    }
}

class CustomDestinationTests: XCTestCase {

    func testBasicLogging() throws {
        let expect = expectation(description: "Send log expectation")
        expect.expectedFulfillmentCount = 5
        let mockSender = MockCustomDestinationSender(expectation: expect)
        let destination = CustomDestination(sender: mockSender)
        DispatchQueue.main.async {
            let message = "{ \"message\": \"Hello, world!\" }"
            _ = destination.send(.verbose, msg: message, thread: "", file: "", function: "", line: 0)
            _ = destination.send(.debug, msg: message, thread: "", file: "", function: "", line: 0)
            _ = destination.send(.info, msg: message, thread: "", file: "", function: "", line: 0)
            _ = destination.send(.warning, msg: message, thread: "", file: "", function: "", line: 0)
            _ = destination.send(.error, msg: message, thread: "", file: "", function: "", line: 0)
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func test_logger_sendsDeviceTimestampForEachLogType() {
        let sut = Logger.shared
        sut.enableCustomLogging = true
        
        let expectation = expectation(description: #function)
        expectation.expectedFulfillmentCount = 5

        let mockSender = MockCustomDestinationSender(expectation: expectation)
        sut.setupWithCustomLogSender(mockSender)
        
        sut.verbose("Verbose Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.debug("Debug Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.info("Info Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.warning("Warning Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.error("Error Message", error: nil, userInfo: nil, #file, #function, #line)
        
        mockSender.logs.forEach { XCTAssertTrue($0.contains("device_timestamp")) }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
}
