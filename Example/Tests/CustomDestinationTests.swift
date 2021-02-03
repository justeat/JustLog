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
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func log(_ string: String) {
        self.expectation.fulfill()
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

}
