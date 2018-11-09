//
//  ItunesArtist.m
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ItunesArtist.h"

@implementation ItunesArtist

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"wrapperType": @"wrapperType",
      @"artistType": @"artistType",
      @"artistName": @"artistName",
      @"artistLinkUrl": @"artistLinkUrl",
      @"artistId": @"artistId",
      @"primaryGenreName": @"primaryGenreName",
      @"primaryGenreId": @"primaryGenreId" 
      };
}

+ (NSValueTransformer *)artistIdJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            return [value stringValue];
        }
        
        return value;
    }];
}

@end
