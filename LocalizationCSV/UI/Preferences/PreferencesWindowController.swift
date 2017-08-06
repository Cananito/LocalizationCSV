//
//  PreferencesWindowController.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 11/4/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class PreferencesWindowController : NSWindowController {
    @IBOutlet weak var toolbar: NSToolbar!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        switchToPaneWithIdentifier("General")
    }
    
    private func switchToPaneWithIdentifier(_ identifier: String) {
        self.toolbar.selectedItemIdentifier = identifier
        self.window?.title = identifier
    }
}
