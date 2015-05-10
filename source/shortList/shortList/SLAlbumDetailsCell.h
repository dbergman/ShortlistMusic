//
//  SLAlbumDetailsCell.h
//  shortList
//
//  Created by Dustin Bergman on 5/10/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItunesTrack;

@interface SLAlbumDetailsCell : UITableViewCell

-(void)configureAlbumDetailCell:(ItunesTrack *)itunesTrack;

@end
