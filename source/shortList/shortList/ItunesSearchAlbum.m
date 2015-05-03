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

-(NSArray *)getArtistAlbums {
    NSMutableArray *albums = [NSMutableArray new];
    [self.albumResults enumerateObjectsUsingBlock:^(ItunesAlbum *album, NSUInteger idx, BOOL *stop) {
        if ([album.wrapperType isEqualToString:@"collection"]) {
            [albums addObject:album];
        }
    }];
    
    return [NSArray arrayWithArray:albums];
}

@end
