//  Loggable.swift

import Foundation

public enum LogType: String {
    case debug
    case warning
    case verbose
    case error
    case info
}

public protocol Loggable {
    
    var type: LogType { get }
    var message: String { get }
    var error: NSError? { get }
    var customData: [String: Any]? { get set }
    var file: String { get }
    var function: String { get }
    var line: UInt { get }
}
