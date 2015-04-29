//
//  ItunesSearchArtist.h
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ItunesSearchArtist : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign, readonly) NSInteger resultCount;
@property (nonatomic, copy, readonly) NSArray *artistResults;

@end
