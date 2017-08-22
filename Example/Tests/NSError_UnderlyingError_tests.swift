//
//  NSError_UnderlyingError_tests.swift
//  JustLog
//
//  Created by Alkiviadis Papadakis on 22/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import JustLog

class NSError_UnderlyingError_tests: XCTestCase {

    func test_ErrorChain_ReturnsArrayOfAssociatedErrorsIncludingSelf() {
        
        let innerInnerUserInfoError = [
            NSLocalizedFailureReasonErrorKey: "inner inner error value",
            NSLocalizedDescriptionKey: "inner inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner inner recovery suggestion"
            ] as [String : Any]
        
        let innerInnerError: NSError = NSError(domain: "com.just-eat.test.inner.inner", code: 9999, userInfo: innerInnerUserInfoError)
        let underlyingReadableUserInfoError = [
            NSUnderlyingErrorKey: innerInnerError,
            NSLocalizedFailureReasonErrorKey: "inner error value",
            NSLocalizedDescriptionKey: "inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner recovery suggestion"
            ] as [String : Any]
        
        let innerError: NSError = NSError(domain: "com.just-eat.test.inner", code: 5678, userInfo: underlyingReadableUserInfoError)
        let readableUserInfos = [
            NSUnderlyingErrorKey: innerError,
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
            ] as [String : Any]
        
        let error = NSError(domain: "com.just-eat.test", code:1234, userInfo:readableUserInfos)
        let associatedErrors = error.errorChain()
        
        XCTAssertTrue(associatedErrors.contains(innerInnerError))
        XCTAssertTrue(associatedErrors.contains(innerError))
        XCTAssertTrue(associatedErrors.contains(error))
    }
    
    func test_underlyingErrors_ReturnsArrayOfAssociatedErrorsExcludingSelf() {
        
        let innerInnerUserInfoError = [
            NSLocalizedFailureReasonErrorKey: "inner inner error value",
            NSLocalizedDescriptionKey: "inner inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner inner recovery suggestion"
            ] as [String : Any]
        
        let innerInnerError: NSError = NSError(domain: "com.just-eat.test.inner.inner", code: 9999, userInfo: innerInnerUserInfoError)
        let underlyingReadableUserInfoError = [
            NSUnderlyingErrorKey: innerInnerError,
            NSLocalizedFailureReasonErrorKey: "inner error value",
            NSLocalizedDescriptionKey: "inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner recovery suggestion"
            ] as [String : Any]
        
        let innerError: NSError = NSError(domain: "com.just-eat.test.inner", code: 5678, userInfo: underlyingReadableUserInfoError)
        let readableUserInfos = [
            NSUnderlyingErrorKey: innerError,
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
            ] as [String : Any]
        
        let error = NSError(domain: "com.just-eat.test", code:1234, userInfo:readableUserInfos)
        let associatedErrors = error.underlyingErrors()
        
        XCTAssertTrue(associatedErrors.contains(innerInnerError))
        XCTAssertTrue(associatedErrors.contains(innerError))
        XCTAssertFalse(associatedErrors.contains(error))
    }
    
    func test_disassociatedErrorChain_ReturnsArrayOfNonAssociatedErrorsIncludingSelfWithNoUnderlyingErrorKey() {
        
        let innerInnerUserInfoError = [
            NSLocalizedFailureReasonErrorKey: "inner inner error value",
            NSLocalizedDescriptionKey: "inner inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner inner recovery suggestion"
            ] as [String : Any]
        
        let innerInnerError: NSError = NSError(domain: "com.just-eat.test.inner.inner", code: 9999, userInfo: innerInnerUserInfoError)
        let underlyingReadableUserInfoError = [
            NSUnderlyingErrorKey: innerInnerError,
            NSLocalizedFailureReasonErrorKey: "inner error value",
            NSLocalizedDescriptionKey: "inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner recovery suggestion"
            ] as [String : Any]
        
        let innerError: NSError = NSError(domain: "com.just-eat.test.inner", code: 5678, userInfo: underlyingReadableUserInfoError)
        let readableUserInfos = [
            NSUnderlyingErrorKey: innerError,
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
            ] as [String : Any]
        
        let error = NSError(domain: "com.just-eat.test", code:1234, userInfo:readableUserInfos)
        let associatedErrors = error.disassociatedErrorChain()
        
        XCTAssertTrue(associatedErrors.count == 3)
        for error in associatedErrors {
            XCTAssertFalse(error.userInfo[NSUnderlyingErrorKey] != nil)
        }
    }
}
