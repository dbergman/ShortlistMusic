//
//  SLUserSignUpVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/16/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLUserSignUpVC.h"
#import "SLLoginVC.h"

@interface SLUserSignUpVC () <PFSignUpViewControllerDelegate>

@end

@implementation SLUserSignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.signUpView.logo = [SLLoginVC getTempLogo:self.signUpView.logo.frame];
    self.delegate = self;
}

#pragma mark PFSignUpViewControllerDelegate
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(PFUI_NULLABLE NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    [self dismissViewControllerAnimated:YES completion:nil];  
}

@end
