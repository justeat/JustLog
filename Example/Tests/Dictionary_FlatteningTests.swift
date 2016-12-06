import Foundation
import XCTest
@testable import JustLog

class Dictionary_Flattening: XCTestCase {
    
    func test_merge() {
        
        let d1 = ["k1": "v1", "k2": "v2"]
        let d2 = ["k3": "v3", "k4": "v4"]
        
        let merged = d1.merged(with: d2)
        let target = ["k1": "v1", "k2": "v2", "k3": "v3", "k4": "v4"]
        
        XCTAssertEqual(merged, target)
    }
    
    func test_merge_withConflictingDictionies() {
        
        let d1 = ["k1": "v1", "k2": "v2"]
        let d2 = ["k1": "v1b", "k3": "v3"]
        
        let merged = d1.merged(with: d2)
        let target = ["k1": "v1b", "k2": "v2", "k3": "v3"]
        
        XCTAssertEqual(merged, target)
    }
    
    func test_flattened() {
        
        let domain = "com.justeat.dictionary"
        let error = NSError(domain: domain, code: 200, userInfo: ["k8": "v8"])
        let nestedError = NSError(domain: domain, code: 200, userInfo: [NSUnderlyingErrorKey: NSError(domain: domain, code: 200, userInfo: ["k10": 10])])
        let input = ["k1": "v1", "k2": ["k3": "v3"], "k4": 4, "k5": 5.1, "k6": true,
                     "k7": error, "k9": nestedError, "k11": [1, 2, 3]] as [String : Any]
        
        let flattened = input.flattened()
        
        XCTAssertEqual(flattened.keys.count, 8)
        XCTAssertEqual(flattened["k1"] as! String, "v1")
        XCTAssertEqual(flattened["k3"] as! String, "v3")
        XCTAssertEqual(flattened["k4"] as! Int, 4)
        XCTAssertEqual(flattened["k5"] as! Double, 5.1)
        XCTAssertEqual(flattened["k6"] as! Bool, true)
        XCTAssertEqual(flattened["k8"] as! String, "v8")
        XCTAssertEqual(flattened["k10"] as! Int, 10)
        XCTAssertEqual(flattened["k11"] as! String, "[1, 2, 3]")
    }
    
    func test_flattened_withConflictingDictionies() {
        
        let input = ["k1": "v1", "k2": ["k1": "v3", "k4": "v4"]] as [String : Any]
        
        let flattened = input.flattened()
        // can be either ["k1": "v1", "k4": "v4"] or ["k1": "v3", "k4": "v4"]
        
        XCTAssertEqual(flattened.keys.count, 2)
        XCTAssertNotNil(flattened["k1"])
        XCTAssertEqual(flattened["k4"] as! String, "v4")
    }
    
    func test_flattened_recursive() {
        
        let input = ["k1": "v1",
                     "k2": ["k3": "v3",
                            "k4": ["k5": "v5"]]] as [String : Any]
        
        let flattened = input.flattened()
        // target = ["k1": "v1", "k3": "v3", "k5": "v5"] as [String : Any]
        
        XCTAssertEqual(flattened.keys.count, 3)
        XCTAssertEqual(flattened["k1"] as! String, "v1")
        XCTAssertEqual(flattened["k3"] as! String, "v3")
        XCTAssertEqual(flattened["k5"] as! String, "v5")
    }
    
}
