//
//  SLLoginVC.h
//  shortList
//
//  Created by Dustin Bergman on 5/13/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "PFLogInViewController.h"
@class PFUser;

typedef void(^SLLoginCompletionBlock)(PFUser *user, BOOL isLoggedIn);

@interface SLLoginVC : PFLogInViewController

- (instancetype)initWithCompletion:(SLLoginCompletionBlock)completion;
+ (UILabel *)getTempLogo:(CGRect)parseLogoFrame;

@end
