//
//  SLBaseVC.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLBaseVC.h"
#import "SLStyle.h"
#import <URBNConvenience/UIView+URBNLayout.h>

@interface SLBaseVC ()

@end

@implementation SLBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIImageView *backGroundImageView = [UIImageView new];
    backGroundImageView.image = [UIImage imageNamed:@"BackGround"];

    backGroundImageView.backgroundColor = [UIColor orangeColor];
    
    backGroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [backGroundImageView urbn_wrapInContainerViewWithView:self.view];
}


@end
