//
//  UIViewController+SLToastBanner.m
//  shortList
//
//  Created by Dustin Bergman on 9/5/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+SLToastBanner.h"
#import "SLStyle.h"
#import <CRToast/CRToast.h>

@implementation UIViewController (SLToastBanner)

- (void)sl_showToastForAction:(NSString *)toastAction message:(NSString *)toastMessage toastType:(SLToastMessageType)toastMessageType completion:(dispatch_block_t)completion {
    [CRToastManager showNotificationWithOptions:[self getOptionsForAction:toastAction message:toastMessage type:toastMessageType] completionBlock:^{
        if (completion) {
            completion();
        }
    }];
}

- (NSDictionary *)getOptionsForAction:(NSString *)actionText message:(NSString *)message type:(SLToastMessageType)toastMessageType  {
    UIColor *backGroundColor;
    if (toastMessageType == SLToastMessageSuccess) {
        backGroundColor = [UIColor sl_Green];
    }
    else if (toastMessageType == SLToastMessageWarning) {
        backGroundColor = [UIColor yellowColor];
    }
    else {
        backGroundColor = [UIColor redColor];
    }
    
    NSDictionary *options = @{
                              kCRToastTextKey : (actionText) ?: @"",
                              kCRToastTextColorKey : [UIColor blackColor],
                              kCRToastFontKey : [SLStyle polarisFontWithSize:FontSizes.large],
                              kCRToastSubtitleTextKey :(message) ?: @"",
                              kCRToastSubtitleTextColorKey : [UIColor blackColor],
                              kCRToastSubtitleFontKey : [SLStyle polarisFontWithSize:FontSizes.small],
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : backGroundColor,
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationTypeLinear),
                              kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypePush),
                              kCRToastNotificationTypeKey :@(CRToastTypeNavigationBar),
                              kCRToastTimeIntervalKey : @(1.5)
                              };
    return options;
}

@end
