//
//  SpotifyAlbums.m
//  shortList
//
//  Created by Dustin Bergman on 8/9/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SpotifyAlbums.h"
#import "SpotifyAlbum.h"

@implementation SpotifyAlbums

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"albumResults": @"albums.items"
      };
}

+ (NSValueTransformer *)albumResultsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:SpotifyAlbum.class];
}


@end
