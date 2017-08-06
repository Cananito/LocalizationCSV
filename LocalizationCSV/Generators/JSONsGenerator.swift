//
//  JSONsGenerator.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 1/7/16.
//  Copyright © 2016 Rogelio Gudino. All rights reserved.
//

import Foundation

func generateJSONFromCSVFilePath(_ csvFilePath: String, destinationPath: String) throws {
    let textRepresentation = try csvFileContents(csvFilePath)
    let csvFile = (csvFilePath as NSString).lastPathComponent
    let fileName = (csvFile as NSString).deletingPathExtension
    let newLineCharacter = UserDefaults.standard.string(forKey: NewLineCharacterKey) ?? "\n"
    let csv = CSV(textRepresentation: textRepresentation, name: fileName, newLineCharacter: Character(newLineCharacter))
    
    let folderName = DateFormatter.nowDateString()
    let destinationPath = destinationPath + "/" + folderName
    if FileManager.default.fileExists(atPath: destinationPath) {
        throw GeneratorsError.destinationFolderAlreadyExists(message: "Folder named '\(folderName)' already exists!")
    } else {
        try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: false, attributes: nil)
    }
    
    for localeDisplayName in csv.localeDisplayNames() {
        if let l = try localeFolderNameForDisplayName(localeDisplayName) {
            let lFolderPath = (destinationPath as NSString).appendingPathComponent(l)
            if FileManager.default.fileExists(atPath: lFolderPath) {
                try deleteContentsOfDirectoryAtPath(lFolderPath)
            } else {
                try FileManager.default.createDirectory(atPath: lFolderPath, withIntermediateDirectories: false, attributes: nil)
            }
            
            let json = JSON(csv: csv, language: localeDisplayName)
            
            let jsonPath = "\(destinationPath)/\(l)/\(fileName).json"
            try json.dataRepresentation().write(to: URL(fileURLWithPath: jsonPath), options: [.atomic])
        }
    }
}
