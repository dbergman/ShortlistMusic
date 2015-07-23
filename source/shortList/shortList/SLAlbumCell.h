//
//  SLAlbumCell.h
//  shortList
//
//  Created by Dustin Bergman on 7/20/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShortListAlbum;

@interface SLAlbumCell : UICollectionViewCell

- (void)configWithShortListAlbum:(ShortListAlbum *)albums;

@end
