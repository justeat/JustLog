import UIKit
import XCTest
@testable import JustLog

class NSError_Flattening: XCTestCase {
    
    func test_GivenAnError_WhenCallingHumanReadableError_ThenUserInfoContainsReadableErrors() {
        
        // Given
        let unreadableUserInfos = [
            NSLocalizedFailureReasonErrorKey: "error value".data(using: String.Encoding.utf8)!,
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion".data(using: String.Encoding.utf8)!
            ] as [String : Any]
        
        let readableUserInfos = [
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
        ]
        
        let unreadableError = NSError(domain: "com.just-eat.test", code:1234, userInfo:unreadableUserInfos)
        let expectedReadableError = NSError(domain: "com.just-eat.test", code:1234, userInfo:readableUserInfos)
        
        // When
        let readableError = unreadableError.humanReadableError()
        
        // Then
        XCTAssertEqual(expectedReadableError, readableError)
    }
    
    func test_GivenAnErrorWithUnderlyingError_WhenCallingHumanReadableError_ThenUserInfoContainsReadableErrors() {
        
        // Given
        let underlyingUnreadableUserInfoError = [
            NSLocalizedFailureReasonErrorKey: "inner error value".data(using: String.Encoding.utf8)!,
            NSLocalizedDescriptionKey: "inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner recovery suggestion".data(using: String.Encoding.utf8)!
            ] as [String : Any]
        
        let underlyingReadableUserInfoError = [
            NSLocalizedFailureReasonErrorKey: "inner error value",
            NSLocalizedDescriptionKey: "inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner recovery suggestion"
            ] as [String : Any]
        
        let unreadableUserInfos = [
            NSUnderlyingErrorKey: NSError(domain: "com.just-eat.test.inner", code: 5678, userInfo: underlyingUnreadableUserInfoError),
            NSLocalizedFailureReasonErrorKey: "error value".data(using: String.Encoding.utf8)!,
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion".data(using: String.Encoding.utf8)!
            ] as [String : Any]
        
        let readableUserInfos = [
            NSUnderlyingErrorKey: NSError(domain: "com.just-eat.test.inner", code: 5678, userInfo: underlyingReadableUserInfoError),
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
        ] as [String : Any]
        
        let unreadableError = NSError(domain: "com.just-eat.test", code:1234, userInfo:unreadableUserInfos)
        let expectedReadableError = NSError(domain: "com.just-eat.test", code:1234, userInfo:readableUserInfos)
        
        // When
        let readableError = unreadableError.humanReadableError()
        
        // Then
        XCTAssertEqual(expectedReadableError, readableError)
    }
    
    func test_GivenAnErrorWithUnderlyingError_WhenCallingLogMessage_ThenJsonStructureOfErrorShouldBeReturned() {
        
        let innerInnerUserInfoError = [
            NSLocalizedFailureReasonErrorKey: "inner inner error value",
            NSLocalizedDescriptionKey: "inner inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner inner recovery suggestion"
            ] as [String : Any]
        
        let underlyingReadableUserInfoError = [
            NSUnderlyingErrorKey: NSError(domain: "com.just-eat.test.inner.inner", code: 9999, userInfo: innerInnerUserInfoError),
            NSLocalizedFailureReasonErrorKey: "inner error value",
            NSLocalizedDescriptionKey: "inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner recovery suggestion"
            ] as [String : Any]
        
        let readableUserInfos = [
            NSUnderlyingErrorKey: NSError(domain: "com.just-eat.test.inner", code: 5678, userInfo: underlyingReadableUserInfoError),
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
            ] as [String : Any]
        
        let unreadableError = NSError(domain: "com.just-eat.test", code:1234, userInfo:readableUserInfos)
        
        let errors = unreadableError.underlyingErrors()
        let errorsIncludingSelf = unreadableError.errorChain()
        XCTAssertEqual(errors.count, 2)
        XCTAssertEqual(errorsIncludingSelf.count, 3)
        
        let message = Logger.shared.logMessage("Message to attach", error: unreadableError, userInfo: ["SomeCustomKey" : "SomeCustomValue"], #file, #function, #line)
        
//        let target = "{\"metadata\":{\"file\":\"NSError_ReadabilityTests.swift\",\"je_feature_version\":\"1.2.0 (1)\",\"je_ios_version\":\"10.3.1\",\"function\":\"test_GivenAnErrorWithUnderlyingError_WhenCallingLogMessage_ThenJsonStructureOfErrorShouldBeReturned()\",\"je_ios_device\":\"x86_64\",\"line\":\"100\"},\"userInfo\":{\"error_code\":[1234,5678,9999],\"je_environment\":\"production\",\"x-je-conversation\":\"FB7DF45D-F491-49DE-B9BF-EABAAC2F95E8\",\"error_domain\":[\"com.just-eat.test\",\"com.just-eat.test.inner\",\"com.just-eat.test.inner.inner\"],\"SomeCustomKey\":\"SomeCustomValue\",\"NSLocalizedDescription\":[\"inner inner description\",\"inner inner description\",\"inner inner description\"],\"NSLocalizedRecoverySuggestion\":[\"inner inner recovery suggestion\",\"inner inner recovery suggestion\",\"inner inner recovery suggestion\"],\"je_feature\":\"ios cia\",\"je_tenant\":\"UK\",\"NSLocalizedFailureReason\":[\"error value\",\"inner error value\",\"inner inner error value\"]},\"message\":\"Message to attach\"}"
//        
//        XCTAssertTrue(message == target)
        
//        let data = JSONSerialization.jsonObject(with: target.data(using: .utf8), options: .allowFragments)
        print(message)
        
    }
}
