//
//  UIViewController+SLLoginGate.m
//  shortList
//
//  Created by Dustin Bergman on 5/13/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+SLLoginGate.h"
#import "SLLoginVC.h"
#import <Parse/Parse.h>

@implementation UIViewController (SLLoginGate)

- (void)showLoginGateWithCompletion:(dispatch_block_t)completion {
    if (![PFUser currentUser]) {
        // Customize the Log In View Controller
        SLLoginVC *loginVC = [[SLLoginVC alloc] init];
        loginVC.delegate = self;
        loginVC.facebookPermissions = @[@"friends_about_me"];
        loginVC.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton;
        
//        // Customize the Sign Up View Controller
//        MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
//        signUpViewController.delegate = self;
//        signUpViewController.fields = PFSignUpFieldsDefault | PFSignUpFieldsAdditional;
//        logInViewController.signUpController = signUpViewController;
        
        // Present Log In View Controller
        [self presentViewController:loginVC animated:YES completion:NULL];
    }
}

@end
