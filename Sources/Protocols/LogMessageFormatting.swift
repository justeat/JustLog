//  LogMessageFormatting.swift

import Foundation

public typealias DefaultLogMetadata = [String: Any]

public protocol FormatterKeysProviding {
    
    var logTypeKey: String { get set }
    var appBundleIDKey: String { get set }
    var appVersionKey: String { get set }
    var deviceTimestampKey: String { get set }
    var deviceTypeKey: String { get set }
    var errorCodeKey: String { get set }
    var errorDomainKey: String { get set }
    var errorsKey: String { get set }
    var fileKey: String { get set }
    var functionKey: String { get set }
    var iosVersionKey: String { get set }
    var lineKey: String { get set }
    var messageKey: String { get set }
    var metadataKey: String { get set }
    var userInfoKey: String { get set }
}

public protocol LogMessageFormatting {
    
    var keys: FormatterKeysProviding { get set }
    var defaultLogMetadata: DefaultLogMetadata? { get set }
    
    func format(_ log: Loggable) -> String
}
