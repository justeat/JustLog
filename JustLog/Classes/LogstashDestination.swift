//
//  LogstashDestination.swift
//  JustLog
//
//  Created by Shabeer Hussain on 06/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation
import SwiftyBeaver

typealias LogContent = [String: Any]
typealias LogTag = Int

/// This entire class relies on `operationQueue` to synchronise access to the `logsToShip` dictionary
/// Every action is put in the `operationQueue` which is synchronous, even though the actual sending
/// via `URLSession` is not. The writers' completion handler are executed on the underlying queue of the `OperationQueue`
/// Here's a brief summary of what operations are added to the queue and when:
/// A log is generated via `send` and added to the `logsToShip` dictionary (along with a `tag` identifier).
/// At some point `writeLogs` is called that creates an `NSURLSessionStreamTask` to send the log to the server.
/// When the writer finish all streams operation it calls the completion handler passing the logs that failed to push.
/// Those logs are added back to `logsToShip`
/// An optional `completionHandler` is called when all logs existing before the `forceSend` call have been tried to send once.
public class LogstashDestination: BaseDestination  {
    
    /// Settings
    var shouldLogActivity: Bool = false
    public var logzioToken: String?
    
    /// Logs buffer
    private var logsToShip = [LogTag: LogContent]()
    private let operationQueue: OperationQueue
    private let dispatchQueue = DispatchQueue(label: "com.justlog.LogstashDestination.dispatchQueue", qos: .utility)
    /// Private
    private let logzioTokenKey = "token"
    
    /// Socket
    private let socket: LogstashDestinationSocketProtocol
    
    @available(*, unavailable)
    override init() {
        fatalError()
    }
    
    public required init(socket: LogstashDestinationSocketProtocol, logActivity: Bool) {
        self.operationQueue = OperationQueue()
        self.operationQueue.underlyingQueue = dispatchQueue
        self.operationQueue.maxConcurrentOperationCount = 1
        self.operationQueue.name = "com.justlog.LogstashDestination.operationQueue"
        self.socket = socket
        super.init()
        self.shouldLogActivity = logActivity
    }
    
    deinit {
        cancelSending()
    }
    
    public func cancelSending() {
        self.operationQueue.cancelAllOperations()
        self.operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            self.logsToShip = [LogTag: LogContent]()
        }
        self.socket.cancel()
    }
    
    // MARK: - Log dispatching

    override public func send(_ level: SwiftyBeaver.Level,
                              msg: String,
                              thread: String,
                              file: String,
                              function: String,
                              line: Int,
                              context: Any? = nil) -> String? {
        
        if let dict = msg.toDictionary() {
            var flattened = dict.flattened()
            if let logzioToken = logzioToken {
                flattened = flattened.merged(with: [logzioTokenKey: logzioToken])
            }
            addLog(flattened)
        }
        
        return nil
    }

    private func addLog(_ dict: LogContent) {
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            
            let time = mach_absolute_time()
            let logTag = Int(truncatingIfNeeded: time)
            self.logsToShip[logTag] = dict
        }
    }

    public func forceSend(_ completionHandler: @escaping (_ error: Error?) -> Void = {_ in }) {
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            let writer = LogstashDestinationWriter(socket: self.socket, shouldLogActivity: self.shouldLogActivity)
            let logsBatch = self.logsToShip
            self.logsToShip = [LogTag: LogContent]()
            writer.write(logs: logsBatch, queue: self.dispatchQueue) { [weak self] missing, error in
                guard let self = self else {
                    completionHandler(error)
                    return
                }
                
                if let unsent = missing {
                    self.logsToShip.merge(unsent) { lhs, rhs in lhs }
                    self.printActivity("🔌 <LogstashDestination>, \(unsent.count) failed tasks")
                }
                completionHandler(error)
            }
        }
    }
}

extension LogstashDestination {
    
    private func printActivity(_ string: String) {
        guard shouldLogActivity else { return }
        print(string)
    }
}
