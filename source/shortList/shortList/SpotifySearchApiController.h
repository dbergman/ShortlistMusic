//
//  SpotifySearchApiController.h
//  shortList
//
//  Created by Dustin Bergman on 8/9/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@class SpotifyAlbums;

typedef void(^SLSpotifyFetchResultsBlock)(SpotifyAlbums *spotifyAlbums, NSError *error);

@interface SpotifySearchApiController : AFHTTPSessionManager

+ (SpotifySearchApiController *)sharedManager;

-(void)spotifySearchByArist:(NSString *)artist album:(NSString *)album completion:(SLSpotifyFetchResultsBlock)completion;

@end
