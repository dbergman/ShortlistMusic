//
//  SLAlbumsCell.h
//  shortList
//
//  Created by Dustin Bergman on 7/15/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLShortlist;

@interface SLAlbumsCollectionCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;

- (void)configShortListCollection:(SLShortlist *)shortList;

@end
