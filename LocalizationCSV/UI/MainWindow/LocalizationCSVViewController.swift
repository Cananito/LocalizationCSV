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
    func execute(topPathTextField: NSTextField, bottomPathTextField: NSTextField, finishWithErrorMessage: (String?) -> ())
}

@objc protocol LocalizationCSVFilePathLogic {
    func openPanel() -> NSOpenPanel
    func shouldEnableExecuteButton(topPathTextField: NSTextField, bottomPathTextField: NSTextField) -> Bool
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
    
    override func controlTextDidChange(_ obj: Notification) {
        updateExecuteButtonEnabledState()
    }
    
    // MARK: Action Methods
    
    @IBAction func browseTopFolderPath(_ sender: AnyObject!) {
        showOpenPanelForTextField(topPathTextField)
    }
    
    @IBAction func browseBottomFolderPath(_ sender: AnyObject!) {
        showOpenPanelForTextField(bottomPathTextField)
    }
    
    @IBAction func execute(_ sender: AnyObject!) {
        showLoadingUI()
        OperationQueue().addOperation { [unowned self] () -> Void in
            self.localizationCSVExecutor.execute(topPathTextField: self.topPathTextField, bottomPathTextField: self.bottomPathTextField, finishWithErrorMessage: self.finishExecuteActionWithErrorMessage)
        }
    }
    
    // MARK: Private Methods
    
    private func showOpenPanelForTextField(_ textField: NSTextField) {
        let openPanel = self.localizationCSVFilePathLogic.openPanel()
        openPanel.begin { [weak self] (result) -> Void in
            if result == NSFileHandlingPanelOKButton, let pathURL = openPanel.url {
                textField.stringValue = pathURL.relativePath
                self?.updateExecuteButtonEnabledState()
            }
        }
    }
    
    private func updateExecuteButtonEnabledState() {
        executeButton.isEnabled = self.localizationCSVFilePathLogic.shouldEnableExecuteButton(topPathTextField: topPathTextField, bottomPathTextField: bottomPathTextField)
    }
    
    private func showLoadingUI() {
        topPathLabel.isHidden = true
        topPathTextField.isHidden = true
        browseTopPathButton.isHidden = true
        bottomPathLabel.isHidden = true
        bottomPathTextField.isHidden = true
        browseBottomPathButton.isHidden = true
        executeButton.isHidden = true
        loadingIndicator.startAnimation(self)
    }
    
    private func hideLoadingUI() {
        topPathLabel.isHidden = false
        topPathTextField.isHidden = false
        browseTopPathButton.isHidden = false
        bottomPathLabel.isHidden = false
        bottomPathTextField.isHidden = false
        browseBottomPathButton.isHidden = false
        executeButton.isHidden = false
        loadingIndicator.stopAnimation(self)
    }
    
    private func finishExecuteActionWithErrorMessage(_ errorMessage: String?) {
        OperationQueue.main.addOperation { () -> Void in
            self.hideLoadingUI()
            if let message = errorMessage {
                let alert = NSAlert()
                alert.messageText = message
                alert.alertStyle = NSAlertStyle.informational
                alert.beginSheetModal(for: self.view.window!, completionHandler: Optional.none)
            }
        }
    }
}
