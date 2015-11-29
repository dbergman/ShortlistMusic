//
//  SLCreateShortListEnterName.h
//  shortList
//
//  Created by Dustin Bergman on 5/17/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLShortlist;

typedef void(^SLCreateNameAction)(NSString *shortListName);
typedef void(^SLTCreatingShortListName)();

@interface SLCreateShortListEnterNameCell : UITableViewCell

@property (nonatomic, copy) SLCreateNameAction createNameAction;
@property (nonatomic, copy) SLTCreatingShortListName creatingShortListNameAction;

- (void)clearShortListName;
- (void)configShortListNameCell:(SLShortlist *)shortList;

@end
