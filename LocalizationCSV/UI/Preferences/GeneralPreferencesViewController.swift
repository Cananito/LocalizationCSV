//
//  GeneralPreferencesViewController.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 11/4/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Cocoa

class GeneralPreferencesViewController : NSViewController {
    @IBOutlet weak var changeNewLineCharacterPickerRadioMatrix: NSMatrix!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectRadioCellForCurrentDefaultNewLineCharacter()
    }
    
    @IBAction func changeNewLineCharacter(sender: NSMatrix!) {
        guard let cell = sender.selectedCell() else { return }
        if cell.title == "\\n" {
            NSUserDefaults.standardUserDefaults().setObject("\n", forKey: NewLineCharacterKey)
        } else if cell.title == "\\r\\n" {
            NSUserDefaults.standardUserDefaults().setObject("\r\n", forKey: NewLineCharacterKey)
        } else if cell.title == "\\r" {
            NSUserDefaults.standardUserDefaults().setObject("\r", forKey: NewLineCharacterKey)
        }
    }
    
    private func selectRadioCellForCurrentDefaultNewLineCharacter() {
        if let newLineCharacterString = NSUserDefaults.standardUserDefaults().stringForKey(NewLineCharacterKey) {
            let cellTitle: String
            switch (newLineCharacterString) {
            case ("\n"):
                cellTitle = "\\n"
                break
            case ("\r\n"):
                cellTitle = "\\r\\n"
                break
            case ("\r"):
                cellTitle = "\\r"
            default:
                return
            }
            
            let cells = changeNewLineCharacterPickerRadioMatrix.cells
            for cell in cells {
                if cell.title == cellTitle {
                    changeNewLineCharacterPickerRadioMatrix.selectCell(cell)
                    return
                }
            }
        }
    }
}
