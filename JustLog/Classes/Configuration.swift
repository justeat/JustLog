//  Configuration.swift

import Foundation

public struct Configuration: Configurable {
    
    public var logFormat: String
    public var sendingInterval: TimeInterval
    
    // file
    public var logFilename: String?
    public var baseUrlForFileLogging: URL?
    
    // logstash
    public var allowUntrustedServer: Bool
    public var logstashHost: String
    public var logstashPort: UInt16
    public var logstashTimeout: TimeInterval
    public var logLogstashSocketActivity: Bool
    public var logzioToken: String?
    public var logstashOverHTTP: Bool
    
    // destinations
    public var isConsoleLoggingEnabled: Bool
    public var isFileLoggingEnabled: Bool
    public var isLogstashLoggingEnabled: Bool
    public var isCustomLoggingEnabled: Bool
    
    public init(logFormat: String = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $T $C$L$c: $M",
                sendingInterval: TimeInterval = 5,
                logFilename: String? = nil,
                baseUrlForFileLogging: URL? = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
                allowUntrustedServer: Bool = false,
                logstashHost: String = "",
                logstashPort: UInt16 = 9300,
                logstashTimeout: TimeInterval = 20,
                logLogstashSocketActivity: Bool = false,
                logzioToken: String? = nil,
                logstashOverHTTP: Bool = false,
                isConsoleLoggingEnabled: Bool = true,
                isFileLoggingEnabled: Bool = true,
                isLogstashLoggingEnabled: Bool = true,
                isCustomLoggingEnabled: Bool = true) {
        self.logFormat = logFormat
        self.sendingInterval = sendingInterval
        
        self.logFilename = logFilename
        self.baseUrlForFileLogging = baseUrlForFileLogging
        
        // logstash
        self.allowUntrustedServer = allowUntrustedServer
        self.logstashHost = logstashHost
        self.logstashPort = logstashPort
        self.logstashTimeout = logstashTimeout
        self.logLogstashSocketActivity = logLogstashSocketActivity
        self.logzioToken = logzioToken
        self.logstashOverHTTP = logstashOverHTTP
        
        // destinations
        self.isConsoleLoggingEnabled = isConsoleLoggingEnabled
        self.isFileLoggingEnabled = isFileLoggingEnabled
        self.isLogstashLoggingEnabled = isLogstashLoggingEnabled
        self.isCustomLoggingEnabled = isCustomLoggingEnabled
    }
}
