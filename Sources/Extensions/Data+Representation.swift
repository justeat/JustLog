//  Data+Representation.swift

import Foundation

extension Data {
    
    func stringRepresentation() -> String {
        String(data: self, encoding: .utf8) ?? ""
    }
}
