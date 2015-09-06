//
//  UIViewController+SLToastBanner.h
//  shortList
//
//  Created by Dustin Bergman on 9/5/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SLToastMessageType) {
    SLToastMessageSuccess,
    SLToastMessageWarning,
    SLToastMessageFailure
};

@interface UIViewController (SLToastBanner)

- (void)sl_showToastForAction:(NSString *)toastAction message:(NSString *)toastMessage toastType:(SLToastMessageType)toastMessageType completion:(dispatch_block_t)completion;

@end
