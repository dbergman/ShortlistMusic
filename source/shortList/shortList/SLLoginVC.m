//
//  SLLoginVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/13/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLLoginVC.h"
#import "SLStyle.h"
#import "UIViewController+SLToastBanner.h"
#import <Parse/Parse.h>

@interface SLLoginVC () <PFLogInViewControllerDelegate>

@property (nonatomic, copy) SLLoginCompletionBlock completion;

@end

@implementation SLLoginVC

- (instancetype)initWithCompletion:(SLLoginCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.logInView.logo = [SLLoginVC getTempLogo:self.logInView.logo.frame];
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PFUser currentUser]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark PFLogInViewControllerDelegate
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    __weak typeof(self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf callBackWithUser:user isLoggedIn:YES];
    }];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(PFUI_NULLABLE NSError *)error {
    [self sl_showToastForAction:NSLocalizedString(@"Login Failed", nil) message:NSLocalizedString(@"Invalid ID or password.", nil) toastType:SLToastMessageFailure completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)callBackWithUser:(PFUser *)user isLoggedIn:(BOOL)isLoggedIn {
    if (self.completion) {
        self.completion(user, isLoggedIn);
    }
}

+ (UILabel *)getTempLogo:(CGRect)parseLogoFrame {
    UILabel *logoLabel = [UILabel new];
    logoLabel.frame = parseLogoFrame;
    logoLabel.backgroundColor = [UIColor clearColor];
    logoLabel.textColor = [UIColor sl_Red];
    logoLabel.font = [SLStyle polarisFontWithSize:28.0];
    logoLabel.text = @"ShortList Music";
    
    return logoLabel;
}

@end
