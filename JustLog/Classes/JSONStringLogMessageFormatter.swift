//  JSONStringLogMessageFormatter.swift

import Foundation
import UIKit

public struct FormatterKeys: FormatterKeysProviding {
    
    public var logTypeKey: String
    public var appBundleIDKey: String
    public var appVersionKey: String
    public var deviceTimestampKey: String
    public var deviceTypeKey: String
    public var errorCodeKey: String
    public var errorDomainKey: String
    public var errorsKey: String
    public var fileKey: String
    public var functionKey: String
    public var iosVersionKey: String
    public var lineKey: String
    public var messageKey: String
    public var metadataKey: String
    public var userInfoKey: String
    
    public init (logTypeKey: String = "log_type",
                 appBundleIDKey: String = "app_bundle_ID",
                 appVersionKey: String = "app_version",
                 deviceTimestampKey: String = "device_timestamp",
                 deviceTypeKey: String = "ios_device",
                 errorCodeKey: String = "error_code",
                 errorDomainKey: String = "error_domain",
                 errorsKey: String = "errors",
                 fileKey: String = "file",
                 functionKey: String = "function",
                 iosVersionKey: String = "ios_version",
                 lineKey: String = "line",
                 messageKey: String = "message",
                 metadataKey: String = "metadata",
                 userInfoKey: String = "user_info") {
        self.logTypeKey = logTypeKey
        self.appBundleIDKey = appBundleIDKey
        self.appVersionKey = appVersionKey
        self.deviceTimestampKey = deviceTimestampKey
        self.deviceTypeKey = deviceTypeKey
        self.errorCodeKey = errorCodeKey
        self.errorDomainKey = errorDomainKey
        self.errorsKey = errorsKey
        self.fileKey = fileKey
        self.functionKey = functionKey
        self.iosVersionKey = iosVersionKey
        self.lineKey = lineKey
        self.messageKey = messageKey
        self.metadataKey = metadataKey
        self.userInfoKey = userInfoKey
    }
}

public class JSONStringLogMessageFormatter: LogMessageFormatting {
    
    public var keys: FormatterKeysProviding
    public var defaultLogMetadata: DefaultLogMetadata?
    
    public init(keys: FormatterKeysProviding, defaultLogMetadata: DefaultLogMetadata? = nil) {
        self.keys = keys
        self.defaultLogMetadata = defaultLogMetadata
    }
    
    public func format(_ log: Loggable) -> String {
        var metadata = [String: Any]()
        metadata[keys.messageKey] = log.message
        metadata[keys.metadataKey] = metadataDictionary(log.file, log.function, log.line)
        
        var userInfo = defaultLogMetadata ?? [String: Any]()
        userInfo[keys.logTypeKey] = log.type.rawValue
        if let customData = log.customData {
            for (key, value) in customData {
                _ = userInfo.updateValue(value, forKey: key)
            }
            metadata[keys.userInfoKey] = userInfo
        }
        
        if let error = log.error {
            let errorDictionaries = error.disassociatedErrorChain()
                .map { errorDictionary(for: $0) }
                .filter { JSONSerialization.isValidJSONObject($0) }
            metadata[keys.errorsKey] = errorDictionaries
        }
        
        return metadata.toJSON() ?? ""
    }
    
    func metadataDictionary(_ file: String, _ function: String, _ line: UInt, _ currentDate: Date = Date()) -> [String: Any] {
        var metadata = [String: String]()
        
        if let url = URL(string: file) {
            metadata[keys.fileKey] = URLComponents(url: url, resolvingAgainstBaseURL: false)?.url?.pathComponents.last ?? file
        }
        
        metadata[keys.functionKey] = function
        metadata[keys.lineKey] = String(line)
        
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"], let bundleShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            metadata[keys.appVersionKey] = "\(bundleShortVersion) (\(bundleVersion))"
        }
        
        metadata[keys.iosVersionKey] = UIDevice.current.systemVersion
        metadata[keys.deviceTypeKey] = UIDevice.current.platform()
        metadata[keys.appBundleIDKey] = Bundle.main.bundleIdentifier
        metadata[keys.deviceTimestampKey] = "\(currentDate.timeIntervalSince1970)"
        
        return metadata
    }
    
    func errorDictionary(for error: NSError) -> [String: Any] {
        let userInfoConst = "user_info"
        var errorInfo = [keys.errorDomainKey: error.domain,
                         keys.errorCodeKey: error.code] as [String: Any]
        let errorUserInfo = error.humanReadableError().userInfo
        errorInfo[userInfoConst] = errorUserInfo
        return errorInfo
    }
}
