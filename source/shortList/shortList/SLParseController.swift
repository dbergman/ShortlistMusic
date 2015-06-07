//
//  SLParseController.swift
//  shortList
//
//  Created by Dustin Bergman on 6/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

typealias SLGetUsersShortListBLock = (shortlists:NSArray) -> Void
typealias SLShortListAlbumsBLock = (albums:NSArray) -> Void

import Foundation

let ShortLists = "Shortlist"
let ShortListAlbums = "ShortListAlbum"

class SLParseController : NSObject {
    class func saveShortlist (newShortList:Shortlist) {
        newShortList.shortListUserId = SLParseController.getCurrentUser().objectId
        
        newShortList.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if !success {
                newShortList.saveEventually(nil)
            }
        }
    }
    
    class func getUsersShortLists(completion:SLGetUsersShortListBLock) {
        var query:PFQuery = PFQuery (className: ShortLists)
        query.whereKey("shortListUserId", equalTo: SLParseController.getCurrentUser().objectId!)
        
        query.findObjectsInBackgroundWithBlock {
            (shortLists: [AnyObject]?, error: NSError?) -> Void in
            if !(error != nil) {
                completion(shortlists: shortLists!)
            }
            else {
                //TODO HANDLE ERROR
            }
        }
    }
    
    class func getShortListAlbums(shortList:Shortlist, completion:SLShortListAlbumsBLock) {
        var query:PFQuery = PFQuery (className: ShortListAlbums)
        query.whereKey("shortListId", equalTo: shortList.objectId!)
        
        query.findObjectsInBackgroundWithBlock {
            (albums: [AnyObject]?, error: NSError?) -> Void in
            if !(error != nil) {
                completion(albums: albums!)
            }
            else {
                //TODO HANDLE ERROR
            }
        }
    }
    
    class func removeShortList(shortlist:Shortlist, completion:SLGetUsersShortListBLock) {
        shortlist.deleteInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            SLParseController.getUsersShortLists(completion)
        }
    }
    
    class func addAlbumToShortList(shortlistAlbum:ShortListAlbum, completion:dispatch_block_t) {
        shortlistAlbum.shortListUserId = SLParseController.getCurrentUser().objectId
        shortlistAlbum.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if !success {
                shortlistAlbum.saveEventually(nil)
            }
            completion();
        }
    }
    
    class func removeAlbumFromShortList(shortList:Shortlist, shortlistAlbum:ShortListAlbum, completion:SLShortListAlbumsBLock) {
        shortlistAlbum.deleteInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
            if success {
                SLParseController.getShortListAlbums(shortList, completion: completion)
            }
        }
    }
    
    class func getCurrentUser() -> PFUser {
        return PFUser.currentUser()!
    }
}

