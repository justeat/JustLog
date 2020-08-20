//
//  LogstashDestination.swift
//  JustLog
//
//  Created by Shabeer Hussain on 06/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation
import SwiftyBeaver

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
    var logActivity: Bool = false
    public var logzioToken: String?
    
    /// Logs buffer
    private var logsToShip = [Int : [String : Any]]()
    private let logDispatchQueue: OperationQueue
    
    /// Private
    private var completionHandler: ((_ error: Error?) -> Void)?
    private let logzioTokenKey = "token"
    
    /// Socket
    private let socket: LogstashDestinationSocketProtocol
    private var logsInSocketQueue = [Int]()
    
    @available(*, unavailable)
    override init() {
        fatalError()
    }
    
    public required init(socket: LogstashDestinationSocketProtocol, logActivity: Bool) {
        self.logDispatchQueue = OperationQueue()
        self.logDispatchQueue.maxConcurrentOperationCount = 1
        self.socket = socket
        super.init()
        self.logActivity = logActivity
    }
    
    deinit {
        cancelSending()
    }
    
    public func cancelSending() {
        self.logDispatchQueue.cancelAllOperations()
        self.logDispatchQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.logsToShip = [Int : [String : Any]]()
        }
        self.logsInSocketQueue = [Int]()
        self.socket.cancel()
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
            
            let pendingLogs = Set(self.logsInSocketQueue)
            let unprocessedLogs = self.logsToShip.filter({ (tag: Int, _) -> Bool in
                !pendingLogs.contains(where: { $0 == tag })
            })
            guard !unprocessedLogs.isEmpty else {
                if self.logActivity {
                    print("writeLogs() - nothing to write, \(pendingLogs.count) in URLSession queue")
                }
                return
            }
            self.socket.sendLogs(unprocessedLogs,
                                 transform: self.dataToShip,
                                 enqueued: { self.logsInSocketQueue.append($0) }) { (tag, error) in
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
            assert(!self.logsInSocketQueue.isEmpty, "Completed a session without any tasks scheduled!")
            
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
            
            if self.logsInSocketQueue.isEmpty {
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
