//
//  FromCSVsUI.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/13/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class FromCSVsUI : NSObject, LocalizationCSVUI {
    @IBOutlet weak var localizationCSVViewController: LocalizationCSVViewController!
    
    func execute(finishWithErrorMessage: String? -> ()) {
        do {
            try updateStringsFilesForFolderPath(localizationCSVViewController.bottomFolderPathTextField.stringValue, csvsFolderPath: localizationCSVViewController.topFolderPathTextField.stringValue)
            finishWithErrorMessage(nil)
        } catch Error.DestinationFolderAlreadyExists(let message) {
            finishWithErrorMessage(message)
        } catch Error.FailedToGenerateStringsFile(let message) {
            finishWithErrorMessage(message)
        } catch {
            finishWithErrorMessage("Something went wrong. Please go to https://github.com/Cananito/LocalizationCSV/issues and submit your issue with all the possible information about how you got this error.")
        }
    }
}
