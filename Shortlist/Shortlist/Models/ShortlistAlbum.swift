//
//  ShortlistAlbum.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/29/23.
//

import CloudKit
import Foundation

struct ShortlistAlbum: Hashable, Identifiable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
    let rank: Int
    let shortlistId: String
    let upc: String?
    var recordID: CKRecord.ID
}

extension ShortlistAlbum {
    init?(with record: CKRecord) {
        guard
            let id = record["id"] as? String,
            let title = record["title"] as? String,
            let artist = record["artist"] as? String,
            let rank = record["rank"] as? Int,
            let shortlistId = record["shortlistId"] as? String
        else {
            return nil
        }

        if let artwork = record["artworkURL"] as? String {
            self.artworkURL = URL(string: artwork)
        } else {
            self.artworkURL = nil
        }

        self.id = id
        self.title = title
        self.artist = artist
        self.rank = rank
        self.shortlistId = shortlistId
        self.upc = record["upc"] as? String
        recordID = record.recordID
    }
}
