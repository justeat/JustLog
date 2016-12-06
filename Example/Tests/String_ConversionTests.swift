import Foundation
import XCTest
@testable import JustLog

class String_Conversion: XCTestCase {
    
    func test_toDictionary_valid() {
        
        let input = "{\"k2\":2.5,\"k5\":[1,2],\"k4\":true,\"k3\":42,\"k1\":\"v1\",\"k6\":{\"k\":\"v\"}}"
        let testValue = input.toDictionary()!
        let target = ["k1": "v1",
                      "k2": 2.5,
                      "k3": 42,
                      "k4": true,
                      "k5": [1, 2],
                      "k6": ["k": "v"]] as [String : Any]
        
        XCTAssertEqual(testValue["k1"] as! String, target["k1"] as! String)
        XCTAssertEqual(testValue["k2"] as! Double, target["k2"] as! Double)
        XCTAssertEqual(testValue["k3"] as! Int, target["k3"] as! Int)
        XCTAssertEqual(testValue["k4"] as! Bool, target["k4"] as! Bool)
        XCTAssertEqual(testValue["k5"] as! [Int], target["k5"] as! [Int])
        XCTAssertEqual(testValue["k6"] as! [String : String], target["k6"] as! [String : String])
    }
    
    func test_toDictionary_invalid() {
        
        let input = "{\"k2\":2.5,\"k5\":[1,2],\"k4\":true,\"k3\":42,\"k1\":\"v1\",\"k6\":{\"k\":\"v\"}"
        let testValue = input.toDictionary()
        
        XCTAssertNil(testValue)
        
    }
    
}
