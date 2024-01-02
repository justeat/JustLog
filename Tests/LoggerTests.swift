//  LoggerTests.swift

import XCTest
@testable import JustLog

class LoggerTests: XCTestCase {
    var sut: Logger!
    
    override func setUp() {
        super.setUp()
        sut = Logger(configuration: Configuration(), logMessageFormatter: JSONStringLogMessageFormatter(keys: FormatterKeys()))
        sut.internalLogger.removeAllDestinations()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_logger_whenSetupNotCompleted_thenLogsQueued() {
        sut.send(Log(type: .verbose, message: "Verbose Message"))
        sut.send(Log(type: .debug, message: "Debug Message"))
        sut.send(Log(type: .info, message: "Info Message"))
        sut.send(Log(type: .warning, message: "Warning Message"))
        sut.send(Log(type: .error, message: "Error Message"))
        
        XCTAssertFalse(sut.queuedLogs.isEmpty)
        XCTAssertEqual(sut.queuedLogs.count, 5)
        XCTAssertEqual(sut.queuedLogs[0].message, "Verbose Message")
        XCTAssertEqual(sut.queuedLogs[1].message, "Debug Message")
        XCTAssertEqual(sut.queuedLogs[2].message, "Info Message")
        XCTAssertEqual(sut.queuedLogs[3].message, "Warning Message")
        XCTAssertEqual(sut.queuedLogs[4].message, "Error Message")
    }
    
    func test_logger_whenSetupCompletedAfterDelay_thenQueuedLogsSent() {
        sut.send(Log(type: .verbose, message: "Verbose Message"))
        sut.send(Log(type: .debug, message: "Debug Message"))
        sut.send(Log(type: .info, message: "Info Message"))
        sut.send(Log(type: .warning, message: "Warning Message"))
        sut.send(Log(type: .error, message: "Error Message"))
        
        XCTAssertFalse(sut.queuedLogs.isEmpty)
        XCTAssertEqual(sut.queuedLogs.count, 5)
        XCTAssertEqual(sut.queuedLogs[0].message, "Verbose Message")
        XCTAssertEqual(sut.queuedLogs[1].message, "Debug Message")
        XCTAssertEqual(sut.queuedLogs[2].message, "Info Message")
        XCTAssertEqual(sut.queuedLogs[3].message, "Warning Message")
        XCTAssertEqual(sut.queuedLogs[4].message, "Error Message")
        
        sut = Logger(configuration: Configuration(), logMessageFormatter: JSONStringLogMessageFormatter(keys: FormatterKeys()))
        XCTAssertTrue(sut.queuedLogs.isEmpty)
    }
    
    func test_logger_whenLogMessagesAreSanitized_thenExpectedResultRetrived() {
        sut = MockLoggerFactory().logger
        
        var message = "conversation = {name = \\\"John Smith\\\";\\n; \\n token = \\\"123453423\\\";\\n"
        let expectedMessage = "conversation = {n***e = \\\"*****\\\";\\n; \\n t***n = \\\"*****\\\";\\n"
        
        message = sut.sanitize(message, LogType.error)
        sut.send(Log(type: .error, message: message))
        
        XCTAssertEqual(message, expectedMessage)
    }
}
