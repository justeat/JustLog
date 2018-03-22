//
//  FileDestination.swift
//  JustLog
//
//  Created by Alberto De Bortoli on 20/12/2016.
//  Copyright © 2017 Just Eat. All rights reserved.
//

import Foundation
import SwiftyBeaver

public class FileDestination: BaseDestination {

    public var logFileURL: URL?

    var fileHandle: FileHandle? = nil
    
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
        
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)

        if let str = formattedString {
            let _ = saveToFile(str: str)
        }
        return formattedString
    }

    deinit {
        if let fileHandle = fileHandle {
            fileHandle.closeFile()
        }
    }

    func saveToFile(str: String) -> Bool {
        guard let url = logFileURL else { return false }
        do {
            if FileManager.default.fileExists(atPath: url.path) == false {
                let line = str + "\n"
                try line.write(to: url, atomically: true, encoding: .utf8)
            } else {
                if fileHandle == nil {
                    fileHandle = try FileHandle(forWritingTo: url as URL)
                }
                if let fileHandle = fileHandle {
                    let _ = fileHandle.seekToEndOfFile()
                    let line = str + "\n"
                    if let data = line.data(using: String.Encoding.utf8) {
                        fileHandle.write(data)
                    }
                }
            }
            return true
        } catch {
            print("SwiftyBeaver File Destination could not write to file \(url).")
            return false
        }
    }
}
