//
//  ItunesTrack.m
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ItunesTrack.h"

@implementation ItunesTrack

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"artistId" : @"artistId",
      @"artistName" : @"artistName",
      @"artistViewUrl" : @"artistViewUrl",
      @"artworkUrl400" : @"artworkUrl100",
      @"artworkUrl100" : @"artworkUrl100",
      @"artworkUrl30" : @"artworkUrl30",
      @"artworkUrl60" : @"artworkUrl60",
      @"collectionCensoredName" : @"collectionCensoredName",
      @"collectionExplicitness" : @"collectionExplicitness",
      @"collectionId" : @"collectionId",
      @"collectionName" : @"collectionName",
      @"collectionPrice" : @"collectionPrice",
      @"collectionViewUrl" : @"collectionViewUrl",
      @"country" : @"country",
      @"currency" : @"currency",
      @"discCount" : @"discCount",
      @"discNumber" : @"discNumber",
      @"kind" : @"kind",
      @"previewUrl" : @"previewUrl",
      @"primaryGenreName" : @"primaryGenreName",
      @"radioStationUrl" : @"radioStationUrl",
      @"releaseDate" : @"releaseDate",
      @"trackCensoredName" : @"trackCensoredName",
      @"trackCount" : @"trackCount",
      @"trackExplicitness" : @"trackExplicitness",
      @"trackId" : @"trackId",
      @"trackName" : @"trackName",
      @"trackNumber" : @"trackNumber",
      @"trackPrice" : @"trackPrice",
      @"trackTimeMillis" : @"trackTimeMillis",
      @"trackViewUrl" : @"trackViewUrl",
      @"wrapperType": @"wrapperType",
      @"releaseYear": @"releaseDate"
    };
}

+ (NSValueTransformer *)releaseYearJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([(NSString *)value length] > 3) {
            return [(NSString *)value substringToIndex:4];
        }
        return nil;
    }];
}

+ (NSValueTransformer *)artworkUrl400JSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *url, BOOL *success, NSError *__autoreleasing *error) {
        return [url stringByReplacingOccurrencesOfString:@"100x100-75.jpg" withString:@"400x400-75.jpg"];
    }];
}

@end

