//
//  SLParseController.swift
//  shortList
//
//  Created by Dustin Bergman on 6/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

typealias SLGetUsersShortListBlock = (_ shortlists: [SLShortlist]) -> Void
typealias SLShortListAlbumsBlock = (_ albums: [SLShortListAlbum]) -> Void
typealias SLIdCheckAction = (_ exists: Bool) -> Void
typealias SLResetEmailSuccess = () -> Void
typealias SLResetEmailFailure = () -> Void
typealias SLCompletion = () -> Void

import Foundation

class SLParseController : NSObject {
    private static let ShortLists = "SLShortlist"
    private static let ShortListAlbums = "SLShortListAlbum"
    
    class func saveShortlist (newShortList:SLShortlist, completion: @escaping SLCompletion) {
        guard let shortListUserId = PFUser.current()?.objectId else { assertionFailure("SLParseController saveShortlist Fail"); return }
        
        newShortList.shortListUserId = shortListUserId
        newShortList.saveInBackground { _, error in
            guard error == nil else { newShortList.saveEventually(nil); return }
            
            completion()
        }
    }

    class func getUsersShortLists(completion:@escaping SLGetUsersShortListBlock) {
        guard let shortListUserId = PFUser.current()?.objectId else { assertionFailure("SLParseController getUsersShortLists Fail"); return }
        
        let query = PFQuery(className: ShortLists)
        query.whereKey("shortListUserId", equalTo: shortListUserId)

        query.findObjectsInBackground { shortLists, error in
            guard let shortLists = shortLists as? [SLShortlist], error == nil else { return }
            guard !shortLists.isEmpty else { completion(shortLists); return }
            
            var shortListCounter = 0
            
            for shortList in shortLists {
                self.getShortListAlbums(shortList: shortList, completion: { albums in
                    shortList.shortListAlbums = albums
                    shortListCounter += 1
                    
                    if (shortListCounter == shortLists.count) {
                        completion(shortLists)
                    }
                })
            }
        }
    }
    
    class func getShortListAlbums(shortList: SLShortlist?, completion:@escaping SLShortListAlbumsBlock) {
        guard let shortList = shortList else { return }
        guard let shortListId = shortList.objectId else { return }
        
        let query:PFQuery = PFQuery (className: ShortListAlbums)
        query.whereKey("shortListId", equalTo: shortListId)
        query.order(byAscending: "shortListRank")
        
        query.findObjectsInBackground { albums, error in
            guard error == nil else { return }
            guard let albums = albums as? [SLShortListAlbum] else { return }
            
            completion(albums)
        }
    }
    
    class func removeShortList(shortlist:SLShortlist, completion:@escaping SLGetUsersShortListBlock) {
        for album in shortlist.shortListAlbums {
            album.deleteInBackground(block: { _, _ in })
        }
        
        shortlist.deleteInBackground { _, _  in
            SLParseController.getUsersShortLists(completion: completion)
        }
    }
    
    class func addAlbumToShortList(shortlistAlbum:SLShortListAlbum, shortlist:SLShortlist, completion:@escaping SLCompletion) {
        guard let shortListUserId = PFUser.current()?.objectId else { assertionFailure("SLParseController addAlbumToShortList Fail"); return }
        
        shortlistAlbum.shortListUserId = shortListUserId
        shortlistAlbum.saveInBackground { _, _ in
            let relation:PFRelation = shortlist.relation(forKey: "ShortListAlbum")
            relation.add(shortlistAlbum)
            
            shortlist.saveInBackground {  _, error in
                guard error == nil else { shortlistAlbum.saveEventually(nil); return }

                completion()
            }
        }
    }
    
    class func removeAlbumFromShortList(shortList:SLShortlist, shortlistAlbum:SLShortListAlbum, completion:@escaping SLShortListAlbumsBlock) {
        shortlistAlbum.deleteInBackground { success, _ in
            if success {
                SLParseController.getShortListAlbums(shortList: shortList, completion: completion)
            }
        }
    }
    
    class func updateShortListAlbums(shortlist:SLShortlist, completion:@escaping SLCompletion) {
        guard !shortlist.shortListAlbums.isEmpty  else { completion(); return  }
        
        for album in shortlist.shortListAlbums {
            album.saveInBackground { _, error in
                if error != nil {
                    album.saveEventually(nil)
                }
            }
        }
        
        completion()
    }
    
    class func doesUserNameExist(username:String, checkAction:@escaping SLIdCheckAction) {
        guard let query = PFUser.query() else { return }
        
        query.whereKey("username", equalTo: username).findObjectsInBackground { objects, error in
            guard let objects = objects, objects.isEmpty, error == nil else { checkAction(true); return }
            
            checkAction(false)
        }
    }
    
    class func doesUserEmailExist(email:String, checkAction:@escaping SLIdCheckAction) {
        guard let query = PFUser.query() else { return }
        
        query.whereKey("email", equalTo: email).findObjectsInBackground { objects, error in
            guard let objects = objects, objects.isEmpty, error == nil else { checkAction(true); return }
            
            checkAction(false)
        }
    }
    
    class func doesSocialIdExist(socialId:String, checkAction:@escaping SLIdCheckAction) {
        guard let query = PFUser.query() else { return }
        
        query.whereKey("socialId", equalTo: socialId).findObjectsInBackground { objects, error in
            guard let objects = objects, objects.isEmpty, error == nil else { checkAction(true); return }

            checkAction(false)
        }
    }
    
    class func resetPassword(email: String, successAction:@escaping SLResetEmailSuccess, failureAction:@escaping SLResetEmailFailure) {
        let emailClean = email.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        PFUser.requestPasswordResetForEmail(inBackground: emailClean) { _, error in
            (error == nil) ? successAction() : failureAction()
        }
    }
}
