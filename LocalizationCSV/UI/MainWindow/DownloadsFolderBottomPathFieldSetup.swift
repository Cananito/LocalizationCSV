//
//  DownloadsFolderBottomPathFieldSetup.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/14/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class DownloadsFolderBottomPathFieldSetup : NSObject, LocalizationCSVUISetup {
    @IBOutlet weak var localizationCSVViewController: LocalizationCSVViewController!
    
    func setup() {
        do {
            let downloadsFolderPathURL = try FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let downloadsFolderPath = downloadsFolderPathURL.relativePath
            localizationCSVViewController.bottomPathTextField.stringValue = downloadsFolderPath
        } catch {
            print("\(error)")
        }
    }
}
