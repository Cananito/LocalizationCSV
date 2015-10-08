//
//  CSVsGenerator.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Foundation

enum Error: ErrorType {
    case DestinationFolderAlreadyExists(message: String)
    case FailedToGenerateStringsFile(message: String)
    case FailedToReadCSVFile(message: String)
}

func generateCSVsForFolderPath(folderPath: String, destinationPath: String) throws {
    let folderName = NSDateFormatter.nowDateString()
    let destinationPath = destinationPath + "/" + folderName
    if NSFileManager.defaultManager().fileExistsAtPath(destinationPath) {
        throw Error.DestinationFolderAlreadyExists(message: "Folder named '\(folderName)' already exists!")
    } else {
        try NSFileManager.defaultManager().createDirectoryAtPath(destinationPath, withIntermediateDirectories: false, attributes: nil)
    }
    
    try generateCSVFromLocalizableStringsFileForProject(folderPath, destinationPath: destinationPath)
    try generateCSVsFromInterfaceBuilderFiles(folderPath, destinationPath: destinationPath)
    try appendExistingTranslationsFromFolder(folderPath, destinationPath: destinationPath)
}

func updateStringsFilesForFolderPath(folderPath: String, csvsFolderPath: String) throws {
    let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath)
    for content in contents {
        if content == "Base.lproj" {
            let baseFolderPath = folderPath.stringByAppendingFormat("/%@", content)
            try updateStringsFilesForBaseFolderPath(baseFolderPath, folderPath: folderPath, csvsFolderPath: csvsFolderPath)
        }
        
        let path = folderPath.stringByAppendingFormat("/%@", content)
        if isPathDirectory(path) {
            try updateStringsFilesForFolderPath(path, csvsFolderPath: csvsFolderPath)
        }
    }
}

// MARK: Localizable.strings

private func generateCSVFromLocalizableStringsFileForProject(folderPath: String, destinationPath: String) throws {
    // `find ./ -name "*.m" -print0 | xargs -0 genstrings -o .`
    executeShellCommand("find \(folderPath) -name \"*.m\" -print0 | xargs -0 genstrings -o \(destinationPath)")
    
    let destinationContents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(destinationPath)
    if destinationContents.count == 0 {
        throw Error.FailedToGenerateStringsFile(message: "Failed to generate the strings files.")
    }
    
    for stringsFile in destinationContents {
        let stringsFilePath = "\(destinationPath)/\(stringsFile)"
        try generateCSVFromStringsFilePath(stringsFilePath, destinationPath: destinationPath)
        try deleteFileAtPath(stringsFilePath)
    }
}

// MARK: Interface Builder

private func generateCSVsFromInterfaceBuilderFiles(folderPath: String, destinationPath: String) throws {
    let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath)
    for content in contents {
        if content == "Base.lproj" {
            let baseFolderPath = folderPath.stringByAppendingFormat("/%@", content)
            try generateCSVsFromInterfaceBuilderBaseFolder(baseFolderPath, destinationPath: destinationPath)
        }
        
        let path = folderPath.stringByAppendingFormat("/%@", content)
        if isPathDirectory(path) {
            try generateCSVsFromInterfaceBuilderFiles(path, destinationPath: destinationPath)
        }
    }
}

private func generateCSVsFromInterfaceBuilderBaseFolder(folderPath: String, destinationPath: String) throws {
    let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath)
    for content in contents {
        if content.hasSuffix(".storyboard") == false && content.hasSuffix(".xib") == false {
            continue
        }
        
        let path = folderPath.stringByAppendingFormat("/%@", content)
        let destination = destinationPath + "/" + (content as NSString).stringByDeletingPathExtension + ".strings"
        let escapedPath = path.stringByReplacingOccurrencesOfString(" ", withString: "\\ ")
        let escapedDestination = destination.stringByReplacingOccurrencesOfString(" ", withString: "\\ ")
        
        // `ibtool --export-strings-file Main.strings Main.storyboard`
        executeShellCommand("ibtool --export-strings-file \(escapedDestination) \(escapedPath)")
        try generateCSVFromStringsFilePath(destination, destinationPath: destinationPath)
        try deleteFileAtPath(destination)
    }
}

// MARK: CSV to Strings

func updateStringsFilesForBaseFolderPath(baseFolderPath: String, folderPath: String, csvsFolderPath: String) throws {
    let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(baseFolderPath)
    for content in contents {
        if !content.hasSuffix(".storyboard") && !content.hasSuffix(".xib") && !content.hasSuffix(".strings") {
            continue
        }
        
        let fileName = (content as NSString).stringByDeletingPathExtension
        if content.hasSuffix(".storyboard") || content.hasSuffix(".xib") {
            try updateStringsFilesForFile(fileName, folderPath: folderPath, includeBaseLocalization: false, csvsFolderPath: csvsFolderPath)
        } else {
            try updateStringsFilesForFile(fileName, folderPath: folderPath, includeBaseLocalization: true, csvsFolderPath: csvsFolderPath)
        }
    }
}

