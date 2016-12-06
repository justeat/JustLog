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
                     "k6": ["k": "v"]] as [String : Any]
        
        let jsonRepresentation = input.toJSON()!
        
        XCTAssertTrue(jsonRepresentation.range(of: "\"k1\":\"v1\"") != nil)
        XCTAssertTrue(jsonRepresentation.range(of: "\"k2\":2.5") != nil)
        XCTAssertTrue(jsonRepresentation.range(of: "\"k3\":42") != nil)
        XCTAssertTrue(jsonRepresentation.range(of: "\"k4\":true") != nil)
        XCTAssertTrue(jsonRepresentation.range(of: "\"k5\":[1,2]") != nil)
        XCTAssertTrue(jsonRepresentation.range(of: "\"k6\":{\"k\":\"v\"}") != nil)
    }
    
    func test_JSON_invalid() {
        
        let input = ["k1": "v1".data(using: String.Encoding.utf8)!] as [String : Any]
        
        let jsonRepresentation = input.toJSON()
        
        XCTAssertNil(jsonRepresentation)
    }
    
}
