//
//  ItunesSearchAPIController.h
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@class ItunesSearchAlbum;

typedef void(^SLItunesFetchResultsBlock)(id responseObject, NSError *error);

@interface ItunesSearchAPIController : AFHTTPSessionManager

+ (ItunesSearchAPIController *)sharedManager;

//search
-(void)getSearchResultsWithBlock:(NSString *)artist completion:(SLItunesFetchResultsBlock)completion;

//Albums
- (void)getAlbumsForArtist:(NSString *)artistId completion:(SLItunesFetchResultsBlock)completion;

//Tracks
- (void)getTracksForAlbumID:(NSString *)albumID completion:(SLItunesFetchResultsBlock)completion;

+ (void)filterAlbums:(ItunesSearchAlbum *)albumResult ByYear:(NSString *)filterYear;

@end
