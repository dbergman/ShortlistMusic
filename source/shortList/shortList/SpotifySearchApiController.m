//
//  SpotifySearchApiController.m
//  shortList
//
//  Created by Dustin Bergman on 8/9/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SpotifySearchApiController.h"

static NSString * const kBaseURL = @"https://api.spotify.com/v1/";

@implementation SpotifySearchApiController

+ (SpotifySearchApiController *)sharedManager {
    static SpotifySearchApiController *spotifySearchController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        spotifySearchController = [[SpotifySearchApiController alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    });
    
    return spotifySearchController;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer new];
        self.requestSerializer = [AFJSONRequestSerializer new];
        //[self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    return self;
}

// https://api.spotify.com/v1/search?query=album:Halcyon+Digest+artist:Deerhunter&offset=0&limit=1&type=album&market=US
-(void)spotifySearchByArist:(NSString *)artist album:(NSString *)album completion:(SLSpotifyFetchResultsBlock)completion {
    
  //https://api.spotify.com/v1/search?q=album:moms+artist:menomena&type=album&market=US&limit=1
   
    
    NSDictionary *params = @{@"q":[NSString stringWithFormat:@"album:%@ artist:%@",album, artist], @"type": @"album", @"market": @"us", @"limit": @(1)};
    
    [self GET:@"search" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"");
    }];
////        NSError *error;
////        ItunesSearchAlbum *itunesSearchAlbum = [MTLJSONAdapter modelOfClass:[ItunesSearchAlbum class] fromJSONDictionary:responseObject error:&error];
////        if (error) {
////            if (completion) {
////                completion(nil, error);
////            }
////        }
////        else {
////            if (completion) {
////                completion(itunesSearchAlbum, nil);
////            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"FAILURE");
//    }];
}

@end
