//  Configurable.swift

import Foundation

public protocol Configurable {
    
    // please see https://docs.swiftybeaver.com/article/20-custom-format for variable log format options
    var logFormat: String { get set }
    var sendingInterval: TimeInterval { get set }
    
    // file
    var logFilename: String? { get set }
    var baseUrlForFileLogging: URL? { get set }
    
    // logstash
    var allowUntrustedServer: Bool { get set }
    var logstashHost: String { get set }
    var logstashPort: UInt16 { get set }
    var logstashTimeout: TimeInterval { get set }
    var logLogstashSocketActivity: Bool { get set }
    var logzioToken: String? { get set }
    var logstashOverHTTP: Bool { get set }
    
    // destinations
    var isConsoleLoggingEnabled: Bool { get set }
    var isFileLoggingEnabled: Bool { get set }
    var isLogstashLoggingEnabled: Bool { get set }
    var isCustomLoggingEnabled: Bool { get set }
}
