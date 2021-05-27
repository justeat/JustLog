//
//  LogstashDestinationTests.swift
//  JustLog_Tests
//
//  Created by Antonio Strijdom on 13/07/2020.
//  Copyright © 2020 Just Eat. All rights reserved.
//

import XCTest
@testable import JustLog

class LogstashDestinationTests: XCTestCase {

    func testBasicLogging() throws {
        let expect = expectation(description: "Send log expectation")
        let mockSocket = MockLogstashDestinationSocket(host: "", port: 0, timeout: 5, logActivity: true, allowUntrustedServer: true)
        mockSocket.networkOperationCountExpectation = expect
        mockSocket.completionHandlerCalledExpectation = expectation(description: "completionHandlerCalledExpectation")
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

    func testCompletionHandlers() throws {
        let expectFirstCompletion = expectation(description: "Send log first expectation")
        let expectSecondCompletion = expectation(description: "Send log second expectation")
        let mockSocket = MockLogstashDestinationSocket(host: "", port: 0, timeout: 5, logActivity: true, allowUntrustedServer: true)
        let destination = LogstashDestination(socket: mockSocket, logActivity: true)
        _ = destination.send(.verbose, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.debug, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.info, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.warning, msg: "{}", thread: "", file: "", function: "", line: 0)
        _ = destination.send(.error, msg: "{}", thread: "", file: "", function: "", line: 0)
        destination.forceSend { _ in
            expectFirstCompletion.fulfill()
        }
        destination.forceSend { _ in
            expectSecondCompletion.fulfill()
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testLoggingError() throws {
        let expect = expectation(description: "Error log expectation")
        let expectFirstCompletion = expectation(description: "First completion expectation")
        let mockSocket = MockLogstashDestinationSocket(host: "", port: 0, timeout: 5, logActivity: true, allowUntrustedServer: true)
        mockSocket.errorState = true
        mockSocket.networkOperationCountExpectation = expect
        mockSocket.completionHandlerCalledExpectation = expectFirstCompletion
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
        let expectSecondCompletion = expectation(description: "Second completion expectation")
        mockSocket.networkOperationCountExpectation = expect2
        mockSocket.completionHandlerCalledExpectation = expectSecondCompletion
        destination.forceSend()
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testLoggingCancel() throws {
        let expect = expectation(description: "Error log expectation")
        let expectFirstCompletion = expectation(description: "First completion expectation")
        let mockSocket = MockLogstashDestinationSocket(host: "", port: 0, timeout: 5, logActivity: true, allowUntrustedServer: true)
        mockSocket.errorState = true
        mockSocket.networkOperationCountExpectation = expect
        mockSocket.completionHandlerCalledExpectation = expectFirstCompletion
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
        let expectSecondCompletion = expectation(description: "Second completion expectation")
        mockSocket.networkOperationCountExpectation = expect2
        mockSocket.completionHandlerCalledExpectation = expectSecondCompletion
        _ = destination.send(.error, msg: "{}", thread: "", file: "", function: "", line: 0)
        destination.forceSend()
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
}

enum LogstashDestinationTestError: Error {
    case whoops
}

class MockLogstashDestinationSocket: NSObject, LogstashDestinationSocketProtocol {
    
    var networkOperationCountExpectation: XCTestExpectation?
    var completionHandlerCalledExpectation: XCTestExpectation?
    var errorState: Bool = false
    
    required init(host: String, port: UInt16, timeout: TimeInterval, logActivity: Bool, allowUntrustedServer: Bool) {
        super.init()
    }
    
    func cancel() {
        // do nothing
    }
    
    func sendLogs(_ logs: [LogTag: LogContent],
                  transform: (LogContent) -> Data,
                  queue: DispatchQueue,
                  complete: @escaping LogstashDestinationSocketProtocolCompletion) {
        
        let dispatchGroup = DispatchGroup()
        var sendStatus = [Int: Error]()
        for log in logs.sorted(by: { $0.0 < $1.0 }) {
            let tag = log.0
            _ = transform(log.1)
            dispatchGroup.enter()
            queue.asyncAfter(deadline: .now() + 0.1) {
                if let error: LogstashDestinationTestError? = self.errorState ? .whoops : nil {
                    sendStatus[tag] = error
                }
                
                self.networkOperationCountExpectation?.fulfill()
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: queue) {
            complete(sendStatus)
            self.completionHandlerCalledExpectation?.fulfill()
        }
    }
}
