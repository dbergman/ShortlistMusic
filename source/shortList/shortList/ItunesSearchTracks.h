//
//  ItunesSearchTracks.h
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Mantle/Mantle.h>

@class ItunesTrack;

@interface ItunesSearchTracks : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign, readonly) NSInteger resultCount;
@property (nonatomic, copy, readonly) NSArray *tracks;

- (NSArray *)getAlbumTracks;
- (ItunesTrack *)getAlbumInfo;

@end
