//
//  ItunesSearchArtist.m
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ItunesSearchArtist.h"
#import "ItunesArtist.h"

@implementation ItunesSearchArtist

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"resultCount": @"resultCount",
      @"artistResults": @"results"
    };
}

+ (NSValueTransformer *)artistResultsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ItunesArtist.class];
}

@end
