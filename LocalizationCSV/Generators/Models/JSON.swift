//
//  JSON.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 1/7/16.
//  Copyright © 2016 Rogelio Gudino. All rights reserved.
//

import Foundation

struct JSON {
    private(set) var entries = [String : String]()
    
    init(csv: CSV, language: String) {
        if csv.grid.count == 0 {
            return
        }
        
        let columnTitleRow = csv.grid[csv.ColumnTitleRowIndex]
        var localeColumnIndex: Int?
        for (index, value) in columnTitleRow.enumerate() {
            if value == language {
                localeColumnIndex = index
                break
            }
        }
        
        guard let _ = localeColumnIndex else {
            return
        }
        
        for var index = 1; index < csv.grid.count; index++ {
            let row = csv.grid[index]
            let key = row[csv.KeyColumnIndex]
            let value = row[localeColumnIndex!]
            entries[key] = value
        }
    }
    
    func dataRepresentation() throws -> NSData {
        return try NSJSONSerialization.dataWithJSONObject(entries, options: NSJSONWritingOptions(rawValue: 0))
    }
}
