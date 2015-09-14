//
//  FromCSVsExecutor.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/13/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class FromCSVsUI : NSObject, LocalizationCSVExecutor {
    func execute(topFolderPathTextField topFolderPathTextField: NSTextField, bottomFolderPathTextField: NSTextField, finishWithErrorMessage: String? -> ()) {
        do {
            try updateStringsFilesForFolderPath(bottomFolderPathTextField.stringValue, csvsFolderPath: topFolderPathTextField.stringValue)
            finishWithErrorMessage(nil)
        } catch Error.DestinationFolderAlreadyExists(let message) {
            finishWithErrorMessage(message)
        } catch Error.FailedToGenerateStringsFile(let message) {
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
}
