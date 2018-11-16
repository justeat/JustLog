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
        _ = Logger.shared
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
    
//    func test_metadataDictionary_ReturnsDictionaryForMetadata() {
//        let metadataDictionary = Logger.shared.metadataDictionary("thisFile.swift", "a function name", 33)
//        XCTAssert
//    }
}
