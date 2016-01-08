//
//  JSONsGenerator.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 1/7/16.
//  Copyright © 2016 Rogelio Gudino. All rights reserved.
//

import Foundation

func generateJSONFromCSVFilePath(csvFilePath: String, destinationPath: String) throws {
    let textRepresentation = try csvFileContents(csvFilePath)
    let csvFile = (csvFilePath as NSString).lastPathComponent
    let fileName = (csvFile as NSString).stringByDeletingPathExtension
    let newLineCharacter = NSUserDefaults.standardUserDefaults().stringForKey(NewLineCharacterKey) ?? "\n"
    let csv = CSV(textRepresentation: textRepresentation, name: fileName, newLineCharacter: Character(newLineCharacter))
    
    let folderName = NSDateFormatter.nowDateString()
    let destinationPath = destinationPath + "/" + folderName
    if NSFileManager.defaultManager().fileExistsAtPath(destinationPath) {
        throw Error.DestinationFolderAlreadyExists(message: "Folder named '\(folderName)' already exists!")
    } else {
        try NSFileManager.defaultManager().createDirectoryAtPath(destinationPath, withIntermediateDirectories: false, attributes: nil)
    }
    
    for localeDisplayName in csv.localeDisplayNames() {
        if let l = try localeFolderNameForDisplayName(localeDisplayName) {
            let lFolderPath = (destinationPath as NSString).stringByAppendingPathComponent(l)
            if NSFileManager.defaultManager().fileExistsAtPath(lFolderPath) {
                try deleteContentsOfDirectoryAtPath(lFolderPath)
            } else {
                try NSFileManager.defaultManager().createDirectoryAtPath(lFolderPath, withIntermediateDirectories: false, attributes: nil)
            }
            
            let json = JSON(csv: csv, language: localeDisplayName)
            
            let jsonPath = "\(destinationPath)/\(l)/\(fileName).json"
            try json.dataRepresentation().writeToFile(jsonPath, atomically: true)
        }
    }
}
