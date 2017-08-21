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
    enum KeyMergePolicy {
        case override
        case encapsulateFlatten
    }
    
    func flattened() -> [String : Any] {
        
        var retVal = [String : Any]()
        
        for (k, v) in self {
            switch v {
            case is String,
                 is Int,
                 is Double,
                 is Bool:
                retVal.updateValue(v, forKey: k)
            case is Dictionary:
                let inner = (v as! [String : Any]).flattened()
                retVal = retVal.merged(with: inner)
            case is Array<Any>:
                retVal.updateValue(String(describing: v), forKey: k)
            case is NSError:
                if let inner = v as? NSError, let userInfo: [String: Any] = inner.userInfo as? [String : Any] {
                    retVal = retVal.merged(with: userInfo.flattened())
                }
            default:
                continue
            }
        }
        
        return retVal
    }

    
    func merged(with dictionary: [String : Any], policy: KeyMergePolicy = .override) -> [String : Any] {
        switch policy {
        case .override:
            return mergeDictionaryByReplacingValues(self, with: dictionary)
        case .encapsulateFlatten:
            return mergeDictionariesByGroupingValues(self, with: dictionary)
        }
    }
    
    private func mergeDictionaryByReplacingValues(_ dictionary: [String : Any], with dictionary2: [String : Any]) -> [String : Any] {
        var retValue = dictionary
        dictionary2.forEach { (key, value) in
            retValue.updateValue(value, forKey: key)
        }
        return retValue
    }
    
    private func mergeDictionariesByGroupingValues(_ dictionary: [String : Any], with dictionary2: [String : Any]) -> [String : Any] {
        var retVal: [String : Any] = [:]
        dictionary2.forEach { (key, value) in
            if let value1 = dictionary[key] {
                let mergedValue: [Any] = [value1, value]
                retVal.updateValue(mergedValue, forKey: key)
            }
            else {
                retVal.updateValue(value, forKey: key)
            }
        }
        return retVal
    }
}
