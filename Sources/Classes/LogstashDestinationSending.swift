//  LogstashDestinationSending.swift

import Foundation

protocol LogstashDestinationSending {

    typealias LogstashDestinationSendingCompletion = ([Int: Error]) -> Void
    typealias LogstashDestinationSendingTransform = ([String: Any]) -> Data

    init(host: String, port: UInt16, timeout: TimeInterval, logActivity: Bool, allowUntrustedServer: Bool)

    func cancel()

    func sendLogs(_ logs: [Int: [String: Any]],
                  transform: @escaping LogstashDestinationSendingTransform,
                  queue: DispatchQueue,
                  complete: @escaping LogstashDestinationSendingCompletion)
}
