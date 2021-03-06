//
//  SLAlbumDetailsVC.h
//  shortList
//
//  Created by Dustin Bergman on 5/3/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLBaseVC.h"
@class ItunesTrack;
@class SLShortlist;

@interface SLAlbumDetailsVC : SLBaseVC

- (instancetype)initWithShortList:(SLShortlist *)shortList albumId:(NSString *)albumCollectionId;

@end
