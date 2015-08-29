//
//  UIViewController+Utilities.m
//  shortList
//
//  Created by Dustin Bergman on 8/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+Utilities.h"
#import "UIImage+ImageEffects.h"

@implementation UIViewController (Utilities)

- (CGFloat)getStatusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (CGFloat)getNavigationBarHeight {
    return self.navigationController.navigationBar.frame.size.height;
}

- (CGFloat)getNavigationBarStatusBarHeight {
    return [self getStatusBarHeight] + [self getNavigationBarHeight];
}

- (CGFloat)getTabBarHeight {
   return self.tabBarController.tabBar.frame.size.height;
}

- (CGFloat)getScreenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGFloat)getScreenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

- (UIImage *)getScreenShot {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    }
    else {
        UIGraphicsBeginImageContext(self.view.bounds.size);
    }
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShot;
}

- (UIImage *)getBlurredScreenShot {
   UIImage *screenShotBlurImage = [[self getScreenShot] applyBlurWithRadius:10 tintColor:[[UIColor blackColor]colorWithAlphaComponent:.3] saturationDeltaFactor:1.8 maskImage:nil];

    return screenShotBlurImage;
}

@end
