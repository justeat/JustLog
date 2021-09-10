//
//  Logger.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 06/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import UIKit
import SwiftyBeaver

@objcMembers
public final class Logger: NSObject {
    
    public enum LogType: String {
        case debug
        case warning
        case verbose
        case error
        case info
    }
    
    internal struct QueuedLog {
        let type: LogType
        let message: String
        let file: String
        let function: String
        let line: UInt
    }
    
    public typealias SanitizeClosureType = (_ message: String, _ minimumLogType: LogType) -> String
    private var _sanitize: SanitizeClosureType = { message, minimumLogType in
        
        return message
    }
    private let sanitizePropertyQueue = DispatchQueue(label: "com.justeat.justlog.sanitizePropertyQueue", qos: .default, attributes: .concurrent)
    public var sanitize: SanitizeClosureType {
        get {
            var sanitizeClosure: SanitizeClosureType? = nil
            sanitizePropertyQueue.sync {
                sanitizeClosure = _sanitize
            }
            if let sanitizeClosure = sanitizeClosure {
                return sanitizeClosure
            } else {
                assertionFailure("Sanitization closure not set")
                return { message, _ in
                    return message
                }
            }
        }
        set {
            sanitizePropertyQueue.async(flags: .barrier) {
                self._sanitize = newValue
            }
        }
    }
    
    public var logTypeKey = "log_type"
    
    public var fileKey = "file"
    public var functionKey = "function"
    public var lineKey = "line"
    
    public var appVersionKey = "app_version"
    public var iosVersionKey = "ios_version"
    public var deviceTypeKey = "ios_device"
    public var appBundleID = "app_bundle_ID"
    
    public var errorDomain = "error_domain"
    public var errorCode = "error_code"
    
    public static let shared = Logger()
    
    // file conf
    public var logFilename: String?
    
    // logstash conf
    public var logstashHost: String = ""
    public var logstashPort: UInt16 = 9300
    public var logstashTimeout: TimeInterval = 20
    public var logLogstashSocketActivity: Bool = false
    public var logzioToken: String?

    /**
     Default to `false`, if `true` untrusted certificates (as self-signed are) will be trusted
     */
    public var allowUntrustedServer: Bool = false

    // logger conf
    public var defaultUserInfo: [String : Any]?
    public var enableConsoleLogging: Bool = true
    public var enableFileLogging: Bool = true
    public var enableLogstashLogging: Bool = true
    public var enableCustomLogging: Bool = true
    public var baseUrlForFileLogging = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    public let internalLogger = SwiftyBeaver.self
    
    private var timerInterval: TimeInterval = 5
    private var timer: RepeatingTimer?
    
    internal private(set) var queuedLogs = [QueuedLog]()
    
    // destinations
    public var console: ConsoleDestination!
    public var logstash: LogstashDestination!
    public var file: FileDestination!
    public var custom: CustomDestination?
    deinit {
        timer?.suspend()
        timer = nil
    }
    
    public func setup() {
        setupWithCustomLogSender()
    }
    
    public func setupWithCustomLogSender(_ customLogSender: CustomDestinationSender? = nil) {
        
        let format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $T $C$L$c: $M"
        
        internalLogger.removeAllDestinations()
        
        // console
        if enableConsoleLogging {
            console = JustLog.ConsoleDestination()
            console.format = format
            internalLogger.addDestination(console)
        }
        
        // file
        if enableFileLogging {
            file = JustLog.FileDestination()
            file.format = format
            if let baseURL = self.baseUrlForFileLogging {
                file.logFileURL = baseURL.appendingPathComponent(logFilename ?? "justeat.log", isDirectory: false)
            }
            internalLogger.addDestination(file)
        }
        
        // logstash
        if enableLogstashLogging {
            let socket = LogstashDestinationSocket(host: logstashHost,
                                                   port: logstashPort,
                                                   timeout: logstashTimeout,
                                                   logActivity: logLogstashSocketActivity,
                                                   allowUntrustedServer: allowUntrustedServer)
            logstash = LogstashDestination(socket: socket, logActivity: logLogstashSocketActivity)
            logstash.logzioToken = logzioToken
            internalLogger.addDestination(logstash)
            
            timer = RepeatingTimer(timeInterval: timerInterval)
            timer?.eventHandler = { [weak self] in
                guard let self = self else { return }
                self.forceSend()
            }
            
            timer?.cancelHandler = { [weak self] in
                guard let self = self else { return }
                self.cancelSending()
            }
            
            timer?.run()
        }
        
        // custom logging
        if enableCustomLogging, let customLogSender = customLogSender {
            let customDestination = CustomDestination(sender: customLogSender)
            // always send all logs to custom destination
            customDestination.minLevel = .verbose
            internalLogger.addDestination(customDestination)
            self.custom = customDestination
        }
        
        sendQueuedLogsIfNeeded()
    }
    
