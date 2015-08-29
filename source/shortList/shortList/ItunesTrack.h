//
//  ItunesTrack.h
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ItunesTrack : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign, readonly) NSInteger artistId;
@property (nonatomic, copy, readonly) NSString *artistName;
@property (nonatomic, copy, readonly) NSString *artistViewUrl;
@property (nonatomic, copy, readonly) NSString *artworkUrl100;
@property (nonatomic, copy, readonly) NSString *artworkUrl600;
@property (nonatomic, copy, readonly) NSString *artworkUrl30;
@property (nonatomic, copy, readonly) NSString *artworkUrl60;
@property (nonatomic, copy, readonly) NSString *collectionCensoredName;
@property (nonatomic, copy, readonly) NSString *collectionExplicitness;
@property (nonatomic, assign, readonly) NSInteger collectionId;
@property (nonatomic, copy, readonly) NSString *collectionName;
@property (nonatomic, copy, readonly) NSNumber *collectionPrice;
@property (nonatomic, copy, readonly) NSString *collectionType;
@property (nonatomic, copy, readonly) NSString *collectionViewUrl;
@property (nonatomic, copy, readonly) NSString *country;
@property (nonatomic, copy, readonly) NSString *currency;
@property (nonatomic, assign, readonly) NSInteger discCount;
@property (nonatomic, assign, readonly) NSInteger discNumber;
@property (nonatomic, copy, readonly) NSString *kind;
@property (nonatomic, copy, readonly) NSString *previewUrl;
@property (nonatomic, copy, readonly) NSString *primaryGenreName;
@property (nonatomic, copy, readonly) NSString *radioStationUrl;
@property (nonatomic, copy, readonly) NSString *releaseDate;
@property (nonatomic, copy, readonly) NSString *trackCensoredName;
@property (nonatomic, copy, readonly) NSNumber *trackCount;
@property (nonatomic, copy, readonly) NSString *trackExplicitness;
@property (nonatomic, assign, readonly) NSInteger trackId;
@property (nonatomic, copy, readonly) NSString *trackName;
@property (nonatomic, assign, readonly) NSInteger trackNumber;
@property (nonatomic, assign, readonly) NSInteger trackPrice;
@property (nonatomic, assign, readonly) NSInteger trackTimeMillis;
@property (nonatomic, copy, readonly) NSString *trackViewUrl;
@property (nonatomic, copy, readonly) NSString *wrapperType;

//Custom
@property (nonatomic, copy, readonly) NSString *releaseYear;
@property (nonatomic, copy, readonly) NSString *trackDuration;
@property (nonatomic, copy) NSString *spotifyDeepLink;

@end
