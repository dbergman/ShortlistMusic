//
//  ItunesSearchAlbum.h
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ItunesSearchAlbum : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger resultCount;
@property (nonatomic, copy) NSArray *albumResults;

-(NSArray *)getArtistAlbums;

@end
