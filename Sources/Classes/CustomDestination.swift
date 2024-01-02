//  CustomDestination.swift

import Foundation
import SwiftyBeaver

public protocol CustomDestinationSender {
    func log(_ string: String)
}

public class CustomDestination: BaseDestination {
    
    let sender: CustomDestinationSender
    
    init(sender: CustomDestinationSender) {
        self.sender = sender
    }
    
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String,
                              function: String, line: Int, context: Any? = nil) -> String? {
        
        if let str = super.send(level, msg: msg,
                                thread: thread,
                                file: file,
                                function: function,
                                line: line) {
            sender.log(str)
            return str
        }
        
        sender.log(msg)
        return msg
    }
}
