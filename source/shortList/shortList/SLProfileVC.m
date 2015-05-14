//
//  SLProfileVC.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLProfileVC.h"
#import "UIViewController+SLLoginGate.h"

@interface SLProfileVC ()

@end

@implementation SLProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"Profile", nil)];
    
    [self showLoginGateWithCompletion:^{
        NSLog(@"SLProfileVC LOG");
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

@end
