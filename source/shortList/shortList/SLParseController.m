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
    shortList[@"year"] = newShortList.shortListYear;
    [shortList saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFRelation *relation = [user relationForKey:@"shortList"];
            [relation addObject:shortList];
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                }
            }];
        } else {
            // There was a problem, check error.description
        }
    }];
    

}

@end
