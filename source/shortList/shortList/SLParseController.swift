//
//  SLParseControllerSW.swift
//  shortList
//
//  Created by Dustin Bergman on 6/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

typealias SLGetUsersShortListBLock = (shortlists:NSArray) -> Void

import Foundation

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
    
    class func getCurrentUser() -> PFUser {
        return PFUser.currentUser()!
    }
}

