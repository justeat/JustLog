//
//  LogstashDestinationTests.swift
//  JustLog_Tests
//
//  Created by Antonio Strijdom on 13/07/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import JustLog

class LogstashDestinationTests: XCTestCase {

    func testBasicLogging() throws {
        let expect = expectation(description: "Send log expectation")
        let mockSocket = MockLogstashDestinationSocket(host: "", port: 0, timeout: 5, logActivity: true, allowUntrustedServer: true)
        mockSocket.expect = expect
        let destination = LogstashDestination(socket: mockSocket, logActivity: true)
        _ = destination.send(.verbose, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.debug, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.info, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.warning, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.error, msg: "{}", thread: "", file: "", function: "", line: 0)
        expect.expectedFulfillmentCount = 5
        destination.forceSend()
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testCompletionHandler() throws {
        let expect = expectation(description: "Send log expectation")
        let mockSocket = MockLogstashDestinationSocket(host: "", port: 0, timeout: 5, logActivity: true, allowUntrustedServer: true)
        let destination = LogstashDestination(socket: mockSocket, logActivity: true)
        _ = destination.send(.verbose, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.debug, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.info, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.warning, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.error, msg: "{}", thread: "", file: "", function: "", line: 0)
        destination.forceSend { _ in
            expect.fulfill()
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testLoggingError() throws {
        let expect = expectation(description: "Error log expectation")
        let mockSocket = MockLogstashDestinationSocket(host: "", port: 0, timeout: 5, logActivity: true, allowUntrustedServer: true)
        mockSocket.errorState = true
        mockSocket.expect = expect
        let destination = LogstashDestination(socket: mockSocket, logActivity: true)
        _ = destination.send(.verbose, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.debug, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.info, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.warning, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.error, msg: "{}", thread: "", file: "", function: "", line: 0)
        expect.expectedFulfillmentCount = 5
        destination.forceSend()
        self.waitForExpectations(timeout: 10.0, handler: nil)
        mockSocket.errorState = false
        let expect2 = expectation(description: "Send log expectation")
        expect2.expectedFulfillmentCount = 5
        mockSocket.expect = expect2
        destination.forceSend()
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testLoggingCancel() throws {
        let expect = expectation(description: "Error log expectation")
        let mockSocket = MockLogstashDestinationSocket(host: "", port: 0, timeout: 5, logActivity: true, allowUntrustedServer: true)
        mockSocket.errorState = true
        mockSocket.expect = expect
        let destination = LogstashDestination(socket: mockSocket, logActivity: true)
        _ = destination.send(.verbose, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.debug, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.info, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.warning, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.error, msg: "{}", thread: "", file: "", function: "", line: 0)
        expect.expectedFulfillmentCount = 5
        destination.forceSend()
        self.waitForExpectations(timeout: 10.0, handler: nil)
        destination.cancelSending()
        mockSocket.errorState = false
        let expect2 = expectation(description: "Send log expectation")
        mockSocket.expect = expect2
        _ = destination.send(.error, msg: "{}", thread: "", file: "", function: "", line: 0)
        destination.forceSend()
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
}

enum LogstashDestinationTestError: Error {
    case whoops
}

class MockLogstashDestinationSocket: NSObject, LogstashDestinationSocketProtocol {
    
    var expect: XCTestExpectation?
    var errorState: Bool = false
    
    required init(host: String, port: UInt16, timeout: TimeInterval, logActivity: Bool, allowUntrustedServer: Bool) {
        super.init()
    }
    
    func cancel() {
        // do nothing
    }
    
    func sendLogs(_ logs: [Int : [String : Any]], transform: ([String : Any]) -> Data, enqueued: LogstashDestinationSocketProtocolEnqueued?, complete: @escaping LogstashDestinationSocketProtocolCompletion) {
        for log in logs.sorted(by: { $0.0 < $1.0 }) {
            let tag = log.0
            let _ = transform(log.1)
            if let enqueued = enqueued {
                enqueued(tag)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let error: LogstashDestinationTestError? = self.errorState ? .whoops : nil
                complete(tag, error)
                self.expect?.fulfill()
            }
        }
    }
}
