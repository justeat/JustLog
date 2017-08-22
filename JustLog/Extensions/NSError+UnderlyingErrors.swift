//
//  NSError+UnderlyingErrors.swift
//  Pods
//
//  Created by Alkiviadis Papadakis on 22/08/2017.
//
//

import Foundation
extension NSError {
    
    /// Extracts and returns all the errors under the NSUnderlyingErrorKey, recursively.
    ///
    /// - Returns: An Array<NSError> with all the underlying errors excluding self
    func underlyingErrors() -> [NSError] {
        guard let underError = self.userInfo[NSUnderlyingErrorKey] as? NSError else {
            return []
        }
        
        return [underError] + underError.underlyingErrors()
    }
    
    /// Extracts and returns all the errors under the NSUnderlyingErrorKey, recursively.
    ///
    /// - Returns: An Array<NSError> with all the underlying errors including self
    func errorChain() -> [NSError] {
        
        guard let underError = self.userInfo[NSUnderlyingErrorKey] as? NSError else {
            return [self]
        }
        
        return [self] + underError.errorChain()
    }
    
    /// Extracts and returns all the errors under the NSUnderlyingErrorKey, recursively.
    /// after extracting an error, it creates a copy of it self by removing the NSUnderlyingErrorKey key.
    ///
    /// - Returns: An Array<NSError> with all the underlying errors including self after it disassociates the connected errors.
    func disassociatedErrorChain() -> [NSError] {
        
        guard let underError = self.userInfo[NSUnderlyingErrorKey] as? NSError else {
            return [self]
        }
        
        var userInfoCopy = self.userInfo
        userInfoCopy.removeValue(forKey: NSUnderlyingErrorKey)
        let copyOfSelf = NSError(domain: self.domain, code: self.code, userInfo: userInfoCopy)
        
        return [copyOfSelf] + underError.disassociatedErrorChain()
    }
}
