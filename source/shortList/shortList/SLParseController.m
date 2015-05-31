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
    
    PFObject *shortList = [PFObject objectWithClassName:@"ShortList"];
    shortList[@"name"] = newShortList.shortListName;
    shortList[@"year"] = (newShortList.shortListYear) ? newShortList.shortListYear: NSLocalizedString(@"All", nil);
    shortList[@"userId"] = user.objectId;
    [shortList saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSInteger errCode = [error code];
            if (kPFErrorConnectionFailed == errCode ||  kPFErrorInternalServer == errCode)
                [shortList saveEventually];
        }
    }];
}

@end
