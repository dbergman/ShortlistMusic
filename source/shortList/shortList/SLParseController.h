//
//  SLParseController.h
//  shortList
//
//  Created by Dustin Bergman on 5/24/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Shortlist;

typedef void(^SLGetUsersShortListBLock)(NSArray *shortlists);

@interface SLParseController : NSObject

+ (void)saveShortlist:(Shortlist *)newShortList;
+ (void)getUsersShortLists:(SLGetUsersShortListBLock)completion;

@end
