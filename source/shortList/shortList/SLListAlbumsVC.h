//
//  SLListAlbumsVC.h
//  shortList
//
//  Created by Dustin Bergman on 5/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLBaseVC.h"

@class Shortlist;

@interface SLListAlbumsVC : SLBaseVC

- (instancetype)initWithShortList:(Shortlist *)shortList NS_DESIGNATED_INITIALIZER;

@end
