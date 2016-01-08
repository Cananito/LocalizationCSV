//
//  LocalizationCSVViewController.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/13/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

@objc protocol LocalizationCSVUISetup {
    weak var localizationCSVViewController: LocalizationCSVViewController! { get set }
    func setup()
}

@objc protocol LocalizationCSVExecutor {
    // TODO: Switch to `func execute() throws` to move error handling to the execute(sender:) method.
    // Can't do this because of a Swift bug.
    func execute(topPathTextField topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: String? -> ())
}

@objc protocol LocalizationCSVFilePathLogic {
    func openPanel() -> NSOpenPanel
    func shouldEnableExecuteButton(topPathTextField topPathTextField: NSTextField, bottomPathTextField: NSTextField) -> Bool
}

class LocalizationCSVViewController : NSViewController {
    @IBOutlet weak var topPathLabel: NSTextField!
    @IBOutlet weak var topPathTextField: NSTextField!
    @IBOutlet weak var browseTopPathButton: NSButton!
    
    @IBOutlet weak var bottomPathLabel: NSTextField!
    @IBOutlet weak var bottomPathTextField: NSTextField!
    @IBOutlet weak var browseBottomPathButton: NSButton!
    
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    @IBOutlet var localizationCSVExecutor: LocalizationCSVExecutor!
    @IBOutlet var localizationCSVFilePathLogic: LocalizationCSVFilePathLogic!
    @IBOutlet var localizationCSVUISetup: LocalizationCSVUISetup?
    
    // MARK: Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizationCSVUISetup?.setup()
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        updateExecuteButtonEnabledState()
    }
    
    // MARK: Action Methods
    
    @IBAction func browseTopFolderPath(sender: AnyObject!) {
        showOpenPanelForTextField(topPathTextField)
    }
    
    @IBAction func browseBottomFolderPath(sender: AnyObject!) {
        showOpenPanelForTextField(bottomPathTextField)
    }
    
    @IBAction func execute(sender: AnyObject!) {
        showLoadingUI()
        NSOperationQueue().addOperationWithBlock { [unowned self] () -> Void in
            self.localizationCSVExecutor.execute(topPathTextField: self.topPathTextField, bottomPathTextField: self.bottomPathTextField, finishWithErrorMessage: self.finishExecuteActionWithErrorMessage)
        }
    }
    
    // MARK: Private Methods
    
    private func showOpenPanelForTextField(textField: NSTextField) {
        let openPanel = self.localizationCSVFilePathLogic.openPanel()
        openPanel.beginWithCompletionHandler { [weak self] (result) -> Void in
            if result == NSFileHandlingPanelOKButton, let pathURL = openPanel.URL {
                textField.stringValue = pathURL.relativePath!
                self?.updateExecuteButtonEnabledState()
            }
        }
    }
    
    private func updateExecuteButtonEnabledState() {
        executeButton.enabled = self.localizationCSVFilePathLogic.shouldEnableExecuteButton(topPathTextField: topPathTextField, bottomPathTextField: bottomPathTextField)
    }
    
    private func showLoadingUI() {
        topPathLabel.hidden = true
        topPathTextField.hidden = true
        browseTopPathButton.hidden = true
        bottomPathLabel.hidden = true
        bottomPathTextField.hidden = true
        browseBottomPathButton.hidden = true
        executeButton.hidden = true
        loadingIndicator.startAnimation(self)
    }
    
    private func hideLoadingUI() {
        topPathLabel.hidden = false
        topPathTextField.hidden = false
        browseTopPathButton.hidden = false
        bottomPathLabel.hidden = false
        bottomPathTextField.hidden = false
        browseBottomPathButton.hidden = false
        executeButton.hidden = false
        loadingIndicator.stopAnimation(self)
    }
    
    private func finishExecuteActionWithErrorMessage(errorMessage: String?) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.hideLoadingUI()
            if let message = errorMessage {
                let alert = NSAlert()
                alert.messageText = message
                alert.alertStyle = NSAlertStyle.InformationalAlertStyle
                alert.beginSheetModalForWindow(self.view.window!, completionHandler: Optional.None)
            }
        }
    }
}
