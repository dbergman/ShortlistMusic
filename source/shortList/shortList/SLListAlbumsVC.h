//
//  SLListAlbumsVC.h
//  shortList
//
//  Created by Dustin Bergman on 5/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLBaseVC.h"

@class SLShortlist;

@interface SLListAlbumsVC : SLBaseVC

- (nonnull instancetype)initWithShortList:(nonnull SLShortlist *)shortList;
@end
