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
    
    @objc public func verbose_objc(_ message: String) {
        self.verbose(message)
    }
    
    @objc public func verbose_objc(_ message: String, error: NSError?) {
        self.verbose(message, error: error)
    }
    
    @objc public func verbose_objc(_ message: String, userInfo: [String : Any]?) {
        self.verbose(message, userInfo: userInfo)
    }
    
    @objc public func verbose_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.verbose(message, error: error, userInfo: userInfo)
    }
    
    //MARK: debug
    
    @objc public func debug_objc(_ message: String) {
        self.debug(message)
    }
    
    @objc public func debug_objc(_ message: String, error: NSError?) {
        self.debug(message, error: error)
    }
    
    @objc public func debug_objc(_ message: String, userInfo: [String : Any]?) {
        self.debug(message, userInfo: userInfo)
    }
    
    @objc public func debug_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.debug(message, error: error, userInfo: userInfo)
    }
    
    //MARK: info
    
    @objc public func info_objc(_ message: String) {
        self.info(message)
    }
    
    @objc public func info_objc(_ message: String, error: NSError?) {
        self.info(message, error: error)
    }
    
    @objc public func info_objc(_ message: String, userInfo: [String : Any]?) {
        self.info(message, userInfo: userInfo)
    }
    
    @objc public func info_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.info(message, error: error, userInfo: userInfo)
    }
    
    //MARK: warning
    
    @objc public func warning_objc(_ message: String) {
        self.warning(message)
    }
    
    @objc public func warning_objc(_ message: String, error: NSError?) {
        self.warning(message, error: error)
    }
    
    @objc public func warning_objc(_ message: String, userInfo: [String : Any]?) {
        self.warning(message, userInfo: userInfo)
    }
    
    @objc public func warning_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.warning(message, error: error, userInfo: userInfo)
    }
    
    //MARK: error
    
    @objc public func error_objc(_ message: String) {
        self.error(message)
    }
    
    @objc public func error_objc(_ message: String, error: NSError?) {
        self.error(message, error: error)
    }
    
    @objc public func error_objc(_ message: String, userInfo: [String : Any]?) {
        self.error(message, userInfo: userInfo)
    }
    
    @objc public func error_objc(_ message: String, error: NSError?, userInfo: [String : Any]?) {
        self.error(message, error: error, userInfo: userInfo)
    }
}
