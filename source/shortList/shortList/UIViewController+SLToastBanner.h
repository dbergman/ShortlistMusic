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

- (void)sl_showToast:(NSString *)toastMessage toastType:(SLToastMessageType)toastMessageType;

@end
