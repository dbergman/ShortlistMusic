//
//  ItunesSearchAlbum.m
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ItunesSearchAlbum.h"
#import "ItunesAlbum.h"

@implementation ItunesSearchAlbum


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"resultCount": @"resultCount",
      @"albumResults": @"results"
      };
}

+ (NSValueTransformer *)albumResultsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ItunesAlbum.class];
}

@end
