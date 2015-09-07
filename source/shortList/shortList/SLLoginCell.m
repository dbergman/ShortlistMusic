//
//  SLLoginCell.m
//  shortList
//
//  Created by Dustin Bergman on 9/6/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

#import "SLLoginCell.h"
#import "SLStyle.h"
#import <Parse/Parse.h>

@interface SLLoginCell ()

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, copy) SLLoginButtonCellAction loginAction;

@end

@implementation SLLoginCell

#pragma mark Initilization
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        
        self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
        [self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.loginButton.titleLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
        self.loginButton.backgroundColor = [UIColor greenColor];
        [self.loginButton addTarget:self action:@selector(loginButtonAction:)forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.loginButton];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:300.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0]];
    }
    
    return self;
}

- (void)configLoginButton:(BOOL)isloggedIn loginButtonAction:(SLLoginButtonCellAction)loginAction {
    self.loginAction = loginAction;
    [self updateButtonWithLoginStatus:isloggedIn];
}

- (void)updateButtonWithLoginStatus:(BOOL)isloggedIn {
    if (isloggedIn) {
        [self.loginButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
        [self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.loginButton.backgroundColor = [UIColor redColor];
    }
    else {
        [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
        [self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.loginButton.backgroundColor = [UIColor greenColor];
    }
}

- (void)loginButtonAction:(id)sender {
    if (self.loginAction) {
        self.loginAction();
    }
}

@end
