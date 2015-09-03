//
//  ToCSVsViewController.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class ToCSVsViewController: NSViewController {
    @IBOutlet weak var projectFolderPathLabel: NSTextField!
    @IBOutlet weak var projectFolderPathTextField: NSTextField!
    @IBOutlet weak var browseProjectFolderPathButton: NSButton!
    
    @IBOutlet weak var csvFolderPathLabel: NSTextField!
    @IBOutlet weak var csvFolderPathTextField: NSTextField!
    @IBOutlet weak var browseCSVFolderPathButton: NSButton!
    
    @IBOutlet weak var generateCSVsButton: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    // MARK: Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let downloadsFolderPathURL = try NSFileManager.defaultManager().URLForDirectory(.DownloadsDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            let downloadsFolderPath = downloadsFolderPathURL.relativePath!
            csvFolderPathTextField.stringValue = downloadsFolderPath
        } catch {
            print("\(error)")
        }
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        updateGenerateCSVsButtonEnabledState()
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
                self.updateGenerateCSVsButtonEnabledState()
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
                self.updateGenerateCSVsButtonEnabledState()
            }
        }
    }
    
    @IBAction func generateCSVs(sender: AnyObject!) {
        showLoadingUI()
        NSOperationQueue().addOperationWithBlock { () -> Void in
            do {
                try generateCSVsForFolderPath(self.projectFolderPathTextField.stringValue, destinationPath: self.csvFolderPathTextField.stringValue)
                self.finishCSVGenerationWithErrorMessage(nil)
            } catch Error.DestinationFolderAlreadyExists(let message) {
                self.finishCSVGenerationWithErrorMessage(message)
            } catch {
                self.finishCSVGenerationWithErrorMessage("Something went wrong. Please go to https://github.com/Cananito/LocalizationCSV/issues and submit your issue with all the possible information about how you got this error.")
            }
        }
    }
    
    // MARK: Private Methods
    
    private func updateGenerateCSVsButtonEnabledState() {
        generateCSVsButton.enabled = validateTextFieldPath(projectFolderPathTextField) && validateTextFieldPath(csvFolderPathTextField)
    }
    
    private func validateTextFieldPath(textField: NSTextField) -> Bool {
        let path = textField.stringValue
        return isPathDirectory(path)
    }
    
    private func showLoadingUI() {
        projectFolderPathLabel.hidden = true
        projectFolderPathTextField.hidden = true
        browseProjectFolderPathButton.hidden = true
        csvFolderPathLabel.hidden = true
        csvFolderPathTextField.hidden = true
        browseCSVFolderPathButton.hidden = true
        generateCSVsButton.hidden = true
        loadingIndicator.startAnimation(self)
    }
    
    private func hideLoadingUI() {
        projectFolderPathLabel.hidden = false
        projectFolderPathTextField.hidden = false
        browseProjectFolderPathButton.hidden = false
        csvFolderPathLabel.hidden = false
        csvFolderPathTextField.hidden = false
        browseCSVFolderPathButton.hidden = false
        generateCSVsButton.hidden = false
        loadingIndicator.stopAnimation(self)
    }
    
    private func finishCSVGenerationWithErrorMessage(errorMessage: String?) {
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
