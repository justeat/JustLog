//
//  NSError+Readability.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 15/12/2016.
//
//

import Foundation

extension NSError {
    
    
    /// Parses Data values in the user info key as String and recursively does the same to all associated underying errors.
    ///
    /// - Returns: A copy of the error including 
    func humanReadableError() -> NSError {
        
        var flattenedUserInfo = userInfo
        
        for (key, value) in userInfo {
            
            switch (value) {
            case is String:
                flattenedUserInfo[key] = value
            case is Data:
                flattenedUserInfo[key] = String(data: value as! Data, encoding: String.Encoding.utf8)
            case is NSError:
                let innerErr = value as! NSError
                flattenedUserInfo[key] = innerErr.humanReadableError()
            default:
                continue
            }
        }
        return NSError(domain: domain, code: code, userInfo: flattenedUserInfo)
    }
}
