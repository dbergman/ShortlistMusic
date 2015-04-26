//
//  SLStyle.h
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+SLStyle.h"

#pragma mark - Structs
extern const struct MarginSizes {
    CGFloat xSmall;
    CGFloat small;
    CGFloat medium;
    CGFloat large;
    CGFloat xLarge;
    CGFloat xxLarge;
} MarginSizes;

#pragma mark - Enums
extern const struct FontSizes {
    CGFloat xSmall;
    CGFloat small;
    CGFloat medium;
    CGFloat large;
    CGFloat xLarge;
} FontSizes;

@interface SLStyle : NSObject

@end
