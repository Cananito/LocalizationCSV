//
//  ToCSVsUISetup.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/14/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class ToCSVsUISetup : NSObject, LocalizationCSVUISetup {
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
}
