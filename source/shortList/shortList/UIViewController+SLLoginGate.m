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
    if (![PFUser currentUser]) {
        SLLoginVC *loginVC = [[SLLoginVC alloc] init];
        loginVC.facebookPermissions = @[@"user_about_me"];
        loginVC.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;

        SLUserSignUpVC *userSignUpVC = [[SLUserSignUpVC alloc] init];
        userSignUpVC.fields = PFSignUpFieldsDefault;
        loginVC.signUpController = userSignUpVC;

        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

@end
