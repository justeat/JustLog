//
//  Logging.swift
//  JustLog
//
//  Created by Oliver Pearmain  (Contractor) on 08/06/2017.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import UIKit

public protocol Logging {
    
    func verbose(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt)
    
    func debug(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt)
    
    func info(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt)
    
    func warning(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt)
    
    func error(_ message: String, error: NSError?, userInfo: [String : Any]?, _ file: StaticString, _ function: StaticString, _ line: UInt)
    
}


// We have to use extension methods to set the default values since protocols don't direct support default values

extension Logging {
    
    public func verbose(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
        verbose(message, error: error, userInfo: userInfo, file, function, line)
    }
    
    public func debug(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
        debug(message, error: error, userInfo: userInfo, file, function, line)
    }
    
    public func info(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
        info(message, error: error, userInfo: userInfo, file, function, line)
    }
    
    public func warning(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
        warning(message, error: error, userInfo: userInfo, file, function, line)
    }
    
    public func error(_ message: String, error: NSError? = nil, userInfo: [String : Any]? = nil, _ file: StaticString = #file, _ function: StaticString = #function, _ line: UInt = #line) {
        self.error(message, error: error, userInfo: userInfo, file, function, line)
    }
    
}
