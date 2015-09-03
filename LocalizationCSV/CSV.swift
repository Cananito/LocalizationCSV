//
//  CSV.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

struct CSV {
    typealias Row = [String]
    let grid: [Row]
    
    init(stringsFile: StringsFile) {
        var grid = [Row]()
        
        let firstRow = ["Key", "Base", "Comment"]
        grid.append(firstRow)
        
        for entry in stringsFile.entries {
            let row = [entry.key.csvEscaped(), entry.value.csvEscaped(), entry.comment.csvEscaped()]
            grid.append(row)
        }
        
        self.grid = grid
    }
    
    func textRepresentation() -> String {
        var rowStrings = [String]()
        for row in grid {
            rowStrings.append(row.joinWithSeparator(","))
        }
        return rowStrings.joinWithSeparator("\n")
    }
}

extension String {
    func csvEscaped() -> String {
        if self.containsString("\"") {
            var escapedCharacters = [Character]()
            escapedCharacters.append("\"")
            for character in self.characters {
                if character == "\"" {
                    escapedCharacters.append("\"")
                    escapedCharacters.append(character)
                } else {
                    escapedCharacters.append(character)
                }
            }
            escapedCharacters.append("\"")
            return String(escapedCharacters)
        } else if self.containsString(",") {
            return "\"" + self + "\""
        }
        
        return self
    }
}
