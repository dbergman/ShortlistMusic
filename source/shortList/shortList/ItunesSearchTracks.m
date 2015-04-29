//
//  ItunesSearchTracks.m
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ItunesSearchTracks.h"

@implementation ItunesSearchTracks

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"resultCount": @"resultCount",
      @"tracks": @"results"
      };
}

@end
