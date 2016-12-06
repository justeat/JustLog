//
//  Dictionary+Flattening.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 15/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { _ = updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
    
    func flattened() -> [String : Any] {
        
        var retVal = [String : Any]()
        
        for (k, v) in self {
            switch v {
            case is String:
                retVal.updateValue(v, forKey: k as! String)
            case is Int:
                retVal.updateValue(v, forKey: k as! String)
            case is Double:
                retVal.updateValue(v, forKey: k as! String)
            case is Bool:
                retVal.updateValue(v, forKey: k as! String)
            case is Dictionary:
                let inner = (v as! [String : Any]).flattened()
                retVal = retVal.merged(with: inner)
            case is Array<Any>:
                retVal.updateValue(String(describing: v), forKey: k as! String)
            case is NSError:
                let inner = (v as! NSError)
                retVal = retVal.merged(with: inner.userInfo.flattened())
            default:
                continue
            }
        }

        return retVal
    }
    
}