func updateStringsFilesForFile(fileName: String, folderPath: String, includeBaseLocalization: Bool, csvsFolderPath: String) throws {
    if let csvFilePath = try csvFilePathForFileName(fileName, inDestinationPath: csvsFolderPath) {
        let textRepresentation = try csvFileContents(csvFilePath)
        let csv = CSV(textRepresentation: textRepresentation, name: fileName)
        
        let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath)
        for content in contents {
            if !includeBaseLocalization && content.hasPrefix("Base") {
                continue
            }
            
            if !content.hasSuffix(".lproj") {
                continue
            }
            
            var language = "?"
            if let l = try localeDisplayNameForFolderName(content) {
                language = l
            }
            let stringsFile = StringsFile(csv: csv, language: language)
            let contentPath = folderPath.stringByAppendingFormat("/%@", content)
            try persistStringsFile(stringsFile, fileName: fileName, destiantionPath: contentPath)
        }
    }
}

// MARK: Appending

private func appendExistingTranslationsFromFolder(folderPath: String, destinationPath: String) throws {
    let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath)
    for content in contents {
        if content.hasSuffix(".lproj") && content.hasPrefix("Base") == false {
            let localeFolderPath = folderPath.stringByAppendingFormat("/%@", content)
            try appendExistingTranslationsFromLocaleFolder(localeFolderPath, destinationPath: destinationPath)
        }
        
        let path = folderPath.stringByAppendingFormat("/%@", content)
        if isPathDirectory(path) {
            try appendExistingTranslationsFromFolder(path, destinationPath: destinationPath)
        }
    }
}

private func appendExistingTranslationsFromLocaleFolder(folderPath: String, destinationPath: String) throws {
    let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath)
    for content in contents {
        if content.hasSuffix(".strings") == false {
            continue
        }
        
        let fileName = (content as NSString).stringByDeletingPathExtension
        if let csvFilePath = try csvFilePathForFileName(fileName, inDestinationPath: destinationPath) {
            let stringsFilePath = folderPath.stringByAppendingFormat("/%@", content)
            let stringsFileContents = try NSString(contentsOfFile: stringsFilePath, usedEncoding: nil) as String
            let stringsFile = StringsFile(textRepresentation: stringsFileContents)
            
            var language = "?"
            if let l = try localeDisplayNameForFolderName((folderPath as NSString).lastPathComponent) {
                language = l
            }
            
            let csvFileContents = try NSString(contentsOfFile: csvFilePath, usedEncoding: nil) as String
            var csv = CSV(textRepresentation: csvFileContents, name: fileName)
            csv.addExistingTranslation(stringsFile, language: language)
            try persistCSV(csv, destinationPath: destinationPath)
        }
    }
}

// MARK: General

private func deleteFileAtPath(path: String) throws {
    try NSFileManager.defaultManager().removeItemAtPath(path)
}

private func generateCSVFromStringsFilePath(filePath: String, destinationPath: String) throws {
    let fileContents = try NSString(contentsOfFile: filePath, usedEncoding: nil) as String
    let stringsFile = StringsFile(textRepresentation: fileContents)
    let csvFileName = ((filePath as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
    let csv = CSV(baseStringsFile: stringsFile, name: csvFileName)
    try persistCSV(csv, destinationPath: destinationPath)
}

private func persistCSV(csv: CSV, destinationPath: String) throws {
    let csvText = csv.textRepresentation() as NSString
    let csvFilePath = destinationPath.stringByAppendingFormat("/%@.csv", csv.name)
    try csvText.writeToFile(csvFilePath, atomically: true, encoding: NSUTF8StringEncoding)
}

private func persistStringsFile(stringsFile: StringsFile, fileName: String, destiantionPath: String) throws {
    let stringsFileText = stringsFile.textRepresentation()
    let stringsFilePath = destiantionPath.stringByAppendingFormat("/%@.strings", fileName)
    try stringsFileText.writeToFile(stringsFilePath, atomically: true, encoding: NSUTF8StringEncoding)
}

private func csvFilePathForFileName(fileName: String, inDestinationPath: String) throws -> String? {
    let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(inDestinationPath)
    for content in contents {
        if (content as NSString).stringByDeletingPathExtension == fileName {
            return inDestinationPath.stringByAppendingFormat("/%@", content)
        }
    }
    return nil
}

private func csvFileContents(csvFilePath: String) throws -> String {
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
