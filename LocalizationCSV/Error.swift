//
//  Error.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 1/7/16.
//  Copyright © 2016 Rogelio Gudino. All rights reserved.
//

enum Error: ErrorType {
    case DestinationFolderAlreadyExists(message: String)
    case FailedToGenerateStringsFile(message: String)
    case FailedToReadCSVFile(message: String)
}
