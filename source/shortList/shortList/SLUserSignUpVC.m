//
//  SLUserSignUpVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/16/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLUserSignUpVC.h"
#import "SLLoginVC.h"

@implementation SLUserSignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.signUpView.logo = [SLLoginVC getTempLogo:self.signUpView.logo.frame];
}

@end
