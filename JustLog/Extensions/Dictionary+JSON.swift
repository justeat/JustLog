//
//  Dictionary+JSON.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 15/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func toJSON() -> String? {
        
        var json: String? = nil
        
        if (JSONSerialization.isValidJSONObject(self)) {
            do {
                json = try JSONSerialization.data(withJSONObject: self).stringRepresentation()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return json
    }
    
}
