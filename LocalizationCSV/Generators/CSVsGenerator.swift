//
//  CSVsGenerator.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Foundation

func generateCSVsForFolderPath(_ folderPath: String, destinationPath: String) throws {
    let folderName = DateFormatter.nowDateString()
    let destinationPath = destinationPath + "/" + folderName
    if FileManager.default.fileExists(atPath: destinationPath) {
        throw GeneratorsError.destinationFolderAlreadyExists(message: "Folder named '\(folderName)' already exists!")
    } else {
        try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: false, attributes: nil)
    }
    
    try generateCSVFromLocalizableStringsFileForProject(folderPath, destinationPath: destinationPath)
    try generateCSVsFromInterfaceBuilderFiles(folderPath, destinationPath: destinationPath)
    try appendExistingTranslationsFromFolder(folderPath, destinationPath: destinationPath)
}

func updateStringsFilesForFolderPath(_ folderPath: String, csvsFolderPath: String) throws {
    let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
    for content in contents {
        if content == "Base.lproj" {
            let baseFolderPath = folderPath.appendingFormat("/%@", content)
            try updateStringsFilesForBaseFolderPath(baseFolderPath, folderPath: folderPath, csvsFolderPath: csvsFolderPath)
        }
        
        let path = folderPath.appendingFormat("/%@", content)
        if isPathDirectory(path) {
            try updateStringsFilesForFolderPath(path, csvsFolderPath: csvsFolderPath)
        }
    }
}

// MARK: Localizable.strings

private func generateCSVFromLocalizableStringsFileForProject(_ folderPath: String, destinationPath: String) throws {
    // `find ./ -name "*.m" -print0 | xargs -0 genstrings -o .`
    _ = executeShellCommand("find \(folderPath) -name \"*.m\" -print0 | xargs -0 genstrings -o \(destinationPath)")
    
    let destinationContents = try FileManager.default.contentsOfDirectory(atPath: destinationPath)
    if destinationContents.count == 0 {
        throw GeneratorsError.failedToGenerateStringsFile(message: "Failed to generate the strings files.")
    }
    
    for stringsFile in destinationContents {
        let stringsFilePath = "\(destinationPath)/\(stringsFile)"
        try generateCSVFromStringsFilePath(stringsFilePath, destinationPath: destinationPath)
        try deleteFileAtPath(stringsFilePath)
    }
}

// MARK: Interface Builder

private func generateCSVsFromInterfaceBuilderFiles(_ folderPath: String, destinationPath: String) throws {
    let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
    for content in contents {
        if content == "Base.lproj" {
            let baseFolderPath = folderPath.appendingFormat("/%@", content)
            try generateCSVsFromInterfaceBuilderBaseFolder(baseFolderPath, destinationPath: destinationPath)
        }
        
        let path = folderPath.appendingFormat("/%@", content)
        if isPathDirectory(path) {
            try generateCSVsFromInterfaceBuilderFiles(path, destinationPath: destinationPath)
        }
    }
}

private func generateCSVsFromInterfaceBuilderBaseFolder(_ folderPath: String, destinationPath: String) throws {
    let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
    for content in contents {
        if content.hasSuffix(".storyboard") == false && content.hasSuffix(".xib") == false {
            continue
        }
        
        let path = folderPath.appendingFormat("/%@", content)
        let destination = destinationPath + "/" + (content as NSString).deletingPathExtension + ".strings"
        let escapedPath = path.replacingOccurrences(of: " ", with: "\\ ")
        let escapedDestination = destination.replacingOccurrences(of: " ", with: "\\ ")
        
        // `ibtool --export-strings-file Main.strings Main.storyboard`
        _ = executeShellCommand("ibtool --export-strings-file \(escapedDestination) \(escapedPath)")
        try generateCSVFromStringsFilePath(destination, destinationPath: destinationPath)
        try deleteFileAtPath(destination)
    }
}

// MARK: CSV to Strings

func updateStringsFilesForBaseFolderPath(_ baseFolderPath: String, folderPath: String, csvsFolderPath: String) throws {
    let contents = try FileManager.default.contentsOfDirectory(atPath: baseFolderPath)
    for content in contents {
        if !content.hasSuffix(".storyboard") && !content.hasSuffix(".xib") && !content.hasSuffix(".strings") {
            continue
        }
        
        let fileName = (content as NSString).deletingPathExtension
        if content.hasSuffix(".storyboard") || content.hasSuffix(".xib") {
            try updateStringsFilesForFile(fileName, folderPath: folderPath, includeBaseLocalization: false, csvsFolderPath: csvsFolderPath)
        } else {
            try updateStringsFilesForFile(fileName, folderPath: folderPath, includeBaseLocalization: true, csvsFolderPath: csvsFolderPath)
        }
    }
}

