//
//  AsyncSocketManager.swift
//  JustLog
//
//  Created by Shabeer Hussain on 06/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

protocol AsyncSocketManagerDelegate: class {
    func socketDidSecure(_ socket: GCDAsyncSocket)
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16)
    func socket(_ socket: GCDAsyncSocket, didWriteDataWithTag tag: Int)
    func socket(_ socket: GCDAsyncSocket, didDisconnectWithError error: Error?)
}

class AsyncSocketManager: NSObject {
 
    enum AsyncSocketError: Error {
        case failedConnection
    }
    
    fileprivate weak var delegate: AsyncSocketManagerDelegate?
    fileprivate var socket: GCDAsyncSocket!
    fileprivate var logActivity: Bool
    
    let host: String
    let port: UInt16
    let timeout: TimeInterval
    var allowUntrustedServer: Bool
    var useSecureSocket: Bool

    let localSocketQueue = DispatchQueue(label: "com.justeat.gcdAsyncSocketDelegateQueue")
    
    init(host: String, port: UInt16, timeout: TimeInterval, delegate: AsyncSocketManagerDelegate, logActivity: Bool, useSecureSocket: Bool, allowUntrustedServer: Bool) {
        
        self.host = host
        self.port = port
        self.timeout = timeout
        self.delegate = delegate
        self.logActivity = logActivity
        self.useSecureSocket = useSecureSocket
        self.allowUntrustedServer = allowUntrustedServer
        super.init()
        
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: localSocketQueue)
    }
    
    func send() {
        if !self.socket.isConnected {
            do {
                _ = try self.connect()
            } catch {
                print("🔌 <AsyncSocket>, Could not startTLS: \(error.localizedDescription)")
            }
        }
        if self.useSecureSocket {
            self.socket.startTLS(self.allowUntrustedServer ? 
                [String(GCDAsyncSocketManuallyEvaluateTrust): NSNumber(value:true)] :
                [String(kCFStreamSSLPeerName): NSString(string: self.host)])
        }
    }
    
    func write(_ data: Data, withTimeout timeout: TimeInterval, tag: Int) {
        if !self.useSecureSocket || self.isSecure() {
            self.socket.write(data, withTimeout: timeout, tag: tag)
        } else {
            print("🔌 <AsyncSocket>, logstash connection was not secure, could not send logs")
        }
    }
}

// MARK: - Connection Management

extension AsyncSocketManager {
    
    func connect() throws -> Bool {
        
        guard !self.socket.isConnected else { return true }
        
        do {
            try self.socket.connect(toHost: host, onPort: port, withTimeout: timeout)
        } catch {
            print("🔌 <AsyncSocket>, Could not connect: \(error.localizedDescription)")
            throw AsyncSocketError.failedConnection
        }
        
        return true
    }
    
    func disconnect() {
        if self.socket.isConnected {
            self.socket.disconnect()
        }
    }
    
    func disconnectSafely() {
        if self.socket.isConnected {
            self.socket.disconnectAfterWriting()
        }
    }
}

// MARK: - Socket Attributes

extension AsyncSocketManager {
    
    func isSecure() -> Bool {
        return self.socket.isSecure
    }
    
    func isConnected() -> Bool {
        return self.socket.isConnected
    }
}

// MARK: - Swift Delegate wrapper

extension AsyncSocketManager: GCDAsyncSocketDelegate {

    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        if logActivity {
            print("🔌 <AsyncSocket>, connected to host!", host)
        }
        self.delegate?.socket(sock, didConnectToHost: host, port: port)
    }
    
    func socketDidSecure(_ sock: GCDAsyncSocket) {
        if logActivity {
            print("🔌 <AsyncSocket>, did secure")
        }
        self.delegate?.socketDidSecure(sock)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        if logActivity {
            print("🔌 <AsyncSocket>, did write")
        }
        self.delegate?.socket(sock, didWriteDataWithTag: tag)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if logActivity {
            if let err = err {
                print("🔌 <AsyncSocket>, disconnected with error: \(err.localizedDescription)")
            }
            else {
                print("🔌 <AsyncSocket>, disconnected!")
            }
        }
        self.delegate?.socket(sock, didDisconnectWithError: err)
    }

    func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        if logActivity {
            print("🔌 <AsyncSocket>, did receive trust")
        }
        completionHandler(self.allowUntrustedServer)
    }
}
