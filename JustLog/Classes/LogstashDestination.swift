//
//  LogstashDestination.swift
//  JustLog
//
//  Created by Shabeer Hussain on 06/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation
import SwiftyBeaver
import CocoaAsyncSocket

public class LogstashDestination: BaseDestination  {
    
    public var logzioToken: String?
    
    var logsToShip = [Int : [String : Any]]()
    fileprivate var completionHandler: ((_ error: Error?) -> Void)?
    private let logzioTokenKey = "token"
    
    var logActivity: Bool = false
    let logDispatchQueue = OperationQueue()
    var socketManager: AsyncSocketManager!
    
    @available(*, unavailable)
    override init() {
        fatalError()
    }
    
    public required init(host: String, port: UInt16, timeout: TimeInterval, logActivity: Bool, allowUntrustedServer: Bool = false) {
        super.init()
        self.logActivity = logActivity
        self.logDispatchQueue.maxConcurrentOperationCount = 1
        self.socketManager = AsyncSocketManager(host: host, port: port, timeout: timeout, delegate: self, logActivity: logActivity, allowUntrustedServer: allowUntrustedServer)
    }
    
    deinit {
        cancelSending()
    }
    
    public func cancelSending() {
        self.logDispatchQueue.cancelAllOperations()
        self.socketManager.disconnect()
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
        
        if self.logsToShip.count == 0 || self.socketManager.isConnected() {
            completionHandler(nil)
            return
        }

        self.completionHandler = completionHandler
        
        logDispatchQueue.addOperation { [weak self] in
            self?.socketManager.send()
        }
    }
    
    func writeLogs() {
        
        self.logDispatchQueue.addOperation{ [weak self] in
            
            guard let `self` = self else { return }
            
            for log in self.logsToShip.sorted(by: { $0.0 < $1.0 }) {
                let logData = self.dataToShip(log.1)
                self.socketManager.write(logData, withTimeout: self.socketManager.timeout, tag: log.0)
            }
            
            self.socketManager.disconnectSafely()
        }
    }
    
    func addLog(_ dict: [String: Any]) {
        let time = mach_absolute_time()
        let logTag = Int(truncatingIfNeeded: time)
        logsToShip[logTag] = dict
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

// MARK: - GCDAsyncSocketManager Delegate

extension LogstashDestination: AsyncSocketManagerDelegate {
    
    func socket(_ socket: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        logDispatchQueue.addOperation {
            self.logsToShip[tag] = nil
        }
        
        if let completionHandler = self.completionHandler {
            completionHandler(nil)
        }
        
        completionHandler = nil
    }
    
    func socketDidSecure(_ socket: GCDAsyncSocket) {
        self.writeLogs()
    }
    
    func socket(_ socket: GCDAsyncSocket, didDisconnectWithError error: Error?) {
        
        if let completionHandler = self.completionHandler {
            completionHandler(error)
        }
        
        completionHandler = nil
    }
}
 
