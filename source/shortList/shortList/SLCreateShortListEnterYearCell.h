//
//  SLCreateShortListEnterYearCell.h
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Shortlist;

typedef void(^SLCreateYearAction)(NSString *shortListYear);

@interface SLCreateShortListEnterYearCell : UITableViewCell

@property (nonatomic, copy) SLCreateYearAction createYearAction;

- (void)hidePickerCell:(BOOL)clearResult;
- (void)configYearCell:(Shortlist *)shortList;

@end
