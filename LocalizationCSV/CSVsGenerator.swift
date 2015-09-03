//
//  CSVsGenerator.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Foundation

func generateCSVsForFolderPath(folderPath: String) {
    do {
        let downloadsFolderPathURL = try NSFileManager.defaultManager().URLForDirectory(.DownloadsDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let downloadsFolderPath = downloadsFolderPathURL.relativePath!
        
        let destinationPath = downloadsFolderPath + "/" + NSDateFormatter.nowDateString()
        if NSFileManager.defaultManager().fileExistsAtPath(destinationPath) == false {
            try NSFileManager.defaultManager().createDirectoryAtPath(destinationPath, withIntermediateDirectories: false, attributes: nil)
        }
        
        generateCSVFromLocalizableStringsFileForProject(folderPath, destinationPath: destinationPath)
        generateCSVsFromInterfaceBuilderFiles(folderPath, destinationPath: destinationPath)
    } catch {
        print("\(error)")
    }
}

private func generateCSVFromLocalizableStringsFileForProject(folderPath: String, destinationPath: String) {
    // `find ./ -name "*.m" -print0 | xargs -0 genstrings -o .`
    _ = outputStringFromLaunchPath("/bin/sh", arguments: [ "-c", "find \(folderPath) -name \"*.m\" -print0 | xargs -0 genstrings -o \(destinationPath)" ])
    
    let tempLocalizableStringsFile = destinationPath + "/Localizable.strings"
    generateCSVFromStringsFilePath(tempLocalizableStringsFile, destinationPath: destinationPath)
    deleteFileAtPath(tempLocalizableStringsFile)
}

private func generateCSVsFromInterfaceBuilderFiles(folderPath: String, destinationPath: String) {
    do {
        let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath)
        for content in contents {
            if content == "Base.lproj" {
                let baseFolderPath = folderPath.stringByAppendingFormat("/%@", content)
                generateCSVsFromInterfaceBuilderBaseFolder(baseFolderPath, destinationPath: destinationPath)
            }
            let path = folderPath.stringByAppendingFormat("/%@", content)
            if isPathDirectory(path) {
                generateCSVsFromInterfaceBuilderFiles(path, destinationPath: destinationPath)
            }
        }
    } catch {
        print("\(error)")
    }
}

private func generateCSVsFromInterfaceBuilderBaseFolder(folderPath: String, destinationPath: String) {
    do {
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
            _ = outputStringFromLaunchPath("/bin/sh", arguments: [ "-c", "ibtool --export-strings-file \(escapedDestination) \(escapedPath)" ])
            generateCSVFromStringsFilePath(destination, destinationPath: destinationPath)
            deleteFileAtPath(destination)
        }
    } catch {
        print("\(error)")
    }
}

private func deleteFileAtPath(path: String) {
    _ = outputStringFromLaunchPath("/bin/sh", arguments: [ "-c", "rm \(path)" ])
}

private func generateCSVFromStringsFilePath(filePath: String, destinationPath: String) {
    do {
        let fileContents = try NSString(contentsOfFile: filePath, usedEncoding: nil) as String
        let stringsFile = StringsFile(textRepresentation: fileContents)
        let csv = CSV(stringsFile: stringsFile)
        let csvText = csv.textRepresentation() as NSString
        let csvFileName = ((filePath as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
        let csvFilePath = destinationPath.stringByAppendingFormat("/%@.csv", csvFileName)
        try csvText.writeToFile(csvFilePath, atomically: true, encoding: NSUTF8StringEncoding)
    } catch {
        print("\(error)")
    }
}
