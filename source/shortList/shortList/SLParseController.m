//
//  SLParseController.m
//  shortList
//
//  Created by Dustin Bergman on 5/24/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLParseController.h"
#import "Shortlist.h"
#import <Parse/Parse.h>

@implementation SLParseController

+ (void)saveShortlist:(Shortlist *)newShortList {
    PFUser *user = [PFUser currentUser];
    newShortList.shortListUserId = user.objectId;
    
    [newShortList saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSInteger errCode = [error code];
            if (kPFErrorConnectionFailed == errCode ||  kPFErrorInternalServer == errCode)
                [newShortList saveEventually];
        }
    }];
}

+ (void)getUsersShortLists:(SLGetUsersShortListBLock)completion {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Shortlist"];
    [query whereKey:@"shortListUserId" equalTo:user.objectId];

    [query findObjectsInBackgroundWithBlock:^(NSArray *shortLists, NSError *error) {
        if (!error) {
            if (completion) {
                completion(shortLists);
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
