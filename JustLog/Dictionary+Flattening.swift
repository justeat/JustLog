//
//  Dictionary+Flattening.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 15/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    
    /// Defines how the dictionary will be flattened and the key-value pairs will be merged.
    ///
    /// - override: Overrides the keys and the values.
    /// - encapsulateFlatten: keeps the keys and adds the values to an array.
    
    func flattened() -> [String : Any] {
        
        var retVal = [String : Any]()
        
        for (k, v) in self {
            switch v {
            case is String,
                 is Int,
                 is Double,
                 is Bool:
                retVal.updateValue(v, forKey: k)
            case is [String : Any]:
                if let value: [String : Any] = v as? [String : Any] {
                    let inner = value.flattened()
                    retVal = retVal.merged(with: inner)
                }
                else {
                    continue
                }
            case is Array<Any>:
                retVal.updateValue(String(describing: v), forKey: k)
            case is NSError:
                if let inner = v as? NSError {
                    retVal = retVal.merged(with: inner.userInfo.flattened())
                }
                else {
                    continue
                }
            default:
                continue
            }
        }
        
        return retVal
    }
    
    func merged(with dictionary: [String : Any]) -> [String : Any] {
        var retValue = self as [String :Any]
        dictionary.forEach { (key, value) in
            retValue.updateValue(value, forKey: key)
        }
        return retValue
    }
}
