//
//  ShortListAlbum.h
//  shortList
//
//  Created by Dustin Bergman on 6/6/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Parse/Parse.h>
@class ItunesTrack;

@interface SLShortListAlbum : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) NSInteger albumId; //collectionId
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *releaseYear;
@property (nonatomic, strong) NSString *shortListId;
@property (nonatomic, strong) NSString *shortListUserId;
@property (nonatomic, strong) NSString *albumArtWork;
@property (nonatomic, assign) NSInteger shortListRank;

+ (instancetype)createShortListAlbum:(ItunesTrack *)albumDetails;

@end
