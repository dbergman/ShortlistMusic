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
    NSError *error;
    ItunesSearchAlbum *itunesSearchAlbums = [MTLJSONAdapter modelOfClass:[ItunesSearchAlbum class] fromJSONDictionary:[self getJSONDictionaryFromBundle:@"ItunesAlbumSearchResults"] error:&error];
    
    XCTAssertNotNil(itunesSearchAlbums, @"Found Items");
}

- (void)testSearchArtistResponse {
    NSError *error;
    ItunesSearchArtist *itunesSearchArtist = [MTLJSONAdapter modelOfClass:[ItunesSearchArtist class] fromJSONDictionary:[self getJSONDictionaryFromBundle:@"ItunesArtistSearchResults"] error:&error];
    
    XCTAssertNotNil(itunesSearchArtist, @"Found Items");
}

- (void)testSearchTrackResponse {
    NSError *error;
    ItunesSearchTracks *itunesSearchTracks = [MTLJSONAdapter modelOfClass:[ItunesSearchTracks class] fromJSONDictionary:[self getJSONDictionaryFromBundle:@"ItunesTracksSearchResult"] error:&error];
    
    XCTAssertNotNil(itunesSearchTracks, @"Found Items");
}

- (NSDictionary *)getJSONDictionaryFromBundle:(NSString *)bundleName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"JSON"];
    NSData *content = [[NSData alloc] initWithContentsOfFile:filePath];
    
    return [NSJSONSerialization JSONObjectWithData:content options:kNilOptions error:nil];
}

@end
