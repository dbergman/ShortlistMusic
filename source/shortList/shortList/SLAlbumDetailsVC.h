//
//  SLAlbumDetailsVC.h
//  shortList
//
//  Created by Dustin Bergman on 5/3/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLBaseVC.h"
@class ItunesTrack;

@interface SLAlbumDetailsVC : SLBaseVC

- (instancetype)initWithAlbumName:(ItunesTrack *)albumDetails Tracks:(NSArray *)tracks;

@end
