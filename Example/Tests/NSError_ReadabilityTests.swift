//  NSError_ReadabilityTests.swift

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
            ] as [String: Any]
        
        let readableUserInfos = [
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
        ]
        
        let unreadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: unreadableUserInfos)
        let expectedReadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: readableUserInfos)
        
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
            ] as [String: Any]
        
        let underlyingReadableUserInfoError = [
            NSLocalizedFailureReasonErrorKey: "inner error value",
            NSLocalizedDescriptionKey: "inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner recovery suggestion"
            ] as [String: Any]
        
        let unreadableUserInfos = [
            NSUnderlyingErrorKey: NSError(domain: "com.just-eat.test.inner", code: 5678, userInfo: underlyingUnreadableUserInfoError),
            NSLocalizedFailureReasonErrorKey: "error value".data(using: String.Encoding.utf8)!,
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion".data(using: String.Encoding.utf8)!
            ] as [String: Any]
        
        let readableUserInfos = [
            NSUnderlyingErrorKey: NSError(domain: "com.just-eat.test.inner", code: 5678, userInfo: underlyingReadableUserInfoError),
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion"
        ] as [String: Any]
        
        let unreadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: unreadableUserInfos)
        let expectedReadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: readableUserInfos)
        
        // When
        let readableError = unreadableError.humanReadableError()
        
        // Then
        XCTAssertEqual(expectedReadableError, readableError)
    }
    
    func test_GivenAnErrorUserInfoWithNSObject_WhenCallingHumanReadableError_ThenUserInfoContainsDescription() {
        
        // Given
        let nsObjectKey = "UnreadableNSObjectKey"
        let nsObjectValue: NSObject = NSURL(string: "https://just-eat.com")!
        
        let unreadableUserInfos = [
            NSLocalizedFailureReasonErrorKey: "error value".data(using: String.Encoding.utf8)!,
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion".data(using: String.Encoding.utf8)!,
            nsObjectKey: nsObjectValue
            ] as [String: Any]
        
        let readableUserInfos = [
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion",
            nsObjectKey: "https://just-eat.com"
        ]
        
        let unreadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: unreadableUserInfos)
        let expectedReadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: readableUserInfos)
        
        // When
        let readableError = unreadableError.humanReadableError()
        
        // Then
        XCTAssertEqual(expectedReadableError, readableError)
    }
    
    func test_GivenAnErrorUserInfoWithCustomStringConvertible_WhenCallingHumanReadableError_ThenUserInfoContainsDescription() {
        
        // Given
        enum ReadableEnum: CustomStringConvertible {
            var description: String { "nonSerializable" }
            
            case nonSerializable
        }
        
        let enumKey = "UnreadableEnumKey"
        let enumValue: ReadableEnum = .nonSerializable
        
        let unreadableUserInfos = [
            NSLocalizedFailureReasonErrorKey: "error value".data(using: String.Encoding.utf8)!,
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion".data(using: String.Encoding.utf8)!,
            enumKey: enumValue
            ] as [String: Any]
        
        let readableUserInfos = [
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion",
            enumKey: "nonSerializable"
        ]
        
        let unreadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: unreadableUserInfos)
        let expectedReadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: readableUserInfos)
        
        // When
        let readableError = unreadableError.humanReadableError()
        
        // Then
        XCTAssertEqual(expectedReadableError, readableError)
    }
    
    func test_GivenAnErrorUserInfoWithPlainSwiftObject_WhenCallingHumanReadableError_ThenUserInfoContainsDefaultMessage() {
        
        // Given
        enum UnreadableEnum {
            case nonSerializable
        }
        
        let enumKey = "UnreadableEnumKey"
        let enumValue: UnreadableEnum = .nonSerializable
        
        let unreadableUserInfos = [
            NSLocalizedFailureReasonErrorKey: "error value".data(using: String.Encoding.utf8)!,
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion".data(using: String.Encoding.utf8)!,
            enumKey: enumValue
            ] as [String: Any]
        
        let readableUserInfos = [
            NSLocalizedFailureReasonErrorKey: "error value",
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion",
            enumKey: "The value for key 'UnreadableEnumKey' can't be serialised"
        ]
        
        let unreadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: unreadableUserInfos)
        let expectedReadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: readableUserInfos)
        
        // When
        let readableError = unreadableError.humanReadableError()
        
        // Then
        XCTAssertEqual(expectedReadableError, readableError)
    }
}
