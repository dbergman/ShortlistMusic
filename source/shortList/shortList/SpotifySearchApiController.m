//
//  SpotifySearchApiController.m
//  shortList
//
//  Created by Dustin Bergman on 8/9/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SpotifySearchApiController.h"
#import <Mantle/Mantle.h>
#import "SpotifyAlbums.h"

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
    }
    
    return self;
}

// https://api.spotify.com/v1/search?query=album:Halcyon+Digest+artist:Deerhunter&offset=0&limit=1&type=album&market=US
-(void)spotifySearchByArist:(NSString *)artist album:(NSString *)album completion:(SLSpotifyFetchResultsBlock)completion {
    NSDictionary *params = @{@"q":[NSString stringWithFormat:@"album:%@ artist:%@",album, artist], @"type": @"album", @"market": @"us", @"limit": @(1)};
    
    [self GET:@"search" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error;
        SpotifyAlbums *spotifyAlbums = [MTLJSONAdapter modelOfClass:[SpotifyAlbums class]  fromJSONDictionary:responseObject error:&error];
        if (error) {
            if (completion) {
                completion(nil, error);
            }
        }
        else {
            if (completion) {
                completion(spotifyAlbums, nil);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"FAILURE");
    }];
}

@end
