//  CustomDestinationTests.swift

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
        let expectation = expectation(description: #function)
        expectation.expectedFulfillmentCount = 5
        
        let mockSender = MockCustomDestinationSender(expectation: expectation)

        let sut = Logger(configuration: Configuration(), logMessageFormatter: JSONStringLogMessageFormatter(keys: FormatterKeys()), customLogSender: mockSender)
        
        sut.send(Log(type: .verbose, message: "Verbose Message"))
        sut.send(Log(type: .debug, message: "Debug Message"))
        sut.send(Log(type: .info, message: "Info Message"))
        sut.send(Log(type: .warning, message: "Warning Message"))
        sut.send(Log(type: .error, message: "Error Message"))
        
        mockSender.logs.forEach { XCTAssertTrue($0.contains("device_timestamp")) }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
}
