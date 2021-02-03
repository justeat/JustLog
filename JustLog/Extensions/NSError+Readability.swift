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
            case let string as String:
                flattenedUserInfo[key] = string
            case let data as Data:
                flattenedUserInfo[key] = String(data: data, encoding: String.Encoding.utf8)
            case let error as NSError:
                flattenedUserInfo[key] = error.humanReadableError()
            default:
                
                if !JSONSerialization.isValidJSONObject(value) {
                    var nonSerialisableObject: Any
                    
                    switch value {
                    case let object as NSObject:
                        nonSerialisableObject = object.description
                    case let object as CustomStringConvertible:
                        nonSerialisableObject = object.description
                    default:
                        nonSerialisableObject = "The value for key '\(key)' can't be serialised"
                    }
                    
                    flattenedUserInfo[key] = nonSerialisableObject
                }
            }
        }
        
        return NSError(domain: domain, code: code, userInfo: flattenedUserInfo)
    }
}
