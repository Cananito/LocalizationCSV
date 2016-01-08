//
//  Executors.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 1/7/16.
//  Copyright © 2016 Rogelio Gudino. All rights reserved.
//

import Cocoa

class ToCSVsExecuter : NSObject, LocalizationCSVExecutor {
    func execute(topPathTextField topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: String? -> ()) {
        exectuteThrowableFunction(generateCSVsForFolderPath, topPathTextField: topPathTextField, bottomPathTextField: bottomPathTextField, finishWithErrorMessage: finishWithErrorMessage)
    }
}

class FromCSVsExecuter : NSObject, LocalizationCSVExecutor {
    func execute(topPathTextField topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: String? -> ()) {
        exectuteThrowableFunction(updateStringsFilesForFolderPath, topPathTextField: topPathTextField, bottomPathTextField: bottomPathTextField, finishWithErrorMessage: finishWithErrorMessage)
    }
}

class ToJSONsExecuter : NSObject, LocalizationCSVExecutor {
    func execute(topPathTextField topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: String? -> ()) {
        exectuteThrowableFunction(generateJSONFromCSVFilePath, topPathTextField: topPathTextField, bottomPathTextField: bottomPathTextField, finishWithErrorMessage: finishWithErrorMessage)
    }
}

private func exectuteThrowableFunction(executeFunction: (String, String) throws -> (), topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: String? -> ()) {
    do {
        try executeFunction(topPathTextField.stringValue, bottomPathTextField.stringValue)
        finishWithErrorMessage(nil)
    } catch GeneratorsError.DestinationFolderAlreadyExists(let message) {
        finishWithErrorMessage(message)
    } catch GeneratorsError.FailedToGenerateStringsFile(let message) {
        finishWithErrorMessage(message)
    } catch GeneratorsError.FailedToReadCSVFile(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.DataBaseDoesNotExist(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.FailToOpen(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.FailToClose(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.FailedToPrepareSelectQuery(let message) {
        finishWithErrorMessage(message)
    } catch DataBaseError.FailedToFinalizeSelectQuery(let message) {
        finishWithErrorMessage(message)
    } catch {
        finishWithErrorMessage("Something went wrong. Please go to https://github.com/Cananito/LocalizationCSV/issues and submit your issue with all the possible information about how you got this error.")
    }
}
