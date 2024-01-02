//  LogstashDestinationSendingScheduler.swift

import Foundation

protocol LogstashDestinationSendingScheduling {
    typealias SendClosure = ([String: Any]) async throws -> Void
    func scheduleSend(_ logs: [Int: [String: Any]],
                      send: @escaping SendClosure) async -> [Int: Error]
}

struct LogstashDestinationSendingScheduler: LogstashDestinationSendingScheduling {
    struct LogResult {
        let tag: Int
        let error: Error?
    }
    
    func scheduleSend(_ logs: [Int: [String: Any]],
                      send: @escaping SendClosure) async -> [Int: Error] {
        let sendStatus = await withTaskGroup(of: LogResult.self) { group in
            for log in logs.sorted(by: { $0.0 < $1.0 }) {
                group.addTask {
                    let tag = log.0
                    do {
                        try await send(log.1)
                        return LogResult(tag: tag, error: nil)
                    } catch {
                        return LogResult(tag: tag, error: error)
                    }
                }
            }
            
            var results = [Int: Error]()
            for await result in group {
                if let error = result.error {
                    results[result.tag] = error
                }
            }
            return results
        }
        return sendStatus
    }
}
