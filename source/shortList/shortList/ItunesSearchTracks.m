//
//  ItunesSearchTracks.m
//  shortList
//
//  Created by Dustin Bergman on 4/28/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "ItunesSearchTracks.h"
#import "ItunesTrack.h"

@implementation ItunesSearchTracks

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"resultCount" : @"resultCount",
      @"tracks" : @"results"
      };
}

+ (NSValueTransformer *)tracksJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ItunesTrack.class];
}

- (NSArray *)getAlbumTracks {
    NSMutableArray *tracks = [NSMutableArray new];
    for (ItunesTrack *track in self.tracks) {
        if ([track.wrapperType isEqualToString:@"track"]) {
            [tracks addObject:track];
        }
    }
    
    return [NSArray arrayWithArray:tracks];
}

- (ItunesTrack *)getAlbumInfo {
    for (ItunesTrack *track in self.tracks) {
        if ([track.wrapperType isEqualToString:@"collection"]) {
            return track;
        }
    }
    
    return nil;
}

@end
