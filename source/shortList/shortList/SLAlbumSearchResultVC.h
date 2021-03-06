//
//  SLAlbumSearchResultTableVC.h
//  shortList
//
//  Created by Dustin Bergman on 5/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLBaseVC.h"

@class SLShortlist;

@interface SLAlbumSearchResultVC : SLBaseVC

- (instancetype)initWithArtistName:(NSString *)artistName Albums:(NSArray *)albums;
- (instancetype)initWithShortList:(SLShortlist *)shortList ArtistName:(NSString *)artistName Albums:(NSArray *)albums;

@end
