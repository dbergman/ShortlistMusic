//
//  UIViewController+SLToastBanner.m
//  shortList
//
//  Created by Dustin Bergman on 9/5/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+SLToastBanner.h"
#import <CRToast/CRToast.h>

@implementation UIViewController (SLToastBanner)

- (void)sl_showToast:(NSString *)toastMessage toastType:(SLToastMessageType)toastMessageType {
    [CRToastManager showNotificationWithOptions:[self getOptions:toastMessage] completionBlock:^{
        NSLog(@"Completed");
    }];
}

- (NSDictionary *)getOptions:(NSString *)message {
    NSDictionary *options = @{
                              kCRToastTextKey : message,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor greenColor],
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationTypeLinear),
                              kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypePush),
                              kCRToastNotificationTypeKey :@(CRToastTypeNavigationBar),
                              kCRToastTextColorKey : [UIColor blackColor]
                              };

    
    
    
    return options;
}

@end
