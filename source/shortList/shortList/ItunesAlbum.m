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
      @"wrapperType": @"wrapperType"
    };
}

@end
