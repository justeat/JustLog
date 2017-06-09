//
//  Logging.swift
//  JustLog
//
//  Created by Oliver Pearmain  (Contractor) on 08/06/2017.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import UIKit

public protocol Logging {
    
    func verbose(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: String, _ function: String, _ line: Int)
    
    func debug(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: String, _ function: String, _ line: Int)
    
    func info(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: String, _ function: String, _ line: Int)
    
    func warning(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: String, _ function: String, _ line: Int)
    
    func error(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: String, _ function: String, _ line: Int)
    
}


// We have to use extension methods to set the default values since protocols don't direct support default values

extension Logging {
    
    public func verbose(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        verbose(message, error: error, userInfo: userInfo, file, function, line)
    }
    
    public func debug(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        debug(message, error: error, userInfo: userInfo, file, function, line)
    }
    
    public func info(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        info(message, error: error, userInfo: userInfo, file, function, line)
    }
    
    public func warning(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        warning(message, error: error, userInfo: userInfo, file, function, line)
    }
    
    public func error(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        self.error(message, error: error, userInfo: userInfo, file, function, line)
    }
    
}
