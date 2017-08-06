//
//  Utilities.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

public func outputStringFromLaunchPath(_ launchPath: String, arguments: Array<String>) -> String {
    let task = Process()
    
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    let fileHandle = pipe.fileHandleForReading
    
    task.launch()
    let outputData = fileHandle.readDataToEndOfFile()
    return NSString(data: outputData, encoding: String.Encoding.utf8.rawValue)! as String
}

public func executeShellCommand(_ command: String) -> String {
    return outputStringFromLaunchPath("/bin/sh", arguments: [ "-c", command ])
}

public func isPathDirectory(_ path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) == false {
        return false
    }
    return isDirectory.boolValue
}

public func isTextFieldValueADirectoryPath(_ textField: NSTextField) -> Bool {
    let path = textField.stringValue
    return isPathDirectory(path)
}

public func isTextFieldValueValidPath(_ textField: NSTextField, withValidFileExtension: String?) -> Bool {
    let path = textField.stringValue
    if let fileExtension = withValidFileExtension {
        if (path as NSString).pathExtension != fileExtension {
            return false
        }
    }
    return FileManager.default.fileExists(atPath: path, isDirectory: nil)
}

func deleteFileAtPath(_ path: String) throws {
    try FileManager.default.removeItem(atPath: path)
}

func deleteContentsOfDirectoryAtPath(_ path: String) throws {
    let contents = try FileManager.default.contentsOfDirectory(atPath: path)
    for content in contents {
        let contentPath = (path as NSString).appendingPathComponent(content)
        if isPathDirectory(contentPath) {
            try deleteContentsOfDirectoryAtPath(contentPath)
        } else {
            try deleteFileAtPath(contentPath)
        }
    }
}

func csvFileContents(_ csvFilePath: String) throws -> String {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: csvFilePath)) else {
        throw GeneratorsError.failedToReadCSVFile(message: "Could not load CSV file at path: \(csvFilePath)")
    }
    
    var convertedString: NSString? = nil
    let encoding = NSString.stringEncoding(for: data, encodingOptions: nil, convertedString: &convertedString, usedLossyConversion: nil)
    
    guard let string = convertedString else {
        throw GeneratorsError.failedToReadCSVFile(message: "Could decode CSV file at path: \(csvFilePath)")
    }
    
    if encoding == String.Encoding.utf8.rawValue {
        return string as String
    }
    
    guard let utf8Data = string.data(using: String.Encoding.utf8.rawValue) else {
        throw GeneratorsError.failedToReadCSVFile(message: "Could decode CSV file at path: \(csvFilePath)")
    }
    guard let utf8String = NSString(data: utf8Data, encoding: String.Encoding.utf8.rawValue) else {
        throw GeneratorsError.failedToReadCSVFile(message: "Could decode CSV file at path: \(csvFilePath)")
    }
    
    return utf8String as String
}

extension String {
    func csvEscaped() -> String {
        if self.contains("\"") {
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
        } else if self.contains(",") || self.contains("\n") {
            return "\"" + self + "\""
        }
        
        return self
    }
}

public extension DateFormatter {
    private static var defaultDateFormatter: DateFormatter? = nil
    
    class func nowDateString() -> String {
        if defaultDateFormatter == nil {
            defaultDateFormatter = DateFormatter()
            defaultDateFormatter!.dateFormat = "MM-dd-yyyy-hh-mm-ss-a"
        }
        return defaultDateFormatter!.string(from: Date())
    }
}
