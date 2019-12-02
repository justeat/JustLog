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
    func socket(_ socket: GCDAsyncSocket, didWriteDataWithTag tag: Int)
    func socket(_ socket: GCDAsyncSocket, didDisconnectWithError error: Error?)
    func socket(_ socket: GCDAsyncSocket, didReceiveTrust: SecTrust, completionHandler: @escaping (Bool) -> Void)
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
    let sslCertificatePath: String?
    let sslPeerName: String?
    
    let localSocketQueue = DispatchQueue(label: "com.justeat.gcdAsyncSocketDelegateQueue")
    
    init(host: String, port: UInt16, timeout: TimeInterval, delegate: AsyncSocketManagerDelegate, logActivity: Bool, allowUntrustedServer: Bool, sslCertificatePath: String?, sslPeerName: String?) {
        
        self.host = host
        self.port = port
        self.timeout = timeout
        self.delegate = delegate
        self.logActivity = logActivity
        self.allowUntrustedServer = allowUntrustedServer
        self.sslCertificatePath = sslCertificatePath
        self.sslPeerName = sslPeerName
        
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
        
        // Configure SSL/TLS settings
        let settings = NSMutableDictionary()
        
        //If we have cert provided then lets send it
        if let certPath = self.sslCertificatePath {
            settings[kCFStreamSSLCertificates] = loadCertificates(tlsCertFilePath: certPath)
        }
        
        //If we have a peer name provided then lets send it
        if let peerName = self.sslPeerName {
            settings[kCFStreamSSLPeerName] = peerName
        } else {
            settings[kCFStreamSSLPeerName] = self.host
        }
        
        //Should we allow manual trust evaluation
        settings[GCDAsyncSocketManuallyEvaluateTrust] = NSNumber.init(value: self.allowUntrustedServer)
           
        self.socket.startTLS(settings as? [String : NSObject])
        
    }
    
    func loadCertificates(tlsCertFilePath: String) -> CFArray?{
       
       let pkcs12Data = NSData(contentsOfFile:tlsCertFilePath)
       
       var imported: CFArray? = nil
       var options: Dictionary<String, CFString> = [:]
       options[kSecImportExportPassphrase as String] = "" as CFString?
                
       switch SecPKCS12Import(pkcs12Data!, (options as CFDictionary), &imported) {
       case noErr:
           let identityDict = unsafeBitCast(CFArrayGetValueAtIndex(imported!, 0), to: CFDictionary.self) as NSDictionary
           let importItemIdentity = kSecImportItemIdentity as String
           let identityRef = identityDict[importItemIdentity] as! SecIdentity
         
           var certRef: SecCertificate?
           switch SecIdentityCopyCertificate(identityRef, &certRef) {
           case noErr:
               return NSArray(objects: identityRef, certRef!)
           case errSecAuthFailed:
               NSLog("SecIdentityCopyCertificate - errSecAuthFailed: Authorization/Authentication failed.")
           default:
               NSLog("SecIdentityCopyCertificate - Unknown OSStatus error")
           }
           break
       case errSecAuthFailed:
           NSLog("SecPKCS12Import - errSecAuthFailed: Authorization/Authentication failed.")
       default:
           NSLog("SecPKCS12Import - Unknown OSStatus error")
       }
       
       return nil
   }
    
    func write(_ data: Data, withTimeout timeout: TimeInterval, tag: Int) {
        if self.isSecure() {
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
            print("🔌 <AsyncSocket>, connected!")
        }
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
