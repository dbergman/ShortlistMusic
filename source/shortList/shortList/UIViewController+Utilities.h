//
//  UIViewController+Utilities.h
//  shortList
//
//  Created by Dustin Bergman on 8/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Utilities)

- (CGFloat)getStatusBarHeight;
- (CGFloat)getNavigationBarHeight;
- (CGFloat)getNavigationBarStatusBarHeight;
- (CGFloat)getTabBarHeight;

- (CGFloat)getScreenWidth;
- (CGFloat)getScreenHeight;

- (UIImage *)getScreenShot;

@end
