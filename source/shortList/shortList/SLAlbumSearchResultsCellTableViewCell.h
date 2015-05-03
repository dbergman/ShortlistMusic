//
//  SLAlbumSearchResultsCellTableViewCell.h
//  shortList
//
//  Created by Dustin Bergman on 5/3/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItunesAlbum;

@interface SLAlbumSearchResultsCellTableViewCell : UITableViewCell

- (void)configCellWithItunesAlbum:(ItunesAlbum *)album;

@end
