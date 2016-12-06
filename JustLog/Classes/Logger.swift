//
//  Logger.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 06/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation
import SwiftyBeaver

@objc
public final class Logger: NSObject {
    
    public var logTypeKey = "log_type"
    
    public var fileKey = "file"
    public var functionKey = "function"
    public var lineKey = "line"
    
    public var appVersionKey = "app_version"
    public var iosVersionKey = "ios_version"
    public var deviceTypeKey = "ios_device"
    
    public var errorDomain = "error_domain"
    public var errorCode = "error_code"
    
    public static let shared = Logger()
    
    // file conf
    public var logFilename: String?
    
    // logstash conf
    public var logstashHost: String!
    public var logstashPort: UInt16 = 9300
    public var logstashTimeout: TimeInterval = 20
    public var logLogstashSocketActivity: Bool = false
    public var logzioToken: String?
    
    // logger conf
    public var defaultUserInfo: [String : Any]?
    public var enableConsoleLogging: Bool = true
    public var enableFileLogging: Bool = true
    public var enableLogstashLogging: Bool = true
    private let internalLogger = SwiftyBeaver.self
    private var dispatchTimer: Timer?
    
    // destinations
    private var console: ConsoleDestination!
    private var logstash: LogstashDestination!
    private var file: FileDestination!
    
    deinit {
        dispatchTimer?.invalidate()
        dispatchTimer = nil
    }
    
    public func setup() {
        
        let format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $T $C$L$c: $M"
        
        // console
        console = JustLog.ConsoleDestination()
        console.format = format
        if enableConsoleLogging {
            internalLogger.addDestination(console)
        }
        
        // file
        file = JustLog.FileDestination()
        file.format = format
        if let baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            file.logFileURL = baseURL.appendingPathComponent(logFilename ?? "justeat.log", isDirectory: false)
        }
        if enableFileLogging {
            internalLogger.addDestination(file)
        }
        
        // logstash
        logstash = LogstashDestination(host: logstashHost, port: logstashPort, timeout: logstashTimeout, logActivity: logLogstashSocketActivity)
        logstash.logzioToken = logzioToken
        if enableLogstashLogging {
            internalLogger.addDestination(logstash)
        }
        
        dispatchTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scheduledForceSend(_:)), userInfo: nil, repeats: true)
    }
    
    public func forceSend(_ completionHandler: @escaping () -> Void = {}) {
        logstash.forceSend(completionHandler)
    }
    
    public func verbose(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        let updatedUserInfo = [logTypeKey: "verbose"].merged(with: userInfo ?? [String : String]())
        let logMessage = self.logMessage(message, error: error, userInfo: updatedUserInfo, file, function, line)
        internalLogger.verbose(logMessage, file, function, line: line)
    }
    
    public func debug(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        let updatedUserInfo = [logTypeKey: "debug"].merged(with: userInfo ?? [String : String]())
        let logMessage = self.logMessage(message, error: error, userInfo: updatedUserInfo, file, function, line)
        internalLogger.debug(logMessage, file, function, line: line)
    }
    
    public func info(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        let updatedUserInfo = [logTypeKey: "info"].merged(with: userInfo ?? [String : String]())
        let logMessage = self.logMessage(message, error: error, userInfo: updatedUserInfo, file, function, line)
        internalLogger.info(logMessage, file, function, line: line)
    }
    
    public func warning(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        let updatedUserInfo = [logTypeKey: "warning"].merged(with: userInfo ?? [String : String]())
        let logMessage = self.logMessage(message, error: error, userInfo: updatedUserInfo, file, function, line)
        internalLogger.warning(logMessage, file, function, line: line)
    }
    
    public func error(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        let updatedUserInfo = [logTypeKey: "error"].merged(with: userInfo ?? [String : Any]())
        let logMessage = self.logMessage(message, error: error, userInfo: updatedUserInfo, file, function, line)
        internalLogger.error(logMessage, file, function, line: line)
    }
}

extension Logger {
    
    fileprivate func logMessage(_ message: String, error: NSError? = nil, userInfo: [String : Any]?, _ file: String, _ function: String, _ line: Int) -> String {
    
        let messageConst = "message"
        let userInfoConst = "userInfo"
        let metadataConst = "metadata"
        
        var options = defaultUserInfo ?? [String : Any]()
        
        var retVal = [String : Any]()
        retVal[messageConst] = message
        
        var fileMetadata = [String : String]()
        
        if let url = URL(string: file) {
            fileMetadata[fileKey] = URLComponents(url: url, resolvingAgainstBaseURL: false)?.url?.pathComponents.last ?? file
        }
        
        fileMetadata[functionKey] = function
        fileMetadata[lineKey] = String(line)
        
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"], let bundleShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            fileMetadata[appVersionKey] = "\(bundleShortVersion) (\(bundleVersion))"
        }
        
        fileMetadata[iosVersionKey] = UIDevice.current.systemVersion
        fileMetadata[deviceTypeKey] = UIDevice.current.platform()
        
        retVal[metadataConst] = fileMetadata
        
        if let userInfo = userInfo {
            for (key, value) in userInfo {
                _ = options.updateValue(value, forKey: key)
            }
        }
        
        if let error = error {
            let errorInfo = [errorDomain: error.domain,
                             errorCode: error.code] as [String : Any]
            let errorUserInfo = error.humanReadableError().userInfo
            options = options.merged(with: errorInfo).merged(with: errorUserInfo.flattened())
        }
        
        retVal[userInfoConst] = options
        
        return retVal.toJSON() ?? ""
    }
    
    @objc fileprivate func scheduledForceSend(_ timer: Timer) {
        forceSend()
    }
    
}
