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
        return "StringsFile"
    }
    
    // MARK: Private Methods
    
    private func populateEntriesFromTextRepresentation(textRepresentation: String) {
        
    }
}
