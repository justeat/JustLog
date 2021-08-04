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
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        forceSendLogs(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        forceSendLogs(application)
    }
    
    func redactValues(message: String, loggerExeptionList: [String], matches: [NSTextCheckingResult]) -> String {
        
        var redactedLogMessage = logMessagePlaceholder
        
        for match in matches.reversed() {
            let key = match.range(at: 1)
            let value = match.range(at: 2)
            
            let keyRange = Range(key, in: redactedLogMessage)!
            let valueRange = Range(value, in: redactedLogMessage)!
            
            for listedException in loggerExeptionList {
                if listedException != redactedLogMessage[valueRange] {
                    redactedLogMessage.replaceSubrange(keyRange, with: "****")
                    redactedLogMessage.replaceSubrange(valueRange, with: "****")
                }
            }
            return redactedLogMessage
        }
    }
    
    private func forceSendLogs(_ application: UIApplication) {
        
        var identifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
        
        identifier = application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(identifier)
            identifier = UIBackgroundTaskIdentifier.invalid
        })
        
        Logger.shared.forceSend { completionHandler in
            application.endBackgroundTask(identifier)
            identifier = UIBackgroundTaskIdentifier.invalid
        }
    }

    var regexRules = [[#"(name) = \\*"(.*?[^\\]+)"#, "function()", "minimumLevel"]]
    
    private func setupLogger() {
        
        let logger = Logger.shared
        
        // custom keys
        logger.logTypeKey = "logtype"
        logger.appVersionKey = "app_version"
        logger.iosVersionKey = "ios_version"
        logger.deviceTypeKey = "ios_device"
        
        // file destination
        logger.logFilename = "justeat-demo.log"
        
        // logstash destination
        logger.logstashHost = "listener.logz.io"
        logger.logstashPort = 5052
        logger.logstashTimeout = 5
        logger.logLogstashSocketActivity = true

        logger.sanitizer = { message, type, regexRules, loggerExeptionList in
        
            var sanitizedMessage = message
            
            for pattern in regexPattern {
                if let regex = try? NSRegularExpression(pattern: pattern , options: NSRegularExpression.Options.caseInsensitive) {
                    
                    let range = NSRange(message.startIndex..<message.endIndex, in: message)
                    let matches = regex.matches(in: message, options: [], range: range)
                    
                    sanitizedMessage = self.redactValues(message: message, loggerExeptionList: [""], matches: matches)
                }
            }
            
            return sanitizedMessage
        }
        
        // logz.io support
        //logger.logzioToken = <logzioToken>

        // untrusted (self-signed) logstash server support
        //logger.allowUntrustedServer = <Bool>
        
        // default info
        logger.defaultUserInfo = ["application": "JustLog iOS Demo",
                                  "environment": "development",
                                  "session": sessionID]
        logger.setup()
    }

}
