//  Dictionary_JSONTests.swift

import Foundation
import XCTest
@testable import JustLog

class Dictionary_JSON: XCTestCase {
    
    func test_JSON_valid() {
        
        let input = ["k1": "v1",
                     "k2": 2.5,
                     "k3": 42,
                     "k4": true,
                     "k5": [1, 2],
                     "k6": ["k": "v"]] as [String: Any]
        
        let jsonRepresentation = input.toJSON()!
        
        XCTAssertTrue(jsonRepresentation.contains("\"k1\":\"v1\""))
        XCTAssertTrue(jsonRepresentation.contains("\"k2\":2.5"))
        XCTAssertTrue(jsonRepresentation.contains("\"k3\":42"))
        XCTAssertTrue(jsonRepresentation.contains("\"k4\":true"))
        XCTAssertTrue(jsonRepresentation.contains("\"k5\":[1,2]"))
        XCTAssertTrue(jsonRepresentation.contains("\"k6\":{\"k\":\"v\"}"))
    }
    
    func test_JSON_invalid() {
        
        let input = ["k1": "v1".data(using: String.Encoding.utf8)!] as [String: Any]
        
        let jsonRepresentation = input.toJSON()
        
        XCTAssertNil(jsonRepresentation)
    }
}
