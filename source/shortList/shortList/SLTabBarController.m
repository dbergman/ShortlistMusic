//
//  SLTabBarController.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLTabBarController.h"
#import "SLStyle.h"

@interface SLTabBarController ()

@property (nonatomic, strong) UIView *topBarView;

@end

@implementation SLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topBarView = [UIView new];
    self.topBarView.backgroundColor = [UIColor sl_Red];
    self.topBarView.frame = CGRectMake(0.0, 0.0, self.tabBar.frame.size.width, 1.0);
    [self.tabBar addSubview:self.topBarView];
}

@end
