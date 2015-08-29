//
//  ShortListAlbum.m
//  shortList
//
//  Created by Dustin Bergman on 6/6/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ShortListAlbum.h"
#import "ItunesTrack.h"

@implementation ShortListAlbum

@dynamic albumName;
@dynamic albumId;
@dynamic artistName;
@dynamic releaseYear;
@dynamic shortListId;
@dynamic albumArtWork;
@dynamic shortListUserId;
@dynamic shortListRank;

+ (NSString *)parseClassName {
    return @"ShortListAlbum";
}

+ (instancetype)createShortListAlbum:(ItunesTrack *)albumDetails {
    ShortListAlbum *shortList = [[ShortListAlbum alloc] init];
    
    if (shortList) {
        shortList.albumName = albumDetails.collectionName;
        shortList.albumId = albumDetails.collectionId;
        shortList.artistName = albumDetails.artistName;
        shortList.releaseYear = albumDetails.releaseYear;
        shortList.albumArtWork = albumDetails.artworkUrl600;
    }
    
    return shortList;
}


@end
