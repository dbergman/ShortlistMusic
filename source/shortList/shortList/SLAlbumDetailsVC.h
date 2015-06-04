//
//  SLAlbumDetailsVC.h
//  shortList
//
//  Created by Dustin Bergman on 5/3/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLBaseVC.h"
@class ItunesTrack;
@class Shortlist;

@interface SLAlbumDetailsVC : SLBaseVC

- (instancetype)initWithAlbumDetails:(ItunesTrack *)albumDetails Tracks:(NSArray *)tracks;
- (instancetype)initWithShortList:(Shortlist *)shortList albumDetails:(ItunesTrack *)albumDetails tracks:(NSArray *)tracks;

@end
