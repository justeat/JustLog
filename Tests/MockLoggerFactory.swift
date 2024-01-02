//  MockLoggerFactory.swift

import Foundation
@testable import JustLog

class MockLoggerFactory {
    
    var logger: Logger?
    
    struct RegexListReponse: Codable {
        var pattern: String
        var minimumLogLevel: String
    }
    
    struct ExceptionListResponse: Codable {
        var value: String
    }
    
    func redactValues(message: String, loggerExceptionList: [ExceptionListResponse], matches: [NSTextCheckingResult]) -> String {
        
        var redactedLogMessage = message
        
        for match in matches.reversed() {
            let key = match.range(at: 1)
            let value = match.range(at: 2)
            
            let keyRange = Range(key, in: redactedLogMessage)!
            let valueRange = Range(value, in: redactedLogMessage)!
            
            for exception in loggerExceptionList where exception.value == redactedLogMessage[valueRange] {
                return redactedLogMessage
            }
            
            var redactedKey = redactedLogMessage[keyRange]
            let redactedKeyStartIndex = redactedKey.index(redactedKey.startIndex, offsetBy: 1)
            let redactedKeyEndIndex = redactedKey.index(redactedKey.endIndex, offsetBy: -1)
            
            redactedKey.replaceSubrange(redactedKeyStartIndex..<redactedKeyEndIndex, with: "***")
            
            var redactedValue = redactedLogMessage[valueRange]
            let valueReplacementStartIndex = redactedValue.startIndex
            let valueReplacementEndIndex = redactedValue.endIndex
            
            redactedValue.replaceSubrange(valueReplacementStartIndex..<valueReplacementEndIndex, with: "*****")
            
            redactedLogMessage.replaceSubrange(valueRange, with: redactedValue)
            redactedLogMessage.replaceSubrange(keyRange, with: redactedKey)
        }
        return redactedLogMessage
    }
    
    init() {
        let decoder = JSONDecoder()
        let configuration = Configuration(logFilename: "justeat-demo.log",
                                          logstashHost: "listener.logz.io",
                                          logstashPort: 5052,
                                          logstashTimeout: 5,
                                          logLogstashSocketActivity: true)
        
        let keys = FormatterKeys(logTypeKey: "logtype",
                                 appVersionKey: "app_version",
                                 deviceTypeKey: "ios_device",
                                 iosVersionKey: "ios_version")
        
        let defaultLogMetadata = ["application": "JustLog iOS Demo",
                                  "environment": "development",
                                  "session": "sessionID"]
        
        let logMessageFormatter = JSONStringLogMessageFormatter(keys: keys, defaultLogMetadata: defaultLogMetadata)
        
        logger = Logger(configuration: configuration, logMessageFormatter: logMessageFormatter)
        
        let regexRuleList = "[{\"pattern\": \"(name) = \\\\\\\\*\\\"(.*?[^\\\\\\\\]+)\", \"minimumLogLevel\": \"warning\"}, {\"pattern\": \"(token) = \\\\\\\\*\\\"(.*?[^\\\\\\\\]+)\", \"minimumLogLevel\": \"warning\"}]".data(using: .utf8)
        let sanitizationExeceptionList = "[{\"value\": \"Dan Jones\"}, {\"value\": \"Jack Jones\"}]".data(using: .utf8)
        
        logger?.sanitize = { message, type in
            var sanitizedMessage = message
            
            guard let ruleList = try? decoder.decode([RegexListReponse].self, from: regexRuleList!) else { return "sanitizedMessage" }
            guard let exceptionList = try? decoder.decode([ExceptionListResponse].self, from: sanitizationExeceptionList!) else { return "sanitizedMessage" }
            
            for value in ruleList where value.minimumLogLevel >= type.rawValue {
                if let regex = try? NSRegularExpression(pattern: value.pattern, options: NSRegularExpression.Options.caseInsensitive) {
                    
                    let range = NSRange(sanitizedMessage.startIndex..<sanitizedMessage.endIndex, in: sanitizedMessage)
                    let matches = regex.matches(in: sanitizedMessage, options: [], range: range)
                    
                    sanitizedMessage = self.redactValues(message: sanitizedMessage, loggerExceptionList: exceptionList, matches: matches)
                }
            }
            return sanitizedMessage
        }
    }
}
