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
    let artworkURLString: String
    let rank: Int
    let shortlistId: String
    let upc: String?
    let appleAlbumURL: String?
    var recordID: CKRecord.ID
}

extension ShortlistAlbum {
    init?(with record: CKRecord) {
        guard
            let id = record["id"] as? String,
            let title = record["title"] as? String,
            let artist = record["artist"] as? String,
            let rank = record["rank"] as? Int,
            let shortlistId = record["shortlistId"] as? String,
            let artworkURLString =  record["artwork"] as? String
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURLString = artworkURLString
        self.rank = rank
        self.shortlistId = shortlistId
        self.upc = record["upc"] as? String
        self.appleAlbumURL = record["appleAlbumURL"] as? String
        recordID = record.recordID
    }
    
    init(shortlistAlbum: ShortlistAlbum, rank: Int) {
        self.id = shortlistAlbum.id
        self.title = shortlistAlbum.title
        self.artist = shortlistAlbum.artist
        self.artworkURLString = shortlistAlbum.artworkURLString
        self.rank = rank
        self.shortlistId = shortlistAlbum.shortlistId
        self.upc = shortlistAlbum.upc
        self.appleAlbumURL = shortlistAlbum.appleAlbumURL
        recordID = shortlistAlbum.recordID
    }
}
