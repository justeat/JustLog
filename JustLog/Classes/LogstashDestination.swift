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
            print("🔌 <AsyncSocket>, did receive \(challenge.protectionSpace.authenticationMethod) challenge")
        }
        if
            challenge.protectionSpace.host == self.host,
            let trust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        } else {
            if logActivity {
                print("🔌 <AsyncSocket>, Could not startTLS: invalid trust")
            }
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

public class LogstashDestination: BaseDestination  {
    
    public var logzioToken: String?
    
    var logsToShip = [Int : [String : Any]]()
    fileprivate var completionHandler: ((_ error: Error?) -> Void)?
    private let logzioTokenKey = "token"
    
    var logActivity: Bool = false
    let logDispatchQueue = OperationQueue()
    let localSocketQueue = OperationQueue()
    let session: URLSession
    fileprivate let sessionDelegate: LogstashDestinationURLSessionDelegate
    
    let allowUntrustedServer: Bool
    let host: String
    let port: Int
    let timeout: TimeInterval
    
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
        self.session.invalidateAndCancel()
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
        writeLogs()
    }
    
    func writeLogs() {
        
        self.logDispatchQueue.addOperation{ [weak self] in
            
            guard let self = self else { return }
            
            for log in self.logsToShip.sorted(by: { $0.0 < $1.0 }) {
                let tag = log.0
                let logData = self.dataToShip(log.1)
                let task = self.session.streamTask(withHostName: self.host, port: self.port)
                if !self.allowUntrustedServer {
                    task.startSecureConnection()
                }
                task.write(logData, timeout: self.timeout) { (error) in
                    if let error = error {
                        if self.logActivity {
                            print("🔌 <AsyncSocket>, did error: \(error.localizedDescription)")
                        }
                        if let completionHandler = self.completionHandler {
                            completionHandler(error)
                        }
                    } else {
                        if self.logActivity {
                            print("🔌 <AsyncSocket>, did write")
                        }
                        self.logDispatchQueue.addOperation { [weak self, tag] in
                            guard let self = self else { return }
                            self.logsToShip[tag] = nil
                        }
                        if let completionHandler = self.completionHandler {
                            completionHandler(nil)
                        }
                    }
                    
                    self.completionHandler = nil
                }
                task.resume()
            }
        }
    }
    
    func addLog(_ dict: [String: Any]) {
        logDispatchQueue.addOperation { [weak self] in
            let time = mach_absolute_time()
            let logTag = Int(truncatingIfNeeded: time)
            self?.logsToShip[logTag] = dict
            self?.writeLogs()
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
    
}
