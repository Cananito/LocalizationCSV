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
            var value = row[localeColumnIndex!]

            // Quite weird, but "\n" in NSString is represented as "\\n" when converted to String.
            if value.contains("\\n") {
                value = value.replacingOccurrences(of: "\\n", with: "\n")
            }
            entries[key] = value
        }
    }
    
    func dataRepresentation() throws -> Data {
        return try JSONSerialization.data(withJSONObject: entries, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
}
