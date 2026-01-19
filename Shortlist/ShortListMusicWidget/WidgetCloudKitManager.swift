//
//  WidgetCloudKitManager.swift
//  ShortListMusicWidget
//
//  Created by Dustin Bergman on 10/5/25.
//

import CloudKit
import Foundation

/// Standalone CloudKit manager for widgets
/// Uses the same CloudKit container as the main app but doesn't require MusicKit dependencies
class WidgetCloudKitManager {
    static let shared = WidgetCloudKitManager()
    
    private let container: CKContainer
    
    private init() {
        // Use the same CloudKit container as the main app
        // This ensures the widget can access the same data
        self.container = CKContainer(identifier: "iCloud.com.dus.shortList")
    }
    
    /// Fetch all albums from the current user's shortlists - useful for widgets
    func getAllAlbums(completion: @escaping (Result<[ShortlistAlbum], Error>) -> Void) {
        print("Widget CloudKit: Starting to fetch user's albums...")
        
        // First, get the user's record ID
        container.fetchUserRecordID { [weak self] userRecordID, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Widget CloudKit: Error fetching user record ID: \(error.localizedDescription)")
                // If we can't get user ID (bundle ID permission issue), return empty array
                // This allows the widget to gracefully degrade
                completion(.success([]))
                return
            }
            
            guard let userRecordID = userRecordID else {
                print("Widget CloudKit: No user record ID found")
                completion(.success([]))
                return
            }
            
            print("Widget CloudKit: User record ID found: \(userRecordID.recordName)")
            
            // Fetch all shortlists for this user
            let shortlistPredicate = NSPredicate(format: "creatorUserRecordID = %@", userRecordID)
            let shortlistQuery = CKQuery(recordType: "Shortlists", predicate: shortlistPredicate)
            
            self.container.publicCloudDatabase.fetch(withQuery: shortlistQuery) { shortlistResult in
                do {
                    let shortlistRecords = try shortlistResult.get()
                    let shortlists = shortlistRecords.matchResults
                        .compactMap { _, result in try? result.get() }
                        .compactMap { Shortlist(with: $0) }
                    
                    print("Widget CloudKit: Found \(shortlists.count) shortlists for user")
                    
                    if shortlists.isEmpty {
                        print("Widget CloudKit: No shortlists found for user")
                        completion(.success([]))
                        return
                    }
                    
                    let shortlistIDs = shortlists.map { $0.id }
                    
                    // Fetch all albums for these shortlists
                    let albumPredicate = NSPredicate(format: "shortlistId IN %@", shortlistIDs)
                    let albumQuery = CKQuery(recordType: "Albums", predicate: albumPredicate)
                    albumQuery.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
                    
                    self.container.publicCloudDatabase.fetch(withQuery: albumQuery) { albumResult in
                        do {
                            let albumRecords = try albumResult.get()
                            print("Widget CloudKit: Found \(albumRecords.matchResults.count) album records")
                            
                            let albums = albumRecords.matchResults
                                .compactMap { _, result in try? result.get() }
                                .compactMap { ShortlistAlbum(with: $0) }
                            
                            print("Widget CloudKit: Successfully parsed \(albums.count) albums for user")
                            for album in albums.prefix(3) {
                                print("Widget CloudKit: Album \(album.title) - Artwork URL: \(album.artworkURLString)")
                            }
                            completion(.success(albums))
                        } catch {
                            print("Widget CloudKit: Error fetching albums: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                    }
                } catch {
                    print("Widget CloudKit: Error fetching shortlists: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
}
