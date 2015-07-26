//
//  ItunesSearchAPIController.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ItunesSearchAPIController.h"
#import "ItunesSearchArtist.h"
#import "ItunesSearchAlbum.h"
#import "ItunesSearchTracks.h"
#import "ItunesAlbum.h"
#import <Mantle/Mantle.h>

static NSString * const kBaseURL = @"https://itunes.apple.com/";

@implementation ItunesSearchAPIController

+ (ItunesSearchAPIController *)sharedManager {
    static ItunesSearchAPIController *iTunesSearchController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iTunesSearchController = [[ItunesSearchAPIController alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    });
    
    return iTunesSearchController;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer new];
        self.requestSerializer = [AFJSONRequestSerializer new];
    }
    
    return self;
}

-(void)getSearchResultsWithBlock:(NSString *)artist completion:(SLItunesFetchResultsBlock)completion {
    [[self operationQueue] cancelAllOperations];
    
    NSDictionary *params = @{@"term": artist, @"media": @"music", @"entity": @"musicArtist", @"attribute": @"artistTerm", @"limit": @"200"};
    
    [self GET:@"search" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        ItunesSearchArtist *itunesSearchArtist = [MTLJSONAdapter modelOfClass:[ItunesSearchArtist class] fromJSONDictionary:responseObject error:&error];
        if (error) {
            if (completion) {
                completion(nil, error);
            }
        }
        else {
            if (completion) {
                completion(itunesSearchArtist, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE");
    }];
}

- (void)getAlbumsForArtist:(NSNumber *) artistId completion:(SLItunesFetchResultsBlock)completion {
    [[self operationQueue] cancelAllOperations];
    
    NSDictionary *params = @{@"id": artistId, @"media": @"music", @"entity": @"album", @"limit": @"200"};
    
    [self GET:@"lookup" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        ItunesSearchAlbum *itunesSearchAlbum = [MTLJSONAdapter modelOfClass:[ItunesSearchAlbum class] fromJSONDictionary:responseObject error:&error];
        if (error) {
            if (completion) {
                completion(nil, error);
            }
        }
        else {
            if (completion) {
                completion(itunesSearchAlbum, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE");
    }];
}

- (void)getTracksForAlbumID:(NSString *)albumID completion:(SLItunesFetchResultsBlock)completion{
    [[self operationQueue] cancelAllOperations];
    
    NSDictionary *params = @{@"id": albumID, @"entity": @"song"};
    
    [self GET:@"lookup" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        ItunesSearchTracks *itunesSearchTracks = [MTLJSONAdapter modelOfClass:[ItunesSearchTracks class] fromJSONDictionary:responseObject error:&error];
        if (error) {
            if (completion) {
                completion(nil, error);
            }
        }
        else {
            if (completion) {
                completion(itunesSearchTracks, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE");
    }];
}

+ (void)filterAlbums:(ItunesSearchAlbum *)albumResult ByYear:(NSString *)filterYear {
    if ([filterYear isEqualToString:@"All"]) {
        return;
    }
    
    NSMutableArray *albumsByYear = [NSMutableArray new];
    for (ItunesAlbum *album in [albumResult getArtistAlbums]) {
        if ([album.releaseYear isEqualToString:filterYear]) {
             [albumsByYear addObject:album];
        }
    }
    
    albumResult.albumResults = albumsByYear;
}

@end
