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
    
    @IBAction func changeNewLineCharacter(_ sender: NSMatrix!) {
        guard let cell = sender.selectedCell() else { return }
        if cell.title == "\\n" {
            UserDefaults.standard.set("\n", forKey: NewLineCharacterKey)
        } else if cell.title == "\\r\\n" {
            UserDefaults.standard.set("\r\n", forKey: NewLineCharacterKey)
        } else if cell.title == "\\r" {
            UserDefaults.standard.set("\r", forKey: NewLineCharacterKey)
        }
    }
    
    private func selectRadioCellForCurrentDefaultNewLineCharacter() {
        if let newLineCharacterString = UserDefaults.standard.string(forKey: NewLineCharacterKey) {
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
