//  LogstashDestinationHTTP.swift

import Foundation

class LogstashDestinationHTTP: NSObject, LogstashDestinationSending {
    
    /// Settings
    private let allowUntrustedServer: Bool
    private let host: String
    private let timeout: TimeInterval
    private let logActivity: Bool

    private var session: URLSession
    var scheduler: LogstashDestinationSendingScheduling

    required init(host: String,
                  port: UInt16,
                  timeout: TimeInterval,
                  logActivity: Bool,
                  allowUntrustedServer: Bool = false) {

        self.allowUntrustedServer = allowUntrustedServer
        self.host = host
        self.timeout = timeout
        self.logActivity = logActivity
        self.session = URLSession(configuration: .ephemeral)
        self.scheduler = LogstashDestinationSendingScheduler()
        super.init()
    }

    /// Cancel all active tasks and invalidate the session
    func cancel() {
        self.session.invalidateAndCancel()
        self.session = URLSession(configuration: .ephemeral)
    }

    /// Create (and resume) stream tasks to send the logs provided to the server
    func sendLogs(_ logs: [Int: [String: Any]],
                  transform: @escaping LogstashDestinationSendingTransform,
                  queue: DispatchQueue,
                  complete: @escaping LogstashDestinationSendingCompletion) {
        Task {
            var components = URLComponents()
            components.scheme = "https"
            components.host = self.host
            components.path = "/applications/logging"
            guard let url = components.url else {
                complete([:])
                return
            }
            
            let sendStatus = await scheduler.scheduleSend(logs) { log in
                let logData = transform(log)
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = logData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                _ = try await self.session.data(for: request)
            }
            
            queue.async {
                complete(sendStatus)
            }
        }
    }
}
