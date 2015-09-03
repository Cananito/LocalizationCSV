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

class StringsFile {
    private(set) var entries = [StringsFileEntry]()
    
    init(textRepresentation: String) {
        populateEntriesFromTextRepresentation(textRepresentation)
    }
    
    func textRepresentation() -> String {
        // TODO: Implement this
        return "StringsFile"
    }
    
    func entryForKey(key: String) -> StringsFileEntry? {
        for entry in entries {
            if entry.key == key {
                return entry
            }
        }
        return nil
    }
    
    // MARK: Private Methods
    
    private func populateEntriesFromTextRepresentation(textRepresentation: String) {
        var entries = [StringsFileEntry]()
        let lines = textRepresentation.componentsSeparatedByString("\n")
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
            
            if let keyValue = currentKeyValue, comment = currentComment {
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
    
    private func removeCommentSyntaxFromLine(line: String) -> String {
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
        
        return line[line.startIndex.advancedBy(startAdvanceBy)..<line.endIndex.advancedBy(endAdvanceBy)]
    }
    
    private func keyValueFromLine(line: String) -> (key: String, value: String) {
        let characters = Array(line.characters)
        var keyEnded = false
        var escaping = false
        var keyEndIndex = 0
        var valueStartIndex = 0
        
        for var index = 0; index < line.characters.count; index++ {
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
        
        let key = removeQuotesAndSemicolons(line[line.startIndex...line.startIndex.advancedBy(keyEndIndex)])
        let value = removeQuotesAndSemicolons(line[line.startIndex.advancedBy(valueStartIndex)..<line.endIndex])
        return (key, value)
    }
    
    private func removeQuotesAndSemicolons(string: String) -> String {
        let result: String
        if string.hasSuffix(";") {
            result = string[string.startIndex.advancedBy(1)..<string.endIndex.advancedBy(-2)]
        } else {
            result = string[string.startIndex.advancedBy(1)..<string.endIndex.advancedBy(-1)]
        }
        return result
    }
}
