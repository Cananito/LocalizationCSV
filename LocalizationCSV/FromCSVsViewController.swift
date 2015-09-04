//
//  FromCSVsViewController.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/3/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class FromCSVsViewController: NSViewController {
    @IBOutlet weak var csvFolderPathLabel: NSTextField!
    @IBOutlet weak var csvFolderPathTextField: NSTextField!
    @IBOutlet weak var browseCSVFolderPathButton: NSButton!
    
    @IBOutlet weak var projectFolderPathLabel: NSTextField!
    @IBOutlet weak var projectFolderPathTextField: NSTextField!
    @IBOutlet weak var browseProjectFolderPathButton: NSButton!
    
    @IBOutlet weak var updateStringsFilesButton: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    // MARK: Overriden Methods
    
    override func controlTextDidChange(obj: NSNotification) {
        updateUpdateStringsFilesButtonEnabledState()
    }
    
    // MARK: Action Methods
    
    @IBAction func browseProjectFolderPath(sender: AnyObject!) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton, let pathURL = openPanel.URL {
                self.projectFolderPathTextField.stringValue = pathURL.relativePath!
                self.updateUpdateStringsFilesButtonEnabledState()
            }
        }
    }
    
    @IBAction func browseCSVFolderPath(sender: AnyObject!) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton, let pathURL = openPanel.URL {
                self.csvFolderPathTextField.stringValue = pathURL.relativePath!
                self.updateUpdateStringsFilesButtonEnabledState()
            }
        }
    }
    
    @IBAction func updateStringsFiles(sender: AnyObject!) {
        showLoadingUI()
        NSOperationQueue().addOperationWithBlock { () -> Void in
            do {
                try updateStringsFilesForFolderPath(self.projectFolderPathTextField.stringValue, csvsFolderPath: self.csvFolderPathTextField.stringValue)
                self.finishStringsUpdatingWithErrorMessage(nil)
            } catch Error.DestinationFolderAlreadyExists(let message) {
                self.finishStringsUpdatingWithErrorMessage(message)
            } catch {
                self.finishStringsUpdatingWithErrorMessage("Something went wrong. Please go to https://github.com/Cananito/LocalizationCSV/issues and submit your issue with all the possible information about how you got this error.")
            }
        }
    }
    
    // MARK: Private Methods
    
    private func updateUpdateStringsFilesButtonEnabledState() {
        updateStringsFilesButton.enabled = isTextFieldValueADirectoryPath(projectFolderPathTextField) && isTextFieldValueADirectoryPath(csvFolderPathTextField)
    }
    
    private func showLoadingUI() {
        projectFolderPathLabel.hidden = true
        projectFolderPathTextField.hidden = true
        browseProjectFolderPathButton.hidden = true
        csvFolderPathLabel.hidden = true
        csvFolderPathTextField.hidden = true
        browseCSVFolderPathButton.hidden = true
        updateStringsFilesButton.hidden = true
        loadingIndicator.startAnimation(self)
    }
    
    private func hideLoadingUI() {
        projectFolderPathLabel.hidden = false
        projectFolderPathTextField.hidden = false
        browseProjectFolderPathButton.hidden = false
        csvFolderPathLabel.hidden = false
        csvFolderPathTextField.hidden = false
        browseCSVFolderPathButton.hidden = false
        updateStringsFilesButton.hidden = false
        loadingIndicator.stopAnimation(self)
    }
    
    private func finishStringsUpdatingWithErrorMessage(errorMessage: String?) {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.hideLoadingUI()
            if let message = errorMessage {
                let alert = NSAlert()
                alert.messageText = message
                alert.alertStyle = NSAlertStyle.InformationalAlertStyle
                alert.beginSheetModalForWindow(self.view.window!, completionHandler: Optional.None)
            }
        })
    }
}
