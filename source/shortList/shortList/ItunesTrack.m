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
      @"artworkUrl600" : @"artworkUrl100",
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
      @"wrapperType" : @"wrapperType",
      @"releaseYear" : @"releaseDate",
      @"trackDuration" : @"trackTimeMillis"
    };
}

+ (NSValueTransformer *)trackDurationJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *duration, BOOL *success, NSError *__autoreleasing *error) {
        int totalSeconds = [duration floatValue] / 1000;
        int min = totalSeconds / 60;
        int sec = totalSeconds % 60;
        
        NSString *minutes = [NSString stringWithFormat:@"%i", min];
        NSString *seconds = [NSString stringWithFormat:@"%i", sec];
        
        if([seconds length] < 2) {
            seconds = [NSString stringWithFormat:@"0%@", seconds];
        }
        
        return [NSString stringWithFormat:@"%@:%@", minutes ,seconds];
    }];
}

+ (NSValueTransformer *)releaseYearJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([(NSString *)value length] > 3) {
            return [(NSString *)value substringToIndex:4];
        }
        return nil;
    }];
}

+ (NSValueTransformer *)artworkUrl600JSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *url, BOOL *success, NSError *__autoreleasing *error) {
        return [url stringByReplacingOccurrencesOfString:@"100x100" withString:@"600x600"];
    }];
}




@end

