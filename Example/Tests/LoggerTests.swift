//
//  LoggerTests.swift
//  JustLog
//
//  Created by Alkiviadis Papadakis on 24/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import JustLog

class LoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Logger.shared.internalLogger.removeAllDestinations()
    }
    
    func test_errorDictionary_ReturnsDictionaryForError() {
        let userInfo = [
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
            ] as [String : Any]
        let error = NSError(domain: "com.just-eat.error", code: 1234, userInfo: userInfo)
        let dict = Logger.shared.errorDictionary(for: error)
        
        XCTAssertNotNil(dict["user_info"])
        XCTAssertNotNil(dict["error_code"])
        XCTAssertNotNil(dict["error_domain"])
    }
    
    func test_errorDictionary_ReturnedDictionaryContainsUserInfo() {
        let userInfo = [
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
            ] as [String : Any]
        let error = NSError(domain: "com.just-eat.error", code: 1234, userInfo: userInfo)
        let dict = Logger.shared.errorDictionary(for: error)
        let dictUserInfo = dict["user_info"] as! [String : Any]
        
        XCTAssertEqual(userInfo[NSLocalizedFailureReasonErrorKey] as! String, dictUserInfo[NSLocalizedFailureReasonErrorKey] as! String)
        XCTAssertEqual(userInfo[NSLocalizedDescriptionKey] as! String, dictUserInfo[NSLocalizedDescriptionKey] as! String)
        XCTAssertEqual(userInfo[NSLocalizedRecoverySuggestionErrorKey] as! String, dictUserInfo[NSLocalizedRecoverySuggestionErrorKey] as! String)
        XCTAssertNotNil(dict["error_domain"])
    }
    
    func test_logger_whenSetupNotCompleted_thenLogsQueued() {
        let sut = Logger.shared
        sut.verbose("Verbose Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.debug("Debug Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.info("Info Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.warning("Warning Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.error("Error Message", error: nil, userInfo: nil, #file, #function, #line)
        
        XCTAssertFalse(sut.queuedLogs.isEmpty)
        XCTAssertEqual(sut.queuedLogs.count, 5)
        XCTAssertEqual(sut.queuedLogs[0].message, "Verbose Message")
        XCTAssertEqual(sut.queuedLogs[1].message, "Debug Message")
        XCTAssertEqual(sut.queuedLogs[2].message, "Info Message")
        XCTAssertEqual(sut.queuedLogs[3].message, "Warning Message")
        XCTAssertEqual(sut.queuedLogs[4].message, "Error Message")
    }
    
    func test_logger_whenSetupCompleted_thenLogsNotQueued() {
        let sut = Logger.shared
        sut.setup()
        
        sut.verbose("Verbose Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.debug("Debug Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.info("Info Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.warning("Warning Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.error("Error Message", error: nil, userInfo: nil, #file, #function, #line)
        
        XCTAssertTrue(sut.queuedLogs.isEmpty)
    }
    
    func test_logger_whenSetupCompletedAfterDelay_thenQueuedLogsSent() {
        let sut = Logger.shared
        
        sut.verbose("Verbose Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.debug("Debug Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.info("Info Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.warning("Warning Message", error: nil, userInfo: nil, #file, #function, #line)
        sut.error("Error Message", error: nil, userInfo: nil, #file, #function, #line)
        
        XCTAssertFalse(sut.queuedLogs.isEmpty)
        XCTAssertEqual(sut.queuedLogs.count, 5)
        XCTAssertEqual(sut.queuedLogs[0].message, "Verbose Message")
        XCTAssertEqual(sut.queuedLogs[1].message, "Debug Message")
        XCTAssertEqual(sut.queuedLogs[2].message, "Info Message")
        XCTAssertEqual(sut.queuedLogs[3].message, "Warning Message")
        XCTAssertEqual(sut.queuedLogs[4].message, "Error Message")
        
        sut.setup()
        
        XCTAssertTrue(sut.queuedLogs.isEmpty)
    }
    
func test_logger_whenLogMessagesAreSanitized_thenExpectedResultRetrived() {
        let sut = Logger.shared
        sut.setup()
        var message = "conversation = {name = \\\"John Smith\\\";\\n; \\n token = \\\"123453423\\\";\\n"
        let expectedMessage = "conversation = {n***e = \\\"*****\\\";\\n; \\n t***n = \\\"*****\\\";\\n"
    
        message = sut.sanitizer(message, Logger.LogType.error)
        sut.error(message, error: nil, userInfo: nil, #file, #function, #line)

        XCTAssertEqual(message, expectedMessage)
    }
}
