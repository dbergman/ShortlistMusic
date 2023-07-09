//
//  Shortlist.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/4/23.
//

import CloudKit
import Foundation

struct Shortlist: Hashable {
    let id: String
    let name: String
    let year: String
    let recordID: CKRecord.ID
    var albums: [ShortListAlbum]?
    
    init?(with record: CKRecord) {
        guard
            let name = record["name"] as? String,
            let year = record["year"] as? String,
            let id = record["id"] as? String
        else {
            return nil
        }

        self.name = name
        self.year = year
        self.id = id
        recordID = record.recordID
    }
}
