//
//  CSV.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

struct CSV {
    typealias Grid = [Row]
    typealias Row = [String]
    
    var grid: Grid
    let name: String
    
    let ColumnTitleRowIndex = 0
    let KeyColumnIndex = 0
    let BaseColumnIndex = 1
    
    init(baseStringsFile: StringsFile, name: String) {
        var grid = Grid()
        
        let firstRow = ["Key", "Base", "Comment"]
        grid.append(firstRow)
        
        for entry in baseStringsFile.entries {
            let row = [entry.key, entry.value, entry.comment]
            grid.append(row)
        }
        
        self.grid = grid
        self.name = name
    }
    
    init(textRepresentation: String, name: String) {
        var grid = Grid()
        var currentRow = Row()
        var currentValue = ""
        var foundFirstDoubleQuote = false
        var foundSecondDoubleQuote = false
        
        let characters = Array(textRepresentation.characters)
        
        for var index = 0; index < characters.count; index++ {
            let character = characters[index]
            switch (character, foundFirstDoubleQuote, foundSecondDoubleQuote) {
            case (",", true, true):
                currentRow.append(currentValue)
                currentValue = ""
                foundFirstDoubleQuote = false
                foundSecondDoubleQuote = false
                break
            case (",", true, false):
                currentValue.append(character)
                break
            case (",", false, _):
                currentRow.append(currentValue)
                currentValue = ""
                break
            case ("\n", true, true):
                currentRow.append(currentValue)
                grid.append(currentRow)
                currentRow = Row()
                currentValue = ""
                foundFirstDoubleQuote = false
                foundSecondDoubleQuote = false
                break
            case ("\n", true, false):
                currentValue.append(character)
                break
            case ("\n", false, _):
                currentRow.append(currentValue)
                grid.append(currentRow)
                currentRow = Row()
                currentValue = ""
                break
            case ("\"", true, true):
                currentValue.append(character)
                foundSecondDoubleQuote = false
                break
            case ("\"", true, false):
                foundSecondDoubleQuote = true
                break
            case ("\"", false, _):
                foundFirstDoubleQuote = true
                break
            default:
                currentValue.append(character)
                break
            }
            
            if index == characters.count - 1 {
                currentRow.append(currentValue)
                grid.append(currentRow)
            }
        }
        
        self.grid = grid
        self.name = name
    }
    
    mutating func addExistingTranslation(stringsFile: StringsFile, language: String) {
        var columnTitleRow = self.grid[ColumnTitleRowIndex]
        let newColumnIndex = columnTitleRow.count - 1
        
        columnTitleRow.insert(language, atIndex: newColumnIndex)
        self.grid[ColumnTitleRowIndex] = columnTitleRow
        
        for var index = 1; index < self.grid.count; index++ {
            var row = self.grid[index]
            if let translatedEntry = stringsFile.entryForKey(row[KeyColumnIndex]) {
                row.insert(translatedEntry.value, atIndex: newColumnIndex)
            } else {
                row.insert("", atIndex: newColumnIndex)
            }
            self.grid[index] = row
        }
    }
    
    func textRepresentation() -> String {
        var rowStrings = [String]()
        for row in grid {
            let escapedRow = row.map { $0.csvEscaped() }
            rowStrings.append(escapedRow.joinWithSeparator(","))
        }
        return rowStrings.joinWithSeparator("\n")
    }
    
    func commentsColumnIndex() -> Int? {
        if grid.count == 0 {
            return nil
        }
        return grid[ColumnTitleRowIndex].count - 1
    }
}
