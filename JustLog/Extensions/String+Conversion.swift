//
//  String+Conversion.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 15/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation

extension String {
    
    func toDictionary() -> [String : Any]? {
        
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
