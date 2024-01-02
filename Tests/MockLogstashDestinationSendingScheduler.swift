//  MockLogstashDestinationSendingScheduler.swift

import Foundation
import XCTest
@testable import JustLog

struct MockLogstashDestinationSendingScheduler: LogstashDestinationSendingScheduling {
    var networkOperationCountExpectation: XCTestExpectation?
    
    func scheduleSend(_ logs: [Int: [String: Any]], send: @escaping SendClosure) async -> [Int: Error] {
        for _ in 0..<logs.count {
            self.networkOperationCountExpectation?.fulfill()
        }
        return [:]
    }
}
