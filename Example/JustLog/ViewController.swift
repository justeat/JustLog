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
    
    @IBAction func verbose() {
        Logger.shared.verbose("[\(logNumber)] not so important", userInfo: ["userInfo key": "userInfo value"])
        logNumber += 1
    }
    
    @IBAction func debug() {
        Logger.shared.debug("[\(logNumber)] something to debug", userInfo: ["userInfo key": "userInfo value"])
        logNumber += 1
    }
    
    @IBAction func info() {
        Logger.shared.info("[\(logNumber)] a nice information", userInfo: ["userInfo key": "userInfo value"])
        logNumber += 1
    }
    
    @IBAction func warning() {
        Logger.shared.warning("[\(logNumber)] oh no, that won’t be good", userInfo: ["userInfo key": "userInfo value"])
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
        
        Logger.shared.error("[\(logNumber)] ouch, an error did occur!", error: unreadableError, userInfo: ["userInfo key": "userInfo value"])
        logNumber += 1
    }
    
    @IBAction func forceSend() {
        Logger.shared.forceSend()
    }

}

