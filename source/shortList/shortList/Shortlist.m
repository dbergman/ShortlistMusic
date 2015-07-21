//
//  Shortlist.m
//  shortList
//
//  Created by Dustin Bergman on 5/24/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "Shortlist.h"

@implementation Shortlist

@dynamic shortListName;
@dynamic shortListYear;
@dynamic shortListUserId;
@synthesize shortListAlbums;

+ (NSString *)parseClassName {
    return @"Shortlist";
}

@end
