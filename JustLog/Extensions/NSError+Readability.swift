//
//  NSError+Readability.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 15/12/2016.
//
//

import Foundation

extension NSError {
    
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
    
    func underlyingErrors() -> [NSError] {
        guard let underError = self.userInfo[NSUnderlyingErrorKey] as? NSError else {
            return []
        }
        
        return [underError] + underError.underlyingErrors()
    }
    
    func errorChain() -> [NSError] {
        
        guard let underError = self.userInfo[NSUnderlyingErrorKey] as? NSError else {
            return [self]
        }
        
        return [self] + underError.errorChain()
    }

    
}
