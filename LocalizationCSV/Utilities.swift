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
    if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) == false {
        return false
    }
    return isDirectory.boolValue
}

public func isTextFieldValueADirectoryPath(textField: NSTextField) -> Bool {
    let path = textField.stringValue
    return isPathDirectory(path)
}

public func isTextFieldValueValidPath(textField: NSTextField, withValidFileExtension: String?) -> Bool {
    let path = textField.stringValue
    if let fileExtension = withValidFileExtension {
        if (path as NSString).pathExtension != fileExtension {
            return false
        }
    }
    return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: nil)
}

func deleteFileAtPath(path: String) throws {
    try NSFileManager.defaultManager().removeItemAtPath(path)
}

func deleteContentsOfDirectoryAtPath(path: String) throws {
    
}

func csvFileContents(csvFilePath: String) throws -> String {
    guard let data = NSData(contentsOfFile: csvFilePath) else {
        throw Error.FailedToReadCSVFile(message: "Could not load CSV file at path: \(csvFilePath)")
    }
    
    var convertedString: NSString? = nil
    let encoding = NSString.stringEncodingForData(data, encodingOptions: nil, convertedString: &convertedString, usedLossyConversion: nil)
    
    guard let string = convertedString else {
        throw Error.FailedToReadCSVFile(message: "Could decode CSV file at path: \(csvFilePath)")
    }
    
    if encoding == NSUTF8StringEncoding {
        return string as String
    }
    
    guard let utf8Data = string.dataUsingEncoding(NSUTF8StringEncoding) else {
        throw Error.FailedToReadCSVFile(message: "Could decode CSV file at path: \(csvFilePath)")
    }
    guard let utf8String = NSString(data: utf8Data, encoding: NSUTF8StringEncoding) else {
        throw Error.FailedToReadCSVFile(message: "Could decode CSV file at path: \(csvFilePath)")
    }
    
    return utf8String as String
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