    private func sendQueuedLogsIfNeeded() {
        if !queuedLogs.isEmpty {
            queuedLogs.forEach { queuedLog in
                sendLogMessage(with: queuedLog.type, logMessage: queuedLog.message, queuedLog.file, queuedLog.function, queuedLog.line)
            }
            queuedLogs.removeAll()
        }
    }
    
    public func forceSend(_ completionHandler: @escaping (_ error: Error?) -> Void = {_ in }) {
        if enableLogstashLogging {
            logstash?.forceSend(completionHandler)
        }
    }
    
    public func cancelSending() {
        if enableLogstashLogging {
            logstash?.cancelSending()
        }
    }
}

extension Logger: Logging {
    
    public func verbose(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        let file = String(describing: file)
        let function = String(describing: function)
        let updatedUserInfo = [logTypeKey: "verbose"].merged(with: userInfo ?? [String : String]())
        log(.verbose, message, error: error, userInfo: updatedUserInfo, file, function, line)
    }
    
    public func debug(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        let file = String(describing: file)
        let function = String(describing: function)
        let updatedUserInfo = [logTypeKey: "debug"].merged(with: userInfo ?? [String : String]())
        log(.debug, message, error: error, userInfo: updatedUserInfo, file, function, line)
    }
    
    public func info(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        let file = String(describing: file)
        let function = String(describing: function)
        let updatedUserInfo = [logTypeKey: "info"].merged(with: userInfo ?? [String : String]())
        log(.info, message, error: error, userInfo: updatedUserInfo, file, function, line)
    }
    
    public func warning(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        let file = String(describing: file)
        let function = String(describing: function)
        let updatedUserInfo = [logTypeKey: "warning"].merged(with: userInfo ?? [String : String]())
        log(.warning, message, error: error, userInfo: updatedUserInfo, file, function, line)

    }
    
    public func error(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        let file = String(describing: file)
        let function = String(describing: function)
        let updatedUserInfo = [logTypeKey: "error"].merged(with: userInfo ?? [String : Any]())
        log(.error, message, error: error, userInfo: updatedUserInfo, file, function, line)
    }
    
    internal func log(_ type: LogType, _ message: String, error: NSError?, userInfo: [String : Any]?, _ file: String, _ function: String, _ line: UInt) {
        
        let messageToLog = logMessage(message, error: error, userInfo: userInfo, file, function, line)
        
        if !internalLogger.destinations.isEmpty {
            sendLogMessage(with: type, logMessage: sanitize(messageToLog, type), file, function, line)
        } else {
            queuedLogs.append(QueuedLog(type: type, message: sanitize(message, type), file: file, function: function, line: line))
        }
    }
    
    internal func sendLogMessage(with type: LogType, logMessage: String, _ file: String, _ function: String, _ line: UInt) {
        switch type {
        case .error:
            internalLogger.error(logMessage, file, function, line: Int(line))
        case .warning:
            internalLogger.warning(logMessage, file, function, line: Int(line))
        case .debug:
            internalLogger.debug(logMessage, file, function, line: Int(line))
        case .info:
            internalLogger.info(logMessage, file, function, line: Int(line))
        case .verbose:
            internalLogger.verbose(logMessage, file, function, line: Int(line))
        }
    }
}

extension Logger {
    
    internal func logMessage(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: String, _ function: String, _ line: UInt) -> String {
    
        let messageConst = "message"
        let userInfoConst = "user_info"
        let metadataConst = "metadata"
        let errorsConst = "errors"
        
        var options = defaultUserInfo ?? [String : Any]()
        
        var retVal = [String : Any]()
        retVal[messageConst] = message
        retVal[metadataConst] = metadataDictionary(file, function, line)
        
        if let userInfo = userInfo {
            for (key, value) in userInfo {
                _ = options.updateValue(value, forKey: key)
            }
            retVal[userInfoConst] = options
        }
        
        if let error = error {
            let errorDictionaries = error.disassociatedErrorChain()
                .map { errorDictionary(for: $0) }
                .filter { JSONSerialization.isValidJSONObject($0) }
            retVal[errorsConst] = errorDictionaries
        }
        
        return retVal.toJSON() ?? ""
    }
    
    private func metadataDictionary(_ file: String, _ function: String, _ line: UInt) -> [String: Any] {
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
        fileMetadata[appBundleID] = Bundle.main.bundleIdentifier
        
        return fileMetadata
    }
    
    internal func errorDictionary(for error: NSError) -> [String : Any] {
        let userInfoConst = "user_info"
        var errorInfo = [errorDomain: error.domain,
                         errorCode: error.code] as [String : Any]
        let errorUserInfo = error.humanReadableError().userInfo
        errorInfo[userInfoConst] = errorUserInfo
        return errorInfo
    }
}
