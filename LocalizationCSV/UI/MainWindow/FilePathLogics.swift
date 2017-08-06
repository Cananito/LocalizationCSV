//
//  FilePathLogics.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 1/7/16.
//  Copyright © 2016 Rogelio Gudino. All rights reserved.
//

import Cocoa

class CSVsFilePathLogic : NSObject, LocalizationCSVFilePathLogic {
    func openPanel() -> NSOpenPanel {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        return openPanel
    }
    
    func shouldEnableExecuteButton(topPathTextField: NSTextField, bottomPathTextField: NSTextField) -> Bool {
        return isTextFieldValueADirectoryPath(topPathTextField) && isTextFieldValueADirectoryPath(bottomPathTextField)
    }
}

class ToJSONsFilePathLogic : NSObject, LocalizationCSVFilePathLogic {
    func openPanel() -> NSOpenPanel {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["csv"]
        openPanel.canCreateDirectories = false
        return openPanel
    }
    
    func shouldEnableExecuteButton(topPathTextField: NSTextField, bottomPathTextField: NSTextField) -> Bool {
        return isTextFieldValueValidPath(topPathTextField, withValidFileExtension: "csv") && isTextFieldValueADirectoryPath(bottomPathTextField)
    }
}
