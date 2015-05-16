//
//  SLLoginVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/13/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLLoginVC.h"
#import "SLStyle.h"

@interface SLLoginVC () <PFLogInViewControllerDelegate>

@end

@implementation SLLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.logInView.logo = [SLLoginVC getTempLogo:self.logInView.logo.frame];
    self.delegate = self;
}

#pragma mark PFLogInViewControllerDelegate
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(PFUI_NULLABLE NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (UILabel *)getTempLogo:(CGRect)parseLogoFrame {
    UILabel *logoLabel = [UILabel new];
    logoLabel.frame = parseLogoFrame;
    logoLabel.backgroundColor = [UIColor clearColor];
    logoLabel.textColor = [UIColor sl_Red];
    logoLabel.font = [UIFont boldSystemFontOfSize:28.0];
    logoLabel.text = @"ShortList Music";
    
    return logoLabel;
}

@end
