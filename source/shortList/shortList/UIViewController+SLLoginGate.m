//
//  UIViewController+SLLoginGate.m
//  shortList
//
//  Created by Dustin Bergman on 5/13/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+SLLoginGate.h"
#import "SLLoginVC.h"
#import "SLUserSignUpVC.h"
#import "PFLogInViewController.h"
#import <Parse/Parse.h>

@implementation UIViewController (SLLoginGate)

- (void)showLoginGate {
    __weak typeof(self)weakSelf = self;
    
    if (![PFUser currentUser]) {
        SLLoginVC *loginVC = [[SLLoginVC alloc] initWithCompletion:^(PFUser *user, BOOL isLoggedIn) {
            if (isLoggedIn) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        loginVC.facebookPermissions = @[@"user_about_me"];
        loginVC.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;

        SLUserSignUpVC *userSignUpVC = [[SLUserSignUpVC alloc] init];
        userSignUpVC.fields = PFSignUpFieldsDefault;
        loginVC.signUpController = userSignUpVC;

        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

@end
