//
//  SLCreateShortListTitleCell.h
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Shortlist;

@interface SLCreateShortListTitleCell : UITableViewCell

@property (nonatomic, copy) dispatch_block_t cleanUpSLBlock;
@property (nonatomic, copy) dispatch_block_t createSLBlock;
@property (nonatomic, copy) dispatch_block_t updateSLBlock;

- (void)configTitle:(Shortlist *)shortList;

@end
