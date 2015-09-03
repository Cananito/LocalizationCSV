//
//  ViewController.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var folderPathTextField: NSTextField!
    @IBOutlet weak var generateCSVsButton: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    // MARK: Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        folderPathTextField.becomeFirstResponder()
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        generateCSVsButton.enabled = validateTextFieldPath()
    }
    
    // MARK: Action Methods
    
    @IBAction func generateCSVs(sender: AnyObject!) {
        showLoadingUI()
        NSOperationQueue().addOperationWithBlock { () -> Void in
            generateCSVsForFolderPath(self.folderPathTextField.stringValue)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.hideLoadingUI()
            })
        }
    }
    
    // MARK: Private Methods
    
    private func validateTextFieldPath() -> Bool {
        let path = folderPathTextField.stringValue
        return isPathDirectory(path)
    }
    
    private func showLoadingUI() {
        folderPathTextField.hidden = true
        generateCSVsButton.hidden = true
        loadingIndicator.startAnimation(self)
    }
    
    private func hideLoadingUI() {
        folderPathTextField.hidden = false
        generateCSVsButton.hidden = false
        loadingIndicator.stopAnimation(self)
    }
}
