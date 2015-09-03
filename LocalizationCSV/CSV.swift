//
//  CSV.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/2/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

struct CSV {
    let temp: StringsFile
    
    init(stringsFile: StringsFile) {
        temp = stringsFile
    }
    
    func textRepresentation() -> String {
        return temp.textRepresentation()
    }
}
