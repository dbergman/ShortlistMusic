//
//  SLParseController.swift
//  shortList
//
//  Created by Dustin Bergman on 6/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

typealias SLGetUsersShortListBlock = (_ shortlists:NSArray) -> Void
typealias SLShortListAlbumsBlock = (_ albums:NSArray) -> Void
typealias SLIdCheckAction = (_ exists:Bool) -> Void
typealias SLResetEmailSuccess = () -> Void
typealias SLResetEmailFailure = () -> Void
typealias SLCompletion = () -> Void

import Foundation

let ShortLists = "SLShortlist"
let ShortListAlbums = "SLShortListAlbum"

class SLParseController : NSObject {
    class func saveShortlist (newShortList:SLShortlist, completion: @escaping SLCompletion) {
        newShortList.shortListUserId = SLParseController.getCurrentUser().objectId!
        newShortList.saveInBackground {
            (success, error) -> Void in
            if !success {
                newShortList.saveEventually(nil)
            }
            else {
                completion()
            }
        }
    }

    class func getUsersShortLists(completion:@escaping SLGetUsersShortListBlock) {
        let query:PFQuery = PFQuery (className: ShortLists)
        query.whereKey("shortListUserId", equalTo: SLParseController.getCurrentUser().objectId!)

        query.findObjectsInBackground { shortLists, error in
            if (error == nil) {
                if (shortLists!.count == 0) {
                    completion(shortLists! as NSArray)
                }
                else {
                    var shortListCounter = 0
                    for shortList:SLShortlist in shortLists as! [SLShortlist] {
                        self.getShortListAlbums(shortList: shortList, completion: { (albums) -> Void in
                            shortList.shortListAlbums = albums as [AnyObject]
                            
                            shortListCounter += 1
                            if (shortListCounter == shortLists!.count) {
                                completion(shortLists! as NSArray)
                            }
                        })
                    }
                }
            }
        }
    }
    
    class func getShortListAlbums(shortList:SLShortlist!, completion:@escaping SLShortListAlbumsBlock) {
        let query:PFQuery = PFQuery (className: ShortListAlbums)
        query.whereKey("shortListId", equalTo: shortList.objectId!)
        query.order(byAscending: "shortListRank")
        
        query.findObjectsInBackground { albums, error in
            if error == nil {
                completion(albums! as NSArray)
            }
            else {
                //TODO HANDLE ERROR
            }
        }
    }
    
    class func removeShortList(shortlist:SLShortlist, completion:@escaping SLGetUsersShortListBlock) {
        for album:SLShortListAlbum in shortlist.shortListAlbums as! [SLShortListAlbum] {
            album.deleteInBackground(block: { (success, error) -> Void in})
        }
        
        shortlist.deleteInBackground {
            (success, error) -> Void in
            if !(error != nil) {
                SLParseController.getUsersShortLists(completion: completion)
            }
        }
    }
    
    class func addAlbumToShortList(shortlistAlbum:SLShortListAlbum, shortlist:SLShortlist, completion:@escaping SLCompletion) {
        shortlistAlbum.shortListUserId = SLParseController.getCurrentUser().objectId
        shortlistAlbum.saveInBackground { (success, error) -> Void in
            let relation:PFRelation = shortlist.relation(forKey: "ShortListAlbum")
            relation.add(shortlistAlbum)
            shortlist.saveInBackground {
                (success, error) -> Void in
                if !success {
                    shortlistAlbum.saveEventually(nil)
                }
                completion();
            }
        }
    }
    
    class func removeAlbumFromShortList(shortList:SLShortlist, shortlistAlbum:SLShortListAlbum, completion:@escaping SLShortListAlbumsBlock) {
        shortlistAlbum.deleteInBackground {(success, error) -> Void in
            if success {
                SLParseController.getShortListAlbums(shortList: shortList, completion: completion)
            }
        }
    }
    
    class func updateShortListAlbums(shortlist:SLShortlist, completion:dispatch_block_t) {
        if (shortlist.shortListAlbums.count == 0) {
            completion()
            return
        }
        
        for album:SLShortListAlbum in shortlist.shortListAlbums as! [SLShortListAlbum]  {
            album.saveInBackground {
                (success, error) -> Void in
                if !success {
                    album.saveEventually(nil)
                }
            }
        }
        completion()
    }
    
    class func doesUserNameExist(username:String, checkAction:@escaping SLIdCheckAction) {
        let query = PFUser.query()
        query!.whereKey("username", equalTo: username)
        
        query?.findObjectsInBackground { objects, error in
            if error == nil {
                if (objects!.count > 0){
                    checkAction(true)
                } else {
                    checkAction(false)
                }
            } else {
                checkAction(true)
            }
        }
    }
    
    class func doesUserEmailExist(email:String, checkAction:@escaping SLIdCheckAction) {
        let query = PFUser.query()
        query!.whereKey("email", equalTo: email)
        
        query!.findObjectsInBackground { objects, error in
            if error == nil {
                if (objects!.count > 0){
                    checkAction(true)
                } else {
                    checkAction(false)
                }
            } else {
                checkAction(true)
            }
        }
    }
    
    class func doesSocialIdExist(socialId:String, checkAction:@escaping SLIdCheckAction) {
        let query = PFUser.query()
        query!.whereKey("socialId", equalTo: socialId)
        query!.findObjectsInBackground { objects, error in
            if error == nil {
                if (objects!.count > 0){
                    checkAction(true)
                } else {
                    checkAction(false)
                }
            } else {
                checkAction(true)
            }
        }
    }
    
    class func resetPassword(email: String, successAction:@escaping SLResetEmailSuccess, failureAction:@escaping SLResetEmailFailure) {
        let emailClean = email.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        PFUser.requestPasswordResetForEmail(inBackground: emailClean) { (success, error) -> Void in
            (error == nil) ? successAction() : failureAction()
        }
    }
    
    class func getCurrentUser() -> PFUser {
        return PFUser.current()!
    }
}

