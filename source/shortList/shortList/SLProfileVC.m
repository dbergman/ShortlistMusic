//
//  SLProfileVC.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLProfileVC.h"
#import "UIViewController+SLLoginGate.h"
#import <BlocksKit+UIKit.h>
#import <Parse/Parse.h>

@interface SLProfileVC ()

@end

@implementation SLProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"Profile", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupRightBarButton];
}

- (void)setupRightBarButton {
    ([PFUser currentUser]) ? [self showLogoutRightBarButton] : [self showLoginRightBarButton];
}

- (void)showLoginRightBarButton {
    __weak typeof(self) weakSelf = self;
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] bk_initWithTitle:NSLocalizedString(@"Login", nil) style:UIBarButtonItemStylePlain handler:^(id sender) {
        [weakSelf showLoginGateWithCompletion:^{
            if ([PFUser currentUser]) {
                [weakSelf showLogoutRightBarButton];
            }
        }];
    }];
    
    weakSelf.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)showLogoutRightBarButton {
    __weak typeof(self) weakSelf = self;
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] bk_initWithTitle:NSLocalizedString(@"Logout", nil) style:UIBarButtonItemStylePlain handler:^(id sender) {
        if ([PFUser currentUser]) {
            [PFUser logOut];
            [weakSelf showLoginRightBarButton];
        }
    }];
    
    weakSelf.navigationItem.rightBarButtonItem = rightBarButton;
}

@end
