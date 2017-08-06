//
//  LocaleDatabase.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/12/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Foundation

enum DataBaseError: Error {
    case dataBaseDoesNotExist(message: String)
    case failToOpen(message: String)
    case failToClose(message: String)
    case failedToPrepareSelectQuery(message: String)
    case failedToFinalizeSelectQuery(message: String)
}

func localeFolderNameForDisplayName(_ displayName: String) throws -> String? {
    let query = "SELECT folder_name FROM Locale WHERE display_name == \"\(displayName)\" LIMIT 1"
    return try executeSingleRowResultQuery(query)
}

func localeDisplayNameForFolderName(_ folderName: String) throws -> String? {
    let query = "SELECT display_name FROM Locale WHERE folder_name == \"\(folderName)\" LIMIT 1"
    return try executeSingleRowResultQuery(query)
}

private func executeSingleRowResultQuery(_ query: String) throws -> String? {
    var dataBase: OpaquePointer? = nil
    guard let dataBaseLocation = Bundle.main.path(forResource: "LocalizationCSV", ofType: "sqlite") else {
        throw DataBaseError.dataBaseDoesNotExist(message: "Data base file not found.")
    }
    if sqlite3_open(dataBaseLocation, &dataBase) != SQLITE_OK {
        throw DataBaseError.failToOpen(message: "Failed to open the data base.")
    }
    
    var statement: OpaquePointer? = nil
    if sqlite3_prepare_v2(dataBase, query, -1, &statement, nil) != SQLITE_OK {
        throw DataBaseError.failedToPrepareSelectQuery(message: "There was an error trying to read from the data base.")
    }
    
    var result: String?
    if sqlite3_step(statement) == SQLITE_ROW {
        let resultCharacters = sqlite3_column_text(statement, 0)
        if resultCharacters != nil {
            result = String(cString: resultCharacters!)
        }
    }
    if sqlite3_finalize(statement) != SQLITE_OK {
        throw DataBaseError.failedToFinalizeSelectQuery(message: "There was an error trying to read from the data base.")
    }
    statement = nil
    
    if sqlite3_close(dataBase) != SQLITE_OK {
        throw DataBaseError.failToClose(message: "Failed to close the data base.")
    }
    dataBase = nil
    
    return result
}
