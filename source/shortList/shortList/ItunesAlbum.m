//
//  ItunesAlbum.m
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ItunesAlbum.h"

@implementation ItunesAlbum

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"wrapperType": @"wrapperType",
      @"amgArtistId": @"amgArtistId",
      @"artistId": @"artistId",
      @"artistName": @"artistName",
      @"artistViewUrl": @"artistViewUrl",
      @"artworkUrl100": @"artworkUrl100",
      @"artworkUrl60": @"artworkUrl60",
      @"collectionCensoredName": @"collectionCensoredName",
      @"collectionExplicitness": @"collectionExplicitness",
      @"collectionId": @"collectionId",
      @"collectionName": @"collectionName",
      @"collectionPrice": @"collectionPrice",
      @"collectionType": @"collectionType",
      @"collectionViewUrl": @"collectionViewUrl",
      @"copyright": @"copyright",
      @"country": @"country",
      @"primaryGenreName": @"primaryGenreName",
      @"releaseDate": @"releaseDate",
      @"trackCount": @"trackCount",
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

+ (NSValueTransformer *)artistIdJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            return [value stringValue];
        }
        
        return value;
    }];
}

+ (NSValueTransformer *)collectionIdJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            return [value stringValue];
        }
        
        return value;
    }];
}

@end
