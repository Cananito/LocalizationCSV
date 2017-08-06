//
//  GeneratorsError.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 1/7/16.
//  Copyright © 2016 Rogelio Gudino. All rights reserved.
//

enum GeneratorsError: Error {
    case destinationFolderAlreadyExists(message: String)
    case failedToGenerateStringsFile(message: String)
    case failedToReadCSVFile(message: String)
}
