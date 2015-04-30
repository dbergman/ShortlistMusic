//
//  ItunesAlbum.h
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ItunesAlbum : MTLModel <MTLJSONSerializing>

//Itunes
@property (nonatomic, assign, readonly) NSInteger amgArtistId;
@property (nonatomic, assign, readonly) NSInteger artistId;
@property (nonatomic, copy, readonly) NSString *artistName;
@property (nonatomic, copy, readonly) NSString *artistViewUrl;
@property (nonatomic, copy, readonly) NSString *artworkUrl100;
@property (nonatomic, copy, readonly) NSString *artworkUrl60;
@property (nonatomic, copy, readonly) NSString *collectionCensoredName;
@property (nonatomic, copy, readonly) NSString *collectionExplicitness;
@property (nonatomic, assign, readonly) NSInteger collectionId;
@property (nonatomic, copy, readonly) NSString *collectionName;
@property (nonatomic, copy, readonly) NSString *collectionPrice;
@property (nonatomic, copy, readonly) NSString *collectionType;
@property (nonatomic, assign, readonly) NSString *collectionViewUrl;
@property (nonatomic, copy, readonly) NSString *copyright;
@property (nonatomic, copy, readonly) NSString *country;
@property (nonatomic, assign, readonly) NSString *primaryGenreName;
@property (nonatomic, copy, readonly) NSString *releaseDate;
@property (nonatomic, copy, readonly) NSString *trackCount;
@property (nonatomic, copy, readonly) NSString *wrapperType;

//Custom
@property (nonatomic, copy, readonly) NSString *releaseYear;

@end
