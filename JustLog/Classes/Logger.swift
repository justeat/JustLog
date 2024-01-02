//  Logger.swift

import UIKit
import SwiftyBeaver

public final class Logger {
    
    public typealias SanitizeClosureType = (_ message: String, _ minimumLogType: LogType) -> String
    private var _sanitize: SanitizeClosureType = { message, _ in
        message
    }
    private let sanitizePropertyQueue = DispatchQueue(label: "com.justeat.justlog.sanitizePropertyQueue", qos: .default, attributes: .concurrent)
    public var sanitize: SanitizeClosureType {
        get {
            var sanitizeClosure: SanitizeClosureType?
            sanitizePropertyQueue.sync {
                sanitizeClosure = _sanitize
            }
            if let sanitizeClosure = sanitizeClosure {
                return sanitizeClosure
            } else {
                assertionFailure("Sanitization closure not set")
                return { message, _ in
                    message
                }
            }
        }
        set {
            sanitizePropertyQueue.async(flags: .barrier) {
                self._sanitize = newValue
            }
        }
    }
    
    private var configuration: Configurable!
    private var logMessageFormatter: LogMessageFormatting!
    
    public let internalLogger = SwiftyBeaver.self
    private var timer: RepeatingTimer?
    
    private(set) var queuedLogs = [Loggable]()
    
    // destinations
    public var console: ConsoleDestination!
    public var isConsoleLoggingEnabled: Bool {
        get { configuration.isConsoleLoggingEnabled }
        set { configuration.isConsoleLoggingEnabled = newValue }
    }
    
    public var file: FileDestination!
    public var isFileLoggingEnabled: Bool {
        get { configuration.isFileLoggingEnabled }
        set { configuration.isFileLoggingEnabled = newValue }
    }
    
    public var logstash: LogstashDestination!
    public var isLogstashLoggingEnabled: Bool {
        get { configuration.isLogstashLoggingEnabled }
        set { configuration.isLogstashLoggingEnabled = newValue }
    }
    
    public var custom: CustomDestination?
    public var isCustomLoggingEnabled: Bool {
        get { configuration.isCustomLoggingEnabled }
        set { configuration.isCustomLoggingEnabled = newValue }
    }
    
    deinit {
        timer?.suspend()
        timer = nil
    }
    
    public init(configuration: Configurable,
                logMessageFormatter: LogMessageFormatting,
                customLogSender: CustomDestinationSender? = nil) {
        self.configuration = configuration
        self.logMessageFormatter = logMessageFormatter
        
        internalLogger.removeAllDestinations()
        
        setupConsoleDestination(with: configuration)
        setupFileDestination(with: configuration)
        setupLogstashDestination(with: configuration)
        setupCustomDestination(with: configuration, customLogSender: customLogSender)
        
        sendQueuedLogsIfNeeded()
    }
    
    private func setupConsoleDestination(with configuration: Configurable) {
        if isConsoleLoggingEnabled {
            console = JustLog.ConsoleDestination()
            console.format = configuration.logFormat
            internalLogger.addDestination(console)
        }
    }
    
    private func setupFileDestination(with configuration: Configurable) {
        if isFileLoggingEnabled {
            file = JustLog.FileDestination()
            file.format = configuration.logFormat
            if let baseUrl = configuration.baseUrlForFileLogging {
                let pathComponent = configuration.logFilename ?? "justeat.log"
                file.logFileURL = baseUrl.appendingPathComponent(pathComponent, isDirectory: false)
            }
            internalLogger.addDestination(file)
        }
    }
    
    private func setupLogstashDestination(with configuration: Configurable) {
        if isLogstashLoggingEnabled {
            let sender: LogstashDestinationSending = {
                if configuration.logstashOverHTTP {
                    return LogstashDestinationHTTP(host: configuration.logstashHost,
                                                   port: configuration.logstashPort,
                                                   timeout: configuration.logstashTimeout,
                                                   logActivity: false)
                } else {
                    return LogstashDestinationSocket(host: configuration.logstashHost,
                                                     port: configuration.logstashPort,
                                                     timeout: configuration.logstashTimeout,
                                                     logActivity: configuration.logLogstashSocketActivity,
                                                     allowUntrustedServer: configuration.allowUntrustedServer)
                }
            }()
            logstash = LogstashDestination(sender: sender, logActivity: configuration.logLogstashSocketActivity)
            logstash.logzioToken = configuration.logzioToken
            internalLogger.addDestination(logstash)
            
            setupTimer(with: configuration)
        }
    }
    
    private func setupTimer(with configuraton: Configurable) {
        timer = RepeatingTimer(timeInterval: configuraton.sendingInterval)
        timer?.eventHandler = { [weak self] in
            guard let self else { return }
            self.forceSend()
        }
        
        timer?.cancelHandler = { [weak self] in
            guard let self else { return }
            self.cancelSending()
        }
        
        timer?.run()
    }
    
    private func setupCustomDestination(with configuration: Configurable, customLogSender: CustomDestinationSender? = nil) {
        if isCustomLoggingEnabled, let customLogSender = customLogSender {
            let customDestination = CustomDestination(sender: customLogSender)
            // always send all logs to custom destination
            customDestination.minLevel = .verbose
            internalLogger.addDestination(customDestination)
            custom = customDestination
        }
    }
    
    private func sendQueuedLogsIfNeeded() {
        if !queuedLogs.isEmpty {
            queuedLogs.forEach { log in
                send(log)
            }
            queuedLogs.removeAll()
        }
    }
    
    public func forceSend(_ completionHandler: @escaping (_ error: Error?) -> Void = {_ in }) {
        guard configuration != nil,
              logMessageFormatter != nil else {
            assertionFailure("Logger has not been configured yet")
            return
        }
        
        if isLogstashLoggingEnabled {
            logstash?.forceSend(completionHandler)
        }
    }
    
    public func cancelSending() {
        guard configuration != nil,
              logMessageFormatter != nil else {
            assertionFailure("Logger has not been configured yet")
            return
        }
        
        if isLogstashLoggingEnabled {
            logstash?.cancelSending()
        }
    }
}

extension Logger: Logging {

    public func send(_ log: Loggable) {
        guard configuration != nil,
              let formatter = logMessageFormatter else {
            assertionFailure("Logger has not been configured yet")
            return
        }

        if !internalLogger.destinations.isEmpty {
            sendLogMessage(with: log.type, logMessage: sanitize(formatter.format(log), log.type), log.file, log.function, log.line)
        } else {
            queuedLogs.append(log)
        }
    }
    
    private func sendLogMessage(with type: LogType, logMessage: String, _ file: String, _ function: String, _ line: UInt) {
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
