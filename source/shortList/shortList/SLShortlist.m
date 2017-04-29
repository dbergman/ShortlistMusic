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

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.shortListName = [decoder decodeObjectForKey:@"shortListName"];
    self.shortListYear = [decoder decodeObjectForKey:@"shortListYear"];
    self.shortListUserId = [decoder decodeObjectForKey:@"shortListUserId"];
    self.shortListAlbums = [decoder decodeObjectForKey:@"shortListAlbums"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.shortListName forKey:@"shortListName"];
    [encoder encodeObject:self.shortListYear forKey:@"shortListYear"];
    [encoder encodeObject:self.shortListUserId forKey:@"shortListUserId"];
    [encoder encodeObject:self.shortListAlbums forKey:@"shortListAlbums"];
}

@end
