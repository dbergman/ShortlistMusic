//
//  ItunesSearchAPIController.h
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

typedef void(^SLItunesFetchResultsBlock)(id responseObject, NSError *error);

@interface ItunesSearchAPIController : AFHTTPRequestOperationManager

+ (ItunesSearchAPIController *)sharedManager;

//search
-(void)getSearchResultsWithBlock:(NSString *)artist completion:(SLItunesFetchResultsBlock)completion;

//Albums
- (void)getAlbumsForArtist:(NSNumber *) artistId completion:(SLItunesFetchResultsBlock)completion;

//Tracks
- (void)getTracksForAlbumID:(NSString *)albumID success:(void (^)(NSMutableArray* results))successBlock failure:(void (^)(NSError* error))failureBlock;

@end
