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
      @"wrapperType": @"wrapperType"
    };
}

@end

