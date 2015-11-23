//
//  SLParseController.swift
//  shortList
//
//  Created by Dustin Bergman on 6/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

typealias SLGetUsersShortListBlock = (shortlists:NSArray) -> Void
typealias SLShortListAlbumsBlock = (albums:NSArray) -> Void
typealias SLIdCheckAction = (exists:Bool) -> Void

import Foundation

let ShortLists = "Shortlist"
let ShortListAlbums = "ShortListAlbum"

class SLParseController : NSObject {
    class func saveShortlist (newShortList:Shortlist) {
        newShortList.shortListUserId = SLParseController.getCurrentUser().objectId!
        newShortList.saveInBackgroundWithBlock {
            (success, error) -> Void in
            if !success {
                newShortList.saveEventually(nil)
            }
        }
    }

    class func getUsersShortLists(completion:SLGetUsersShortListBlock) {
        let query:PFQuery = PFQuery (className: ShortLists)
        query.whereKey("shortListUserId", equalTo: SLParseController.getCurrentUser().objectId!)
        
        query.findObjectsInBackgroundWithBlock { (shortLists: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if (shortLists!.count == 0) {
                    completion(shortlists: shortLists!)
                }
                else {
                    var shortListCounter = 0
                    for shortList:Shortlist in shortLists as! [Shortlist] {
                        self.getShortListAlbums(shortList, completion: { (albums) -> Void in
                            shortList.shortListAlbums = albums as [AnyObject]
                            
                            shortListCounter++
                            if (shortListCounter == shortLists!.count) {
                                completion(shortlists: shortLists!)
                            }
                        })
                    }
                }
            }
        }
    }
    
    class func getShortListAlbums(shortList:Shortlist!, completion:SLShortListAlbumsBlock) {
        let query:PFQuery = PFQuery (className: ShortListAlbums)
        query.whereKey("shortListId", equalTo: shortList.objectId!)
        query.orderByAscending("shortListRank")

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
    
    class func removeShortList(shortlist:Shortlist, completion:SLGetUsersShortListBlock) {
        for album:ShortListAlbum in shortlist.shortListAlbums as! [ShortListAlbum] {
            album.deleteInBackgroundWithBlock({ (success, error) -> Void in})
        }
        
        shortlist.deleteInBackgroundWithBlock {
            (success, error) -> Void in
            if !(error != nil) {
                SLParseController.getUsersShortLists(completion)
            }
        }
    }
    
    class func addAlbumToShortList(shortlistAlbum:ShortListAlbum, shortlist:Shortlist, completion:dispatch_block_t) {
        shortlistAlbum.shortListUserId = SLParseController.getCurrentUser().objectId
        shortlistAlbum.saveInBackgroundWithBlock { (success, error) -> Void in
            let relation:PFRelation = shortlist.relationForKey("ShortListAlbum")
            relation.addObject(shortlistAlbum)
            shortlist.saveInBackgroundWithBlock {
                (success, error) -> Void in
                if !success {
                    shortlistAlbum.saveEventually(nil)
                }
                completion();
            }
        }
    }
    
    class func removeAlbumFromShortList(shortList:Shortlist, shortlistAlbum:ShortListAlbum, completion:SLShortListAlbumsBlock) {
        shortlistAlbum.deleteInBackgroundWithBlock {(success, error) -> Void in
            if success {
                SLParseController.getShortListAlbums(shortList, completion: completion)
            }
        }
    }
    
    class func updateShortListAlbums(shortlist:Shortlist, completion:dispatch_block_t) {
        if (shortlist.shortListAlbums.count == 0) {
            completion()
            return
        }
        
        for album: ShortListAlbum in shortlist.shortListAlbums as! [ShortListAlbum]  {
            album.saveInBackgroundWithBlock {
                (success, error) -> Void in
                if !success {
                    album.saveEventually(nil)
                }
            }
        }
        completion()
    }
    
    class func doesUserNameExist(username:String, checkAction:SLIdCheckAction) {
        let query = PFUser.query()
        query!.whereKey("username", equalTo: username)
        query!.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) in
            if error == nil {
                if (objects!.count > 0){
                    checkAction(exists: true)
                } else {
                    checkAction(exists: false)
                }
            } else {
                checkAction(exists: true)
            }
        }
    }
    
    class func doesSocialIdExist(socialId:String, checkAction:SLIdCheckAction) {
        let query = PFUser.query()
        query!.whereKey("socialId", equalTo: socialId)
        query!.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) in
            if error == nil {
                if (objects!.count > 0){
                    checkAction(exists: true)
                } else {
                    checkAction(exists: false)
                }
            } else {
                checkAction(exists: true)
            }
        }
    }
    
    class func getCurrentUser() -> PFUser {
        return PFUser.currentUser()!
    }
}

