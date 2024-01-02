//
//  AppDelegate.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 12/06/2016.
//  Copyright (c) 2017 Just Eat. All rights reserved.
//

import UIKit
import JustLog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var sessionID = UUID().uuidString
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLogger()
        return true
    }

    struct RegexListReponse: Codable {
        var pattern: String
        var minimumLogLevel: String
    }
    
    struct ExceptionListResponse: Codable {
        var value: String
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        forceSendLogs(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        forceSendLogs(application)
    }
    
    private var logger: Logger!

    func redactValues(message: String, loggerExeptionList: [ExceptionListResponse], matches: [NSTextCheckingResult]) -> String {
        
        var redactedLogMessage = message
        
        for match in matches.reversed() {
            let key = match.range(at: 1)
            let value = match.range(at: 2)
            
            let keyRange = Range(key, in: redactedLogMessage)!
            let valueRange = Range(value, in: redactedLogMessage)!
            
            for exception in loggerExeptionList {
                if exception.value == redactedLogMessage[valueRange] {
                    return redactedLogMessage
                }
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
    
    private func forceSendLogs(_ application: UIApplication) {
        
        var identifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
        
        identifier = application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(identifier)
            identifier = UIBackgroundTaskIdentifier.invalid
        })
        
        logger.forceSend { completionHandler in
            application.endBackgroundTask(identifier)
            identifier = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    private func setupLogger() {
        let decoder = JSONDecoder()

        let configuration = Configuration(
            logFilename: "justeat-demo.log",
            logstashHost: "listener.logz.io",
            logstashPort: 5052,
            logstashTimeout: 5,
            logLogstashSocketActivity: true
        )

        logger = Logger(
            configuration: configuration,
            logMessageFormatter: JSONStringLogMessageFormatter(keys: FormatterKeys())
        )

        let regexRuleList = "[{\"pattern\": \"(name) = \\\\\\\\*\\\"(.*?[^\\\\\\\\]+)\", \"minimumLogLevel\": \"warning\"}, {\"pattern\": \"(token) = \\\\\\\\*\\\"(.*?[^\\\\\\\\]+)\", \"minimumLogLevel\": \"warning\"}]".data(using: .utf8)
        let sanitizationExeceptionList = "[{\"value\": \"Dan Jones\"}, {\"value\": \"Jack Jones\"}]".data(using: .utf8)

        logger.sanitize = { message, type in
            var sanitizedMessage = message

            guard let ruleList = try? decoder.decode([RegexListReponse].self, from: regexRuleList!) else { return "sanitizedMessage" }
            guard let exceptionList = try? decoder.decode([ExceptionListResponse].self, from: sanitizationExeceptionList!) else { return "sanitizedMessage" }

            for value in ruleList {
                if (value.minimumLogLevel >= type.rawValue) {
                    if let regex = try? NSRegularExpression(pattern: value.pattern , options: NSRegularExpression.Options.caseInsensitive) {

                        let range = NSRange(sanitizedMessage.startIndex..<sanitizedMessage.endIndex, in: sanitizedMessage)
                        let matches = regex.matches(in: sanitizedMessage, options: [], range: range)

                        sanitizedMessage = self.redactValues(message: sanitizedMessage, loggerExeptionList: exceptionList, matches: matches)
                    }
                }
            }
            return sanitizedMessage
        }
        
        // logz.io support
        //logger.logzioToken = <logzioToken>
        
        // untrusted (self-signed) logstash server support
        //logger.allowUntrustedServer = <Bool>
    }
    
    
}
