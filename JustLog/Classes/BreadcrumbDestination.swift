//
//  CustomDestination.swift
//  JustLog
//
//  Created by Antonio Strijdom on 01/02/2021.
//

import Foundation
import SwiftyBeaver

public protocol BreadcrumbDestinationSender {
    func log(_ string: String)
}

public class CustomDestination: BaseDestination {
    
    let sender: BreadcrumbDestinationSender
    
    init(sender: BreadcrumbDestinationSender) {
        self.sender = sender
    }
    
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String,
                              function: String, line: Int, context: Any? = nil) -> String? {
        
        let dict = msg.toDictionary()
        guard let innerMessage = dict?["message"] as? String else { return nil }
        
        let formattedString = super.send(level, msg: innerMessage, thread: thread, file: file, function: function, line: line)

        if let str = formattedString {
            sender.log(str)
        }
        return formattedString
    }
}
