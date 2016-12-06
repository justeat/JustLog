//
//  Logger+ObjC.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 20/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation

extension Logger {
    
    //MARK: verbose
    
    public func verbose_objc(_ message: String) {
        self.verbose(message)
    }
    
    public func verbose_objc(_ message: String, error: NSError?) {
        self.verbose(message, error: error)
    }
    
    public func verbose_objc(_ message: String, userInfo: [String : Any]?) {
        self.verbose(message, userInfo: userInfo)
    }
    
    public func verbose_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.verbose(message, error: error, userInfo: userInfo)
    }
    
    //MARK: debug
    
    public func debug_objc(_ message: String) {
        self.debug(message)
    }
    
    public func debug_objc(_ message: String, error: NSError?) {
        self.debug(message, error: error)
    }
    
    public func debug_objc(_ message: String, userInfo: [String : Any]?) {
        self.debug(message, userInfo: userInfo)
    }
    
    public func debug_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.debug(message, error: error, userInfo: userInfo)
    }
    
    //MARK: info
    
    public func info_objc(_ message: String) {
        self.info(message)
    }
    
    public func info_objc(_ message: String, error: NSError?) {
        self.info(message, error: error)
    }
    
    public func info_objc(_ message: String, userInfo: [String : Any]?) {
        self.info(message, userInfo: userInfo)
    }
    
    public func info_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.info(message, error: error, userInfo: userInfo)
    }
    
    //MARK: warning
    
    public func warning_objc(_ message: String) {
        self.warning(message)
    }
    
    public func warning_objc(_ message: String, error: NSError?) {
        self.warning(message, error: error)
    }
    
    public func warning_objc(_ message: String, userInfo: [String : Any]?) {
        self.warning(message, userInfo: userInfo)
    }
    
    public func warning_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.warning(message, error: error, userInfo: userInfo)
    }
    
    //MARK: error
    
    public func error_objc(_ message: String) {
        self.error(message)
    }
    
    public func error_objc(_ message: String, error: NSError?) {
        self.error(message, error: error)
    }
    
    public func error_objc(_ message: String, userInfo: [String : Any]?) {
        self.error(message, userInfo: userInfo)
    }
    
    public func error_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.error(message, error: error, userInfo: userInfo)
    }
}
