//
//  Data+Representation.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 15/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation

extension Data {
    
    func stringRepresentation() -> String {
        let retVal = NSString(data: self, encoding: String.Encoding.utf8.rawValue) as? String
        return retVal ?? ""
    }
}
