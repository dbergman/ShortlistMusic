//
//  ShortListAlbum.m
//  shortList
//
//  Created by Dustin Bergman on 6/6/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLShortListAlbum.h"
#import "ItunesTrack.h"

@implementation SLShortListAlbum

@dynamic albumName;
@dynamic albumId;
@dynamic artistName;
@dynamic releaseYear;
@dynamic shortListId;
@dynamic albumArtWork;
@dynamic shortListUserId;
@dynamic shortListRank;

+ (NSString *)parseClassName {
    return @"SLShortListAlbum";
}

+ (instancetype)createShortListAlbum:(ItunesTrack *)albumDetails {
    SLShortListAlbum *shortList = [[SLShortListAlbum alloc] init];
    
    if (shortList) {
        shortList.albumName = albumDetails.collectionName;
        shortList.albumId = [albumDetails.collectionId integerValue];
        shortList.artistName = albumDetails.artistName;
        shortList.releaseYear = albumDetails.releaseYear;
        shortList.albumArtWork = albumDetails.artworkUrl600;
    }
    
    return shortList;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.albumName = [decoder decodeObjectForKey:@"albumName"];
    self.albumId = [decoder decodeIntegerForKey:@"albumId"];
    self.artistName = [decoder decodeObjectForKey:@"artistName"];
    self.releaseYear = [decoder decodeObjectForKey:@"releaseYear"];
    self.shortListId = [decoder decodeObjectForKey:@"shortListId"];
    self.shortListUserId = [decoder decodeObjectForKey:@"shortListUserId"];
    self.albumArtWork = [decoder decodeObjectForKey:@"albumArtWork"];
    self.shortListRank = [decoder decodeIntegerForKey:@"shortListRank"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.albumName forKey:@"albumName"];
    [encoder encodeInteger:self.albumId forKey:@"albumId"];
    [encoder encodeObject:self.artistName forKey:@"artistName"];
    [encoder encodeObject:self.releaseYear forKey:@"releaseYear"];
    [encoder encodeObject:self.shortListId forKey:@"shortListId"];
    [encoder encodeObject:self.shortListUserId forKey:@"shortListUserId"];
    [encoder encodeObject:self.albumArtWork forKey:@"albumArtWork"];
    [encoder encodeInteger:self.shortListRank forKey:@"shortListRank"];
}

@end
