//
//  SLParseController.swift
//  shortList
//
//  Created by Dustin Bergman on 6/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

typealias SLGetUsersShortListBLock = (shortlists:NSArray) -> Void

import Foundation

let ShortLists = "Shortlist"

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
        var query:PFQuery = PFQuery (className: "Shortlist")
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
    
    class func removeShortList(shortlist:Shortlist, completion:SLGetUsersShortListBLock) {
        shortlist.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
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
    
    class func getCurrentUser() -> PFUser {
        return PFUser.currentUser()!
    }
}

