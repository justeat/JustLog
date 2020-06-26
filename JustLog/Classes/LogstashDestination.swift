//
//  LogstashDestination.swift
//  JustLog
//
//  Created by Shabeer Hussain on 06/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation
import SwiftyBeaver

private class LogstashDestinationURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionStreamDelegate {
    let host: String
    let logActivity: Bool
    
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

/// This entire class relies on `logDispatchQueue` to synchronise access to the `logsToShip` dictionary
/// Every action is put in the `logDispatchQueue` which is synchronous, even though the actual sending
/// via `URLSession` is not.
/// Here's a brief summary of what operations are added to the queue and when:
/// A log is generated via `send` and added to the `logsToShip` dictionary (along with a `tag` identifier).
/// At some point `writeLogs` is called that creates an `NSURLSessionStreamTask` to send the log to the server.
/// When the task completes, either `completeLog` or `retryLog` are called.
///    `completeLog` removes the log from `logsToShip`
///    `retryLog` clears the log from `logsInSocketQueue` and causes it to be resent the next time `writeLogs` is called.
/// An optional `completionHandler` is called when all logs are written.
public class LogstashDestination: BaseDestination  {
    
    /// Settings
    let allowUntrustedServer: Bool
    let host: String
    let port: Int
    let timeout: TimeInterval
    var logActivity: Bool = false
    public var logzioToken: String?
    
    /// Logs buffer
    var logsToShip = [Int : [String : Any]]()
    let logDispatchQueue = OperationQueue()
    
    /// Private
    private var completionHandler: ((_ error: Error?) -> Void)?
    private let logzioTokenKey = "token"
    
    /// Socket
    private let localSocketQueue = OperationQueue()
    private var session: URLSession
    private let sessionDelegate: LogstashDestinationURLSessionDelegate
    private var logsInSocketQueue = [Int]()
    
    @available(*, unavailable)
    override init() {
        fatalError()
    }
    
    public required init(host: String, port: UInt16, timeout: TimeInterval, logActivity: Bool, allowUntrustedServer: Bool = false) {
        
        self.allowUntrustedServer = allowUntrustedServer
        self.host = host
        self.port = Int(port)
        self.timeout = timeout
        self.sessionDelegate = LogstashDestinationURLSessionDelegate(host: host, logActivity: logActivity)
        self.session = URLSession(configuration: .ephemeral,
                                  delegate: sessionDelegate,
                                  delegateQueue: localSocketQueue)
        super.init()
        self.logActivity = logActivity
        self.logDispatchQueue.maxConcurrentOperationCount = 1
    }
    
    deinit {
        cancelSending()
    }
    
    public func cancelSending() {
        self.logDispatchQueue.cancelAllOperations()
        self.logsInSocketQueue = [Int]()
        self.session.invalidateAndCancel()
        self.session = URLSession(configuration: .ephemeral,
                                  delegate: sessionDelegate,
                                  delegateQueue: localSocketQueue)
    }
    
    // MARK: - Log dispatching

    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String,
                              function: String, line: Int, context: Any? = nil) -> String? {
        
        if let dict = msg.toDictionary() {
            var flattened = dict.flattened()
            if let logzioToken = logzioToken {
                flattened = flattened.merged(with: [logzioTokenKey: logzioToken])
            }
            addLog(flattened)
        }
        
        return nil
    }

    public func forceSend(_ completionHandler: @escaping (_ error: Error?) -> Void  = {_ in }) {

        self.completionHandler = completionHandler

        writeLogs()
    }
    
    func writeLogs() {
        
        self.logDispatchQueue.addOperation{ [weak self] in
            
            guard let self = self else { return }
            
            let logsInQueue = self.logsInSocketQueue
            let unprocessedLogs = self.logsToShip.filter({ (tag: Int, _) -> Bool in
                !logsInQueue.contains(where: { $0 == tag })
            })
            guard unprocessedLogs.count > 0 else {
                if self.logActivity {
                    print("writeLogs() - nothing to write, \(logsInQueue.count) in URLSession queue")
                }
                return
            }
            let task = self.session.streamTask(withHostName: self.host, port: self.port)
            if !self.allowUntrustedServer {
                task.startSecureConnection()
            }
            for log in unprocessedLogs.sorted(by: { $0.0 < $1.0 }) {
                let tag = log.0
                let logData = self.dataToShip(log.1)
                task.write(logData, timeout: self.timeout) { (error) in
                    if let error = error {
                        if self.logActivity {
                            print("🔌 <LogstashDestination>, \(tag) did error: \(error.localizedDescription)")
                        }
                        self.retryLog(withTag: tag)
                        self.callCompleteHandlerIfRequired(optionalError: error)
                    } else {
                        if self.logActivity {
                            print("🔌 <LogstashDestination>, did write \(tag)")
                        }
                        self.completeLog(withTag:tag)
                        self.callCompleteHandlerIfRequired()
                    }
                }
                self.logsInSocketQueue.append(tag)
            }
            task.resume()
        }
    }
    
    func addLog(_ dict: [String: Any]) {
        logDispatchQueue.addOperation { [weak self] in
            let time = mach_absolute_time()
            let logTag = Int(truncatingIfNeeded: time)
            self?.logsToShip[logTag] = dict
        }
    }
    
    func dataToShip(_ dict: [String: Any]) -> Data {
        
        var data = Data()
        
        do {
            data = try JSONSerialization.data(withJSONObject:dict, options:[])
            
            if let encodedData = "\n".data(using: String.Encoding.utf8) {
                data.append(encodedData)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return data
    }
    
    func completeLog(withTag tag: Int) {
        
        self.logDispatchQueue.addOperation{ [weak self] in
            guard let self = self else { return }
            assert(self.logsInSocketQueue.count > 0, "Completed a session without any tasks scheduled!")
            
            // get the tag for this task & remove from queue
            if self.logsInSocketQueue.contains(tag) {
                self.logsInSocketQueue.removeAll(where: { $0 == tag })
                self.logsToShip[tag] = nil
            } else {
                if self.logActivity {
                    print("🔌 <LogstashDestination>, Completed task for tag (\(tag)")
                }
            }
            
            if self.logActivity {
                print("🔌 <LogstashDestination>, \(self.logsInSocketQueue.count) remaining tasks")
            }
        }
    }
    
    func retryLog(withTag tag: Int) {
        
        self.logDispatchQueue.addOperation{ [weak self] in
            guard let self = self else { return }
            
            // get the tag for this task & remove from queue
            if self.logsInSocketQueue.contains(tag) {
                self.logsInSocketQueue.removeAll(where: { $0 == tag })
            }
            
            if self.logActivity {
                print("🔌 <LogstashDestination>, \(self.logsInSocketQueue.count) remaining tasks")
            }
        }
    }
    
    func callCompleteHandlerIfRequired(optionalError error: Error? = nil) {
        
        self.logDispatchQueue.addOperation { [weak self] in
            guard let self = self else { return }
            
            if self.logsInSocketQueue.count <= 0 {
                if let completionHandler = self.completionHandler {
                    if self.logActivity {
                        print("🔌 <LogstashDestination>, calling completion handler")
                    }
                    completionHandler(error)
                }
                self.completionHandler = nil
            }
        }
    }
    
}
