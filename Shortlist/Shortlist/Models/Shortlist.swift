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
    let createdTimestamp: Date
    var albums: [ShortlistAlbum]?
}

extension Shortlist {
    init?(with record: CKRecord) {
        guard
            let name = record["name"] as? String,
            let year = record["year"] as? String,
            let id = record["id"] as? String,
            let createdTimestamp = record.creationDate
        else {
            return nil
        }

        if let albums = record["albums"] as? [ShortlistAlbum] {
            self.albums = albums
        }
        
        self.name = name
        self.year = year
        self.id = id
        recordID = record.recordID
        self.createdTimestamp = createdTimestamp
    }
    
    init(shortlist: Shortlist, shortlistAlbums: [ShortlistAlbum]){
        self.name = shortlist.name
        self.year = shortlist.year
        self.id = shortlist.id
        albums = shortlistAlbums
        recordID = shortlist.recordID
        createdTimestamp = shortlist.createdTimestamp
    }
}
