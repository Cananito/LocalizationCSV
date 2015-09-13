//
//  LocalizationCSVViewController.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/13/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

@objc protocol LocalizationCSVUI {
    weak var localizationCSVViewController: LocalizationCSVViewController! { get set }
    optional func setup()
    func execute(finish: String? -> ())
}

class LocalizationCSVViewController : NSViewController {
    @IBOutlet weak var topFolderPathLabel: NSTextField!
    @IBOutlet weak var topFolderPathTextField: NSTextField!
    @IBOutlet weak var browseTopFolderPathButton: NSButton!
    
    @IBOutlet weak var bottomFolderPathLabel: NSTextField!
    @IBOutlet weak var bottomFolderPathTextField: NSTextField!
    @IBOutlet weak var browseBottomFolderPathButton: NSButton!
    
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    @IBOutlet var localizationCSVUI: LocalizationCSVUI!
    
    // MARK: Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizationCSVUI.setup?()
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        updateExecuteButtonEnabledState()
    }
    
    // MARK: Action Methods
    
    @IBAction func browseTopFolderPath(sender: AnyObject!) {
        showOpenPanelForTextField(topFolderPathTextField)
    }
    
    @IBAction func browseBottomFolderPath(sender: AnyObject!) {
        showOpenPanelForTextField(bottomFolderPathTextField)
    }
    
    @IBAction func execute(sender: AnyObject!) {
        showLoadingUI()
        NSOperationQueue().addOperationWithBlock { [unowned self] () -> Void in
            self.localizationCSVUI.execute(self.finishExecuteActionWithErrorMessage)
        }
    }
    
    // MARK: Private Methods
    
    private func showOpenPanelForTextField(textField: NSTextField) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.beginWithCompletionHandler { [weak self] (result) -> Void in
            if result == NSFileHandlingPanelOKButton, let pathURL = openPanel.URL {
                textField.stringValue = pathURL.relativePath!
                self?.updateExecuteButtonEnabledState()
            }
        }
    }
    
    private func updateExecuteButtonEnabledState() {
        executeButton.enabled = isTextFieldValueADirectoryPath(topFolderPathTextField) && isTextFieldValueADirectoryPath(bottomFolderPathTextField)
    }
    
    private func showLoadingUI() {
        topFolderPathLabel.hidden = true
        topFolderPathTextField.hidden = true
        browseTopFolderPathButton.hidden = true
        bottomFolderPathLabel.hidden = true
        bottomFolderPathTextField.hidden = true
        browseBottomFolderPathButton.hidden = true
        executeButton.hidden = true
        loadingIndicator.startAnimation(self)
    }
    
    private func hideLoadingUI() {
        topFolderPathLabel.hidden = false
        topFolderPathTextField.hidden = false
        browseTopFolderPathButton.hidden = false
        bottomFolderPathLabel.hidden = false
        bottomFolderPathTextField.hidden = false
        browseBottomFolderPathButton.hidden = false
        executeButton.hidden = false
        loadingIndicator.stopAnimation(self)
    }
    
    private func finishExecuteActionWithErrorMessage(errorMessage: String?) {
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
