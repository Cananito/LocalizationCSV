//
//  Utilities.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

public func outputStringFromLaunchPath(launchPath: String, arguments: Array<String>) -> String {
    let task = NSTask()
    
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    let fileHandle = pipe.fileHandleForReading
    
    task.launch()
    let outputData = fileHandle.readDataToEndOfFile()
    return NSString(data: outputData, encoding: NSUTF8StringEncoding) as! String
}

public func executeShellCommand(command: String) -> String {
    return outputStringFromLaunchPath("/bin/sh", arguments: [ "-c", command ])
}

public func isPathDirectory(path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory:&isDirectory) == false {
        return false
    }
    return isDirectory.boolValue
}

public func isTextFieldValueADirectoryPath(textField: NSTextField) -> Bool {
    let path = textField.stringValue
    return isPathDirectory(path)
}

extension String {
    func csvEscaped() -> String {
        if self.containsString("\"") {
            var escapedCharacters = [Character]()
            escapedCharacters.append("\"")
            for character in self.characters {
                if character == "\"" {
                    escapedCharacters.append("\"")
                    escapedCharacters.append(character)
                } else {
                    escapedCharacters.append(character)
                }
            }
            escapedCharacters.append("\"")
            return String(escapedCharacters)
        } else if self.containsString(",") || self.containsString("\n") {
            return "\"" + self + "\""
        }
        
        return self
    }
}

public extension NSDateFormatter {
    private static var defaultDateFormatter: NSDateFormatter? = nil
    
    class func nowDateString() -> String {
        if defaultDateFormatter == nil {
            defaultDateFormatter = NSDateFormatter()
            defaultDateFormatter!.dateFormat = "MM-dd-yyyy-hh-mm-ss-a"
        }
        return defaultDateFormatter!.stringFromDate(NSDate())
    }
}
