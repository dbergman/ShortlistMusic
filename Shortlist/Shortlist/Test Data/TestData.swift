//
//  TestData.swift
//  Shortlist
//
//  Created by Dustin Bergman on 12/17/23.
//

import Foundation
import CloudKit

struct TestData {
    struct ShortLists{
        static let shortList: Shortlist = {
            Shortlist(
                id: "uniqueShortlistID",
                name: "Shortlist One",
                year: "All",
                recordID: CKRecord.ID(recordName: "uniqueRecordName1"), 
                createdTimestamp: Date(),
                albums: [
                    TestData.ShortListAlbums.revolverShortListAlbum,
                    TestData.ShortListAlbums.sgtPepperShortListAlbum
                ])
        }()
    }

    struct ShortListAlbums {
        static let revolverShortListAlbum: ShortlistAlbum = {
            ShortlistAlbum(
                id: UUID().uuidString,
                title: "Revolver",
                artist: "The Beatles",
                artworkURLString:  "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/58/4a/10/584a1058-de0a-6a6b-d0bd-da09a028b8bc/00602567705499.rgb.jpg/60x60bb.jpg",
                rank: 1,
                shortlistId: "uniqueShortlistID",
                upc: "00602567705499",
                recordID: CKRecord.ID(recordName: "uniqueAlbumRecordName")
            )
        }()

        static let sgtPepperShortListAlbum: ShortlistAlbum = {
            ShortlistAlbum(
                id: UUID().uuidString,
                title: "Sgt. Pepper's Lonely Hearts Club Band",
                artist: "The Beatles",
                artworkURLString:  "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/6f/79/8d/6f798d84-7475-8525-fc91-f7b51b2b5a9b/00602567725428.rgb.jpg/60x60bb.jpg",
                rank: 2,
                shortlistId: "uniqueShortlistID",
                upc: "00602567725428",
                recordID: CKRecord.ID(recordName: "uniqueAlbumRecordName")
            )
        }()
        
        static let whiteShortListAlbum: ShortlistAlbum = {
            ShortlistAlbum(
                id: UUID().uuidString,
                title: "The Beatles (White Album)",
                artist: "The Beatles",
                artworkURLString:  "https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/14/d1/3d/14d13df6-b66a-cdd8-b71c-7f678f7c7fbd/18UMGIM58178.rgb.jpg/60x60bb.jpg",
                rank: 3,
                shortlistId: "uniqueShortlistID",
                upc: "00602577087097",
                recordID: CKRecord.ID(recordName: "uniqueAlbumRecordName")
            )
        }()
        
        static let abbeyRoadShortListAlbum: ShortlistAlbum = {
            ShortlistAlbum(
                id: UUID().uuidString,
                title: "Abbey Road",
                artist: "The Beatles",
                artworkURLString:  "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/df/db/61/dfdb615d-47f8-06e9-9533-b96daccc029f/18UMGIM31076.rgb.jpg/60x60bb.jpg",
                rank: 4,
                shortlistId: "uniqueShortlistID",
                upc: "00602567713449",
                recordID: CKRecord.ID(recordName: "uniqueAlbumRecordName")
            )
        }()
        
        static let letItBeShortListAlbum: ShortlistAlbum = {
            ShortlistAlbum(
                id: UUID().uuidString,
                title: "Let It Be",
                artist: "The Beatles",
                artworkURLString:  "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/ae/98/4c/ae984c7a-cd06-a7cd-e8bf-32cb15ba698d/00602567705475.rgb.jpg/60x60bb.jpg",
                rank: 5,
                shortlistId: "uniqueShortlistID",
                upc: "00602567705475",
                recordID: CKRecord.ID(recordName: "uniqueAlbumRecordName")
            )
        }()

        static let magicalMysteryTourShortListAlbum: ShortlistAlbum = {
            ShortlistAlbum(
                id: UUID().uuidString,
                title: "Magical Mystery Tour",
                artist: "The Beatles",
                artworkURLString:  "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/43/0e/37/430e3790-75d5-c96a-1380-f9d9803aa700/18UMGIM31245.rgb.jpg/60x60bb.jpg",
                rank: 6,
                shortlistId: "uniqueShortlistID",
                upc: "00602567705437",
                recordID: CKRecord.ID(recordName: "uniqueAlbumRecordName")
            )
        }()
    }
}
