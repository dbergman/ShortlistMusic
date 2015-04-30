//
//  ItunesSearchTesting.m
//  shortList
//
//  Created by Dustin Bergman on 4/29/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ItunesSearchAlbum.h"
#import "ItunesSearchArtist.h"
#import "ItunesSearchTracks.h"

@interface ItunesSearchTesting : XCTestCase

@end

@implementation ItunesSearchTesting

- (void)testSearchAlbumsResponse {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ItunesAlbumSearchResults" ofType:@"JSON"];
    NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil];
    
    NSError *error;
    ItunesSearchAlbum *itunesSearchAlbums = [MTLJSONAdapter modelOfClass:[ItunesSearchAlbum class] fromJSONDictionary:jsonDictionary error:&error];
    
    XCTAssertNotNil(itunesSearchAlbums, @"Found Items");
}

- (void)testSearchArtistResponse {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ItunesArtistSearchResults" ofType:@"JSON"];
    NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil];
    
    NSError *error;
    ItunesSearchArtist *itunesSearchArtist = [MTLJSONAdapter modelOfClass:[ItunesSearchArtist class] fromJSONDictionary:jsonDictionary error:&error];
    
    XCTAssertNotNil(itunesSearchArtist, @"Found Items");
}

- (void)testSearchTrackResponse {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ItunesTracksSearchResult" ofType:@"JSON"];
    NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil];
    
    NSError *error;
    ItunesSearchTracks *itunesSearchTracks = [MTLJSONAdapter modelOfClass:[ItunesSearchTracks class] fromJSONDictionary:jsonDictionary error:&error];
    
    XCTAssertNotNil(itunesSearchTracks, @"Found Items");
}

@end
