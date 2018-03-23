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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupLogger()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        forceSendLogs(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        forceSendLogs(application)
    }

    private func forceSendLogs(_ application: UIApplication) {
        
        var identifier: UIBackgroundTaskIdentifier = 0
        
        identifier = application.beginBackgroundTask(expirationHandler: {
            application.endBackgroundTask(identifier)
            identifier = UIBackgroundTaskInvalid
        })
        
        Logger.shared.forceSend { completionHandler in
            application.endBackgroundTask(identifier)
            identifier = UIBackgroundTaskInvalid
        }
    }
    
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

        // logz.io support
        //logger.logzioToken = <logzioToken>
        
        // default info
        logger.defaultUserInfo = ["application": "JustLog iOS Demo",
                                  "environment": "development",
                                  "session": sessionID]
        logger.setup()
    }

}

