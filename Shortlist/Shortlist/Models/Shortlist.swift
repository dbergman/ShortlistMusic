//
//  Shortlist.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/4/23.
//

import CloudKit
import Foundation

struct Shortlist: Hashable {
    var name: String
    var year: String
    var recordID: CKRecord.ID
    
    init?(with record: CKRecord) {
        guard
            let name = record["name"] as? String,
            let year = record["year"] as? String
                
        else {
            return nil
        }

        self.name = name
        self.year = year
        recordID = record.recordID
    }
}
