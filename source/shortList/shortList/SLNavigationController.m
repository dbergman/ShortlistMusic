//
//  SLNavigationController.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLNavigationController.h"
#import "SLStyle.h"

@interface SLNavigationController ()

@property (nonatomic, strong) UIView *bottomBarView;

@end

@implementation SLNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bottomBarView = [UIView new];
    self.bottomBarView.backgroundColor = [UIColor sl_Red];
    self.bottomBarView.frame = CGRectMake(0.0, CGRectGetMaxY(self.navigationBar.frame) - 1.0, self.navigationBar.frame.size.width, 1.0);
    [self.navigationBar addSubview:self.bottomBarView];
}

@end
