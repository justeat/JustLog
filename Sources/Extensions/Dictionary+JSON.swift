//  Dictionary+JSON.swift

import Foundation

extension Dictionary {
    
    /// Parses the dictionary as a json data object and returns the String representation.
    ///
    /// - Returns: The String representation of the dictionary
    func toJSON() -> String? {
        
        var json: String?
        
        if JSONSerialization.isValidJSONObject(self) {
            do {
                json = try JSONSerialization.data(withJSONObject: self).stringRepresentation()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return json
    }
}
