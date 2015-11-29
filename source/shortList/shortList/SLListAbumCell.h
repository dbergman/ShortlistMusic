//
//  SLListAbumCell.h
//  shortList
//
//  Created by Dustin Bergman on 7/7/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLShortListAlbum;

@interface SLListAbumCell : UITableViewCell

- (void)configureCell:(SLShortListAlbum *)album;

@end
