//
//  ToCSVsExecutor.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/13/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class ToCSVsExecuter : NSObject, LocalizationCSVExecutor {
    @IBOutlet weak var localizationCSVViewController: LocalizationCSVViewController!
    
    func setup() {
        do {
            let downloadsFolderPathURL = try NSFileManager.defaultManager().URLForDirectory(.DownloadsDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            let downloadsFolderPath = downloadsFolderPathURL.relativePath!
            localizationCSVViewController.bottomFolderPathTextField.stringValue = downloadsFolderPath
        } catch {
            print("\(error)")
        }
    }
    
    func execute(finishWithErrorMessage: String? -> ()) {
        do {
            try generateCSVsForFolderPath(localizationCSVViewController.topFolderPathTextField.stringValue, destinationPath: localizationCSVViewController.bottomFolderPathTextField!.stringValue)
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
