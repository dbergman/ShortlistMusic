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
    private let accessQueue = DispatchQueue(label: "com.shortlist.widget.cloudkit", qos: .userInitiated)
    private let cacheValidityInterval: TimeInterval = 5.0
    
    private var cachedAlbums: [ShortlistAlbum]?
    private var cacheTimestamp: Date?
    private var inFlightCompletions: [(Result<[ShortlistAlbum], Error>) -> Void] = []
    private var isFetching = false
    
    private init() {
        self.container = CKContainer(identifier: "iCloud.com.dus.shortList")
    }
    
    func getAllAlbums(completion: @escaping (Result<[ShortlistAlbum], Error>) -> Void) {
        accessQueue.async { [weak self] in
            guard let self = self else {
                completion(.success([]))
                return
            }
            
            if let cached = self.cachedAlbums,
               let timestamp = self.cacheTimestamp,
               Date().timeIntervalSince(timestamp) < self.cacheValidityInterval {
                DispatchQueue.main.async {
                    completion(.success(cached))
                }
                return
            }
            
            if self.isFetching {
                self.inFlightCompletions.append(completion)
                return
            }
            
            self.isFetching = true
            self.inFlightCompletions.append(completion)
            
            self.container.fetchUserRecordID { [weak self] userRecordID, error in
                guard let self = self else { return }
                
                if error != nil {
                    self.notifyCompletions(result: .success([]))
                    return
                }
                
                guard let userRecordID = userRecordID else {
                    self.notifyCompletions(result: .success([]))
                    return
                }
                
                let shortlistPredicate = NSPredicate(format: "creatorUserRecordID = %@", userRecordID)
                let shortlistQuery = CKQuery(recordType: "Shortlists", predicate: shortlistPredicate)
                
                self.container.publicCloudDatabase.fetch(withQuery: shortlistQuery) { shortlistResult in
                    do {
                        let shortlistRecords = try shortlistResult.get()
                        let shortlists = shortlistRecords.matchResults
                            .compactMap { _, result in try? result.get() }
                            .compactMap { Shortlist(with: $0) }
                        
                        if shortlists.isEmpty {
                            self.notifyCompletions(result: .success([]))
                            return
                        }
                        
                        let shortlistIDs = shortlists.map { $0.id }
                        let albumPredicate = NSPredicate(format: "shortlistId IN %@", shortlistIDs)
                        let albumQuery = CKQuery(recordType: "Albums", predicate: albumPredicate)
                        albumQuery.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
                        
                        self.container.publicCloudDatabase.fetch(withQuery: albumQuery) { albumResult in
                            do {
                                let albumRecords = try albumResult.get()
                                let albums = albumRecords.matchResults
                                    .compactMap { _, result in try? result.get() }
                                    .compactMap { ShortlistAlbum(with: $0) }
                                
                                self.notifyCompletions(result: .success(albums))
                            } catch {
                                self.notifyCompletions(result: .failure(error))
                            }
                        }
                    } catch {
                        self.notifyCompletions(result: .failure(error))
                    }
                }
            }
        }
    }
    
    private func notifyCompletions(result: Result<[ShortlistAlbum], Error>) {
        accessQueue.async { [weak self] in
            guard let self = self else { return }
            
            if case .success(let albums) = result {
                self.cachedAlbums = albums
                self.cacheTimestamp = Date()
            }
            
            let completions = self.inFlightCompletions
            self.inFlightCompletions.removeAll()
            self.isFetching = false
            
            DispatchQueue.main.async {
                completions.forEach { $0(result) }
            }
        }
    }
}
