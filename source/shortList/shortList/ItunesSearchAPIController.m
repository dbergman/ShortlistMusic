//
//  ItunesSearchAPIController.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ItunesSearchAPIController.h"

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

-(void)getSearchResultsWithBlock:(NSString *)artist success:(void (^)(NSMutableArray* results))successBlock failure:(void (^)(NSError* error))failureBlock {
    [[self operationQueue] cancelAllOperations];
    
    NSDictionary *params = @{@"term": artist, @"media": @"music", @"entity": @"musicArtist", @"attribute": @"artistTerm", @"limit": @"200"};
    
    [self GET:@"search" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *searchResults =  [(NSDictionary*)responseObject objectForKey:@"results"];
        successBlock(searchResults);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
        NSLog(@" getSearchResultsWithBlock:: %@",error);
    }];
}

- (void)getAlbumsForArtist:(NSNumber *) artistId success:(void (^)(NSMutableArray* results))successBlock failure:(void (^)(NSError* error))failureBlock {
    [[self operationQueue] cancelAllOperations];
    
    NSDictionary *params = @{@"id": artistId, @"media": @"music", @"entity": @"album", @"limit": @"200"};
    
    [self GET:@"lookup" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *searchResults =  [(NSDictionary*)responseObject objectForKey:@"results"];
        successBlock(searchResults);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
        NSLog(@" getSearchResultsWithBlock:: %@",error);
    }];
}

- (void)getTracksForAlbumID:(NSString *)albumID success:(void (^)(NSMutableArray* results))successBlock failure:(void (^)(NSError* error))failureBlock {
    [[self operationQueue] cancelAllOperations];
    
    NSDictionary *params = @{@"id": albumID, @"entity": @"song"};
    
    [self GET:@"lookup" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *searchResults =  [(NSDictionary*)responseObject objectForKey:@"results"];
        successBlock(searchResults);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(error);
        NSLog(@" getSearchResultsWithBlock:: %@",error);
    }];
}

@end
