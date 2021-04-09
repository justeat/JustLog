//
//  LogstashDestinationSocket.swift
//  JustLog
//
//  Created by Antonio Strijdom on 29/06/2020.
//  Copyright © 2020 Just Eat. All rights reserved.
//

import Foundation

public protocol LogstashDestinationSocketProtocol {
    typealias LogstashDestinationSocketProtocolEnqueued = (Int) -> Void
    typealias LogstashDestinationSocketProtocolCompletion = (Int, Error?) -> Void
    typealias LogstashDestinationSocketProtocolTransform = ([String: Any]) -> Data
    init(host: String, port: UInt16, timeout: TimeInterval, logActivity: Bool, allowUntrustedServer: Bool)
    func cancel()
    func sendLogs(_ logs: [Int: [String: Any]], transform: LogstashDestinationSocketProtocolTransform, enqueued: LogstashDestinationSocketProtocolEnqueued?, complete: @escaping LogstashDestinationSocketProtocolCompletion)
}

class LogstashDestinationSocket: NSObject, LogstashDestinationSocketProtocol {
    
    /// Settings
    private let allowUntrustedServer: Bool
    private let host: String
    private let port: Int
    private let timeout: TimeInterval
    private let logActivity: Bool
    
    private let localSocketQueue = OperationQueue()
    private let sessionDelegate: LogstashDestinationURLSessionDelegate
    private var session: URLSession
    
    required init(host: String,
                  port: UInt16,
                  timeout: TimeInterval,
                  logActivity: Bool,
                  allowUntrustedServer: Bool = false) {
        
        self.allowUntrustedServer = allowUntrustedServer
        self.host = host
        self.port = Int(port)
        self.timeout = timeout
        self.logActivity = logActivity
        self.sessionDelegate = LogstashDestinationURLSessionDelegate(host: host, logActivity: logActivity)
        self.session = URLSession(configuration: .ephemeral,
                                  delegate: self.sessionDelegate,
                                  delegateQueue: localSocketQueue)
        self.localSocketQueue.name = "com.justlog.localSocketDispatchQueue"
        super.init()
    }
    
    /// Cancel all active tasks and invalidate the session
    func cancel() {
        self.session.invalidateAndCancel()
        self.session = URLSession(configuration: .ephemeral,
                                  delegate: sessionDelegate,
                                  delegateQueue: localSocketQueue)
    }
    
    /// Create (and resume) stream tasks to send the logs provided to the server
    func sendLogs(_ logs: [Int: [String: Any]], transform: LogstashDestinationSocketProtocolTransform, enqueued: LogstashDestinationSocketProtocolEnqueued?, complete: @escaping LogstashDestinationSocketProtocolCompletion) {
        
        let task = self.session.streamTask(withHostName: self.host, port: self.port)
        if !self.allowUntrustedServer {
            task.startSecureConnection()
        }
        for log in logs.sorted(by: { $0.0 < $1.0 }) {
            let tag = log.0
            let logData = transform(log.1)
            task.write(logData, timeout: self.timeout) { (error) in
                complete(tag, error)
            }
            if let enqueued = enqueued {
                enqueued(tag)
            }
        }
        task.resume()
    }
}

private class LogstashDestinationURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionStreamDelegate {
    private let host: String
    private let logActivity: Bool
    
    init(host: String, logActivity: Bool) {
        self.host = host
        self.logActivity = logActivity
        super.init()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if logActivity {
            print("🔌 <LogstashDestination>, did receive \(challenge.protectionSpace.authenticationMethod) challenge")
        }
        if
            challenge.protectionSpace.host == self.host,
            let trust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        } else {
            if logActivity {
                print("🔌 <LogstashDestination>, Could not startTLS: invalid trust")
            }
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
