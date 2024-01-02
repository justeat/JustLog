//  JSONStringLogMessageFormatterTests.swift

import XCTest
@testable import JustLog

class JSONStringLogMessageFormatterTests: XCTestCase {
    
    func test_errorDictionary_returnDictionaryForError() {
        let userInfo = [
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
        ] as [String: Any]
        let error = NSError(domain: "com.just-eat.error", code: 1234, userInfo: userInfo)
        
        let sut = JSONStringLogMessageFormatter(keys: FormatterKeys())
        let dict = sut.errorDictionary(for: error)
        
        XCTAssertNotNil(dict["user_info"])
        XCTAssertNotNil(dict["error_code"])
        XCTAssertNotNil(dict["error_domain"])
    }
    
    func test_errorDictionary_returnDictionaryContainsUserInfo() {
        let userInfo = [
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
        ] as [String: Any]
        let error = NSError(domain: "com.just-eat.error", code: 1234, userInfo: userInfo)
        
        let sut = JSONStringLogMessageFormatter(keys: FormatterKeys())
        let dict = sut.errorDictionary(for: error)
        let dictUserInfo = dict["user_info"] as! [String: Any]
        
        XCTAssertEqual(userInfo[NSLocalizedFailureReasonErrorKey] as! String, dictUserInfo[NSLocalizedFailureReasonErrorKey] as! String)
        XCTAssertEqual(userInfo[NSLocalizedDescriptionKey] as! String, dictUserInfo[NSLocalizedDescriptionKey] as! String)
        XCTAssertEqual(userInfo[NSLocalizedRecoverySuggestionErrorKey] as! String, dictUserInfo[NSLocalizedRecoverySuggestionErrorKey] as! String)
        XCTAssertNotNil(dict["error_domain"])
    }
    
    func test_metadataDictionary_returnDictionaryContainsMetadata() {
        let keys = FormatterKeys()
        
        let iosVersion = UIDevice.current.systemVersion
        let deviceType = UIDevice.current.platform()
        let appBundleID = Bundle.main.bundleIdentifier
        
        let sut = JSONStringLogMessageFormatter(keys: keys)
        let metadata = sut.metadataDictionary("TestFile", "testFunc", 42)
        
        XCTAssertEqual(metadata[keys.iosVersionKey] as! String, iosVersion)
        XCTAssertEqual(metadata[keys.deviceTypeKey] as! String, deviceType)
        XCTAssertEqual(metadata[keys.appBundleIDKey] as? String, appBundleID)
    }
    
    func test_formatterKeys_canBeOverriden() {
        var keys = FormatterKeys()
        keys.fileKey = "NotFileKey"
        keys.functionKey = "NotFunctionKey"
        keys.lineKey = "NotLineKey"
        
        let sut = JSONStringLogMessageFormatter(keys: keys)
        let metadata = sut.metadataDictionary("TestFile", "testFunc", 42)
        
        XCTAssertEqual(metadata["NotFileKey"] as! String, "TestFile")
        XCTAssertEqual(metadata["NotFunctionKey"] as! String, "testFunc")
        XCTAssertEqual(metadata["NotLineKey"] as! String, "42")
    }
    
    func test_formattedLogMessage_haveDeviceTimestampAsMetadata() throws {
        let sut = JSONStringLogMessageFormatter(keys: FormatterKeys())
        let log = Log(type: .error, message: "Log message")
        
        let message = sut.format(log)
        
        let data = try XCTUnwrap(message.data(using: .utf8))
        guard let parsedMessage = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            XCTFail("Failed to parse log message")
            return
        }
        
        let parsedMetadata = try XCTUnwrap(parsedMessage["metadata"] as? [String: String])
        _ = try XCTUnwrap(parsedMetadata["device_timestamp"])
    }
    
    func test_format_returnsNotEmptyString() {
        let log = Log(type: .error, message: "Log message")
        
        let sut = JSONStringLogMessageFormatter(keys: FormatterKeys())
        let string = sut.format(log)
        
        XCTAssertFalse(string.isEmpty)
    }
}
