//
//  StringsFile.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

struct StringsFileEntry {
    let key: String
    let value: String
    let comment: String
}

struct StringsFile {
    private(set) var entries = [StringsFileEntry]()
    
    init(textRepresentation: String) {
        var entries = [StringsFileEntry]()
        let lines = textRepresentation.components(separatedBy: "\n")
        var currentComment: String?
        var currentKeyValue: (key: String, value: String)?
        for line in lines {
            if line.isEmpty {
                continue
            }
            
            if line.hasPrefix("/*") {
                currentComment = removeCommentSyntaxFromLine(line)
            } else if line.hasPrefix("\"") {
                currentKeyValue = keyValueFromLine(line)
            }
            
            if let keyValue = currentKeyValue, let comment = currentComment {
                let entry = StringsFileEntry(key: keyValue.key, value: keyValue.value, comment: comment)
                entries.append(entry)
                currentComment = nil
                currentKeyValue = nil
            } else if let keyValue = currentKeyValue {
                let entry = StringsFileEntry(key: keyValue.key, value: keyValue.value, comment: "")
                entries.append(entry)
                currentComment = nil
                currentKeyValue = nil
            }
        }
        
        self.entries = entries
    }
    
    init(csv: CSV, language: String) {
        if csv.grid.count == 0 {
            return
        }
        
        let columnTitleRow = csv.grid[csv.ColumnTitleRowIndex]
        var localeColumnIndex: Int?
        for (index, value) in columnTitleRow.enumerated() {
            if value == language {
                localeColumnIndex = index
                break
            }
        }
        
        guard let _ = localeColumnIndex else {
            return
        }
        
        for index in 1 ..< csv.grid.count {
            let row = csv.grid[index]
            let key = row[csv.KeyColumnIndex]
            let value = row[localeColumnIndex!]
            let comment = row[csv.commentsColumnIndex()!]
            let entry = StringsFileEntry(key: key, value: value, comment: comment)
            entries.append(entry)
        }
    }
    
    func textRepresentation() -> String {
        var entryStrings = [String]()
        for entry in entries {
            let entryString = "/* " + entry.comment + " */\n" + "\"" + entry.key + "\" = \"" + entry.value + "\";"
            entryStrings.append(entryString)
        }
        return "\n" + entryStrings.joined(separator: "\n\n") + "\n"
    }
    
    func entryForKey(_ key: String) -> StringsFileEntry? {
        for entry in entries {
            if entry.key == key {
                return entry
            }
        }
        return nil
    }
    
    // MARK: Private Methods
    
    fileprivate func removeCommentSyntaxFromLine(_ line: String) -> String {
        let startAdvanceBy: Int
        let endAdvanceBy: Int
        
        if line.hasPrefix("/* ") {
            startAdvanceBy = 3
        } else if line.hasPrefix("/*") {
            startAdvanceBy = 2
        } else {
            startAdvanceBy = 0
        }
        
        if line.hasSuffix(" */") {
            endAdvanceBy = -3
        } else if line.hasSuffix("*/") {
            endAdvanceBy = -2
        } else {
            endAdvanceBy = 0
        }
        
        return line[line.characters.index(line.startIndex, offsetBy: startAdvanceBy)..<line.characters.index(line.endIndex, offsetBy: endAdvanceBy)]
    }
    
    fileprivate func keyValueFromLine(_ line: String) -> (key: String, value: String) {
        let characters = Array(line.characters)
        var keyEnded = false
        var escaping = false
        var keyEndIndex = 0
        var valueStartIndex = 0
        
        for index in 0 ..< line.characters.count {
            if index == 0 {
                continue
            }
            
            if escaping == true {
                escaping = false
                continue
            }
            
            let character = characters[index]
            if character == "\\" {
                escaping = true
                continue
            }
            
            if keyEnded == false && character == "\"" {
                keyEnded = true
                keyEndIndex = index
            } else if keyEnded == true && character == "\"" {
                valueStartIndex = index
                break
            }
        }
        
        let key = removeQuotesAndSemicolons(line[line.startIndex...line.characters.index(line.startIndex, offsetBy: keyEndIndex)])
        let value = removeQuotesAndSemicolons(line[line.characters.index(line.startIndex, offsetBy: valueStartIndex)..<line.endIndex])
        return (key, value)
    }
    
    private func removeQuotesAndSemicolons(_ string: String) -> String {
        let result: String
        if string.hasSuffix(";") {
            result = string[string.characters.index(string.startIndex, offsetBy: 1)..<string.characters.index(string.endIndex, offsetBy: -2)]
        } else {
            result = string[string.characters.index(string.startIndex, offsetBy: 1)..<string.characters.index(string.endIndex, offsetBy: -1)]
        }
        return result
    }
}
