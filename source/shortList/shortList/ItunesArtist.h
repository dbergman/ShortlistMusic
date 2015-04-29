//
//  ItunesArtist.h
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ItunesArtist : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *wrapperType;
@property (nonatomic, copy, readonly) NSString *artistType;
@property (nonatomic, copy, readonly) NSString *artistName;
@property (nonatomic, copy, readonly) NSString *artistLinkUrl;
@property (nonatomic, assign, readonly) NSInteger artistId;
@property (nonatomic, copy, readonly) NSString *primaryGenreName;
@property (nonatomic, assign, readonly) NSInteger primaryGenreId;
@property (nonatomic, copy, readonly) NSString *radioStationUrl;

@end
