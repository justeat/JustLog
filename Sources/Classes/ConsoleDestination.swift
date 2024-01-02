//  ConsoleDestination.swift

import Foundation
import SwiftyBeaver

public class ConsoleDestination: BaseDestination {
    
    public override init() {
        super.init()
        
        levelColor.verbose = "📣 "
        levelColor.debug = "📝 "
        levelColor.info = "ℹ️ "
        levelColor.warning = "⚠️ "
        levelColor.error = "☠️ "
    }

    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String,
                              function: String, line: Int, context: Any? = nil) -> String? {
        
        let dict = msg.toDictionary()
        guard let innerMessage = dict?["message"] as? String else { return nil }
        
        let formattedString = super.send(level, msg: innerMessage, thread: thread, file: file, function: function, line: line)

        if let str = formattedString {
            print(str)
        }
        return formattedString
    }
}
