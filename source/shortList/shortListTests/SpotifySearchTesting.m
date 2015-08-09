//
//  SpotifySearchTesting.m
//  shortList
//
//  Created by Dustin Bergman on 8/9/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SpotifyAlbums.h"
#import "SpotifyAlbum.h"

@interface SpotifySearchTesting : XCTestCase

@end

@implementation SpotifySearchTesting

- (void)testSpotifyDeepLinkURL {
    NSError *error;
    
    SpotifyAlbums *spotifyAlbums = [MTLJSONAdapter modelOfClass:[SpotifyAlbums class] fromJSONDictionary:[self getJSONDictionaryFromBundle:@"SpotifyAlbumResults"] error:&error];
    
    SpotifyAlbum *spotifyAlbum = spotifyAlbums.albumResults.firstObject;
    
    XCTAssert(spotifyAlbum.spotifyAlbumUrl, @"Should find Spotify deeplink Url");
}

- (NSDictionary *)getJSONDictionaryFromBundle:(NSString *)bundleName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"JSON"];
    NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
    
    return [NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil];
}

@end
