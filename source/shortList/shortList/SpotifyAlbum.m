//
//  SpotifyAlbum.m
//  shortList
//
//  Created by Dustin Bergman on 8/9/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SpotifyAlbum.h"

static NSString * const kSLSpotifyDeepLinkPrefix = @"spotify:";

@implementation SpotifyAlbum

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"spotifyAlbumUrl": @"external_urls.spotify"
      };
}

@end
