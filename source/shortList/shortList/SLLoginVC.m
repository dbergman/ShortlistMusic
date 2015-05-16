//
//  SLLoginVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/13/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLLoginVC.h"
#import "SLStyle.h"

@implementation SLLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.logInView.logo = [SLLoginVC getTempLogo:self.logInView.logo.frame];
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
