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
    
}