func updateStringsFilesForFile(_ fileName: String, folderPath: String, includeBaseLocalization: Bool, csvsFolderPath: String) throws {
    if let csvFilePath = try csvFilePathForFileName(fileName, inDestinationPath: csvsFolderPath) {
        let textRepresentation = try csvFileContents(csvFilePath)
        let newLineCharacter = UserDefaults.standard.string(forKey: NewLineCharacterKey) ?? "\n"
        let csv = CSV(textRepresentation: textRepresentation, name: fileName, newLineCharacter: Character(newLineCharacter))
        
        let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
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
            let contentPath = folderPath.appendingFormat("/%@", content)
            try persistStringsFile(stringsFile, fileName: fileName, destiantionPath: contentPath)
        }
    }
}

// MARK: Appending

private func appendExistingTranslationsFromFolder(_ folderPath: String, destinationPath: String) throws {
    let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
    for content in contents {
        if content.hasSuffix(".lproj") && content.hasPrefix("Base") == false {
            let localeFolderPath = folderPath.appendingFormat("/%@", content)
            try appendExistingTranslationsFromLocaleFolder(localeFolderPath, destinationPath: destinationPath)
        }
        
        let path = folderPath.appendingFormat("/%@", content)
        if isPathDirectory(path) {
            try appendExistingTranslationsFromFolder(path, destinationPath: destinationPath)
        }
    }
}

private func appendExistingTranslationsFromLocaleFolder(_ folderPath: String, destinationPath: String) throws {
    let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
    for content in contents {
        if content.hasSuffix(".strings") == false {
            continue
        }
        
        let fileName = (content as NSString).deletingPathExtension
        if let csvFilePath = try csvFilePathForFileName(fileName, inDestinationPath: destinationPath) {
            let stringsFilePath = folderPath.appendingFormat("/%@", content)
            let stringsFileContents = try NSString(contentsOfFile: stringsFilePath, usedEncoding: nil) as String
            let stringsFile = StringsFile(textRepresentation: stringsFileContents)
            
            var language = "?"
            if let l = try localeDisplayNameForFolderName((folderPath as NSString).lastPathComponent) {
                language = l
            }
            
            let csvFileContents = try NSString(contentsOfFile: csvFilePath, usedEncoding: nil) as String
            let newLineCharacter = UserDefaults.standard.string(forKey: NewLineCharacterKey) ?? "\n"
            var csv = CSV(textRepresentation: csvFileContents, name: fileName, newLineCharacter: Character(newLineCharacter))
            csv.addExistingTranslation(stringsFile, language: language)
            try persistCSV(csv, destinationPath: destinationPath)
        }
    }
}

// MARK: General

private func generateCSVFromStringsFilePath(_ filePath: String, destinationPath: String) throws {
    let fileContents = try NSString(contentsOfFile: filePath, usedEncoding: nil) as String
    let stringsFile = StringsFile(textRepresentation: fileContents)
    let csvFileName = ((filePath as NSString).lastPathComponent as NSString).deletingPathExtension
    let newLineCharacter = UserDefaults.standard.string(forKey: NewLineCharacterKey) ?? "\n"
    let csv = CSV(baseStringsFile: stringsFile, name: csvFileName, newLineCharacter: Character(newLineCharacter))
    try persistCSV(csv, destinationPath: destinationPath)
}

private func persistCSV(_ csv: CSV, destinationPath: String) throws {
    let csvText = csv.textRepresentation() as NSString
    let csvFilePath = destinationPath.appendingFormat("/%@.csv", csv.name)
    try csvText.write(toFile: csvFilePath, atomically: true, encoding: String.Encoding.utf8.rawValue)
}

private func persistStringsFile(_ stringsFile: StringsFile, fileName: String, destiantionPath: String) throws {
    let stringsFileText = stringsFile.textRepresentation()
    let stringsFilePath = destiantionPath.appendingFormat("/%@.strings", fileName)
    try stringsFileText.write(toFile: stringsFilePath, atomically: true, encoding: String.Encoding.utf8)
}

private func csvFilePathForFileName(_ fileName: String, inDestinationPath: String) throws -> String? {
    let contents = try FileManager.default.contentsOfDirectory(atPath: inDestinationPath)
    for content in contents {
        if (content as NSString).deletingPathExtension == fileName {
            return inDestinationPath.appendingFormat("/%@", content)
        }
    }
    return nil
}
