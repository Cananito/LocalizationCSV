//
//  Executors.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 1/7/16.
//  Copyright © 2016 Rogelio Gudino. All rights reserved.
//

import Cocoa

class ToCSVsExecuter : NSObject, LocalizationCSVExecutor {
    func execute(topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: (String?) -> ()) {
        exectuteThrowableFunction(generateCSVsForFolderPath, topPathTextField: topPathTextField, bottomPathTextField: bottomPathTextField, finishWithErrorMessage: finishWithErrorMessage)
    }
}

class FromCSVsExecuter : NSObject, LocalizationCSVExecutor {
    func execute(topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: (String?) -> ()) {
        exectuteThrowableFunction(updateStringsFilesForFolderPath, topPathTextField: bottomPathTextField, bottomPathTextField: topPathTextField, finishWithErrorMessage: finishWithErrorMessage)
    }
}

class ToJSONsExecuter : NSObject, LocalizationCSVExecutor {
    func execute(topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: (String?) -> ()) {
        exectuteThrowableFunction(generateJSONFromCSVFilePath, topPathTextField: topPathTextField, bottomPathTextField: bottomPathTextField, finishWithErrorMessage: finishWithErrorMessage)
    }
}

private func exectuteThrowableFunction(_ executeFunction: (String, String) throws -> (), topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: (String?) -> ()) {
    do {
        try executeFunction(topPathTextField.stringValue, bottomPathTextField.stringValue)
        finishWithErrorMessage(nil)
    } catch GeneratorsError.destinationFolderAlreadyExists(let message) {
        finishWithErrorMessage(message)
    } catch GeneratorsError.failedToGenerateStringsFile(let message) {
        finishWithErrorMessage(message)
    } catch GeneratorsError.failedToReadCSVFile(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.dataBaseDoesNotExist(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.failToOpen(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.failToClose(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.failedToPrepareSelectQuery(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.failedToFinalizeSelectQuery(let message) {
        finishWithErrorMessage(message)
    } catch {
        finishWithErrorMessage("Something went wrong. Please go to https://github.com/Cananito/LocalizationCSV/issues and submit your issue with all the possible information about how you got this error.")
    }
}
