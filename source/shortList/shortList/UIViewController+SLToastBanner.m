//
//  UIViewController+SLToastBanner.m
//  shortList
//
//  Created by Dustin Bergman on 9/5/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+SLToastBanner.h"
#import "SLStyle.h"
#import "UIView+Toast.h"

@implementation UIViewController (SLToastBanner)

- (void)sl_showToastForAction:(NSString *)toastAction message:(NSString *)toastMessage toastType:(SLToastMessageType)toastMessageType completion:(dispatch_block_t)completion {
    
    CSToastStyle *style = [self getOptionsForAction:toastAction message:toastMessage type:toastMessageType];
    
    [self.navigationController.view makeToast:toastMessage duration:2.0 position:CSToastPositionTop title:toastAction image:nil style:style completion:^(BOOL didTap) {
            if (completion) {
                completion();
            }
    }];
}

- (CSToastStyle *)getOptionsForAction:(NSString *)actionText message:(NSString *)message type:(SLToastMessageType)toastMessageType  {
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
    
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageFont = [SLStyle polarisFontWithSize:FontSizes.xSmall];
    style.messageColor = [UIColor blackColor];
    style.titleColor = [UIColor blackColor];
    style.titleFont = [SLStyle polarisFontWithSize:FontSizes.xLarge];
    style.messageAlignment = NSTextAlignmentCenter;
    style.titleAlignment = NSTextAlignmentCenter;
    style.backgroundColor = backGroundColor;
    style.horizontalPadding = 20.0;

    return style;
}

- (void)sl_standardToastUnableToCompleteRequest {
    [self sl_showToastForAction:NSLocalizedString(@"Failure", nil) message:NSLocalizedString(@"Unable to complete request.", nil) toastType:SLToastMessageFailure completion:nil];
}

@end
