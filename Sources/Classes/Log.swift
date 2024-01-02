//  Log.swift

import Foundation

public struct Log: Loggable {
    
    public let type: LogType
    public let message: String
    public let error: NSError?
    public var customData: [String: Any]?
    public let file: String
    public let function: String
    public let line: UInt
    
    public init(type: LogType,
                message: String,
                error: NSError? = nil,
                customData: [String: Any]? = nil,
                file: String = #file,
                function: String = #function,
                line: UInt = #line) {
        self.type = type
        self.message = message
        self.error = error
        self.customData = customData
        self.file = file
        self.function = function
        self.line = line
    }
}
