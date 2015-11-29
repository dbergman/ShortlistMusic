//
//  Shortlist.m
//  shortList
//
//  Created by Dustin Bergman on 5/24/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLShortlist.h"

@implementation SLShortlist

@dynamic shortListName;
@dynamic shortListYear;
@dynamic shortListUserId;
@synthesize shortListAlbums = _shortListAlbums;

+ (NSString *)parseClassName {
    return @"SLShortlist";
}

- (void)setShortListAlbums:(NSArray *)shortListAlbums {
    _shortListAlbums = shortListAlbums;
}

@end
