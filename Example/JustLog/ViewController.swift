//
//  ViewController.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 12/06/2016.
//  Copyright (c) 2017 Just Eat. All rights reserved.
//

import UIKit
import JustLog

class ViewController: UIViewController {

    private var logNumber = 0

    private var logger: Logger = Logger(
        configuration: Configuration(),
        logMessageFormatter: JSONStringLogMessageFormatter(keys: FormatterKeys())
    )

    @IBAction func verbose() {
        let log = Log(type: .verbose, message: "[\(logNumber)] not so important", customData: ["userInfo key": "userInfo value"])
        logger.send(log)
        logNumber += 1
    }
    
    @IBAction func debug() {
        let log = Log(type: .debug, message: "[\(logNumber)] not so debug", customData: ["userInfo key": "userInfo value"])
        logger.send(log)
        logNumber += 1
    }
    
    @IBAction func info() {
        let log = Log(type: .info, message: "[\(logNumber)] a nice information", customData: ["userInfo key": "userInfo value"])
        logger.send(log)
        logNumber += 1
    }
    
    @IBAction func warning() {
        let log = Log(type: .warning, message: "[\(logNumber)] oh no, that won’t be good", customData: ["userInfo key": "userInfo value"])
        logger.send(log)
        logNumber += 1
    }
    
    @IBAction func warningSanitized() {
        let messageToSanitize = "conversation ={\\n id = \\\"123455\\\";\\n};\\n from = {\\n id = 123456;\\n name = \\\"John Smith\\\";\\n; \\n token = \\\"123456\\\";\\n"
        let sanitizedMessage = logger.sanitize(messageToSanitize, LogType.warning)
        let log = Log(type: .warning, message: sanitizedMessage, customData: ["userInfo key": "userInfo value"])
        logger.send(log)
        logNumber += 1
    }
    
    @IBAction func error() {
        
        let underlyingUnreadableUserInfoError = [
            NSLocalizedFailureReasonErrorKey: "inner error value".data(using: String.Encoding.utf8)!,
            NSLocalizedDescriptionKey: "inner description",
            NSLocalizedRecoverySuggestionErrorKey: "inner recovery suggestion".data(using: String.Encoding.utf8)!
            ] as [String : Any]
        
        let unreadableUserInfos = [
            NSUnderlyingErrorKey: NSError(domain: "com.just-eat.test.inner", code: 5678, userInfo: underlyingUnreadableUserInfoError),
            NSLocalizedFailureReasonErrorKey: "error value".data(using: String.Encoding.utf8)!,
            NSLocalizedDescriptionKey: "description",
            NSLocalizedRecoverySuggestionErrorKey: "recovery suggestion".data(using: String.Encoding.utf8)!
            ] as [String : Any]
        
        let unreadableError = NSError(domain: "com.just-eat.test", code: 1234, userInfo: unreadableUserInfos)
        
        let log = Log(type: .error, message: "[\(logNumber)] ouch, an error did occur!", error: unreadableError, customData: ["userInfo key": "userInfo value"])
        logger.send(log)
        logNumber += 1
    }
    
    @IBAction func forceSend() {
        logger.forceSend()
    }

    @IBAction func cancel(_ sender: Any) {
        logger.cancelSending()
    }
}

