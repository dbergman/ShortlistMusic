//
//  SLBaseVC.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLBaseVC.h"
#import "SLStyle.h"

@interface SLBaseVC ()
@end

@implementation SLBaseVC

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self init];
}

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    return [self init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setTitle:(NSString *)vcTitle {
    UILabel *artistTitleLabel = (UILabel *)self.navigationItem.titleView;
    artistTitleLabel = [UILabel new];
    artistTitleLabel.numberOfLines = 2;
    artistTitleLabel.textAlignment = NSTextAlignmentCenter;
    artistTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    artistTitleLabel.text = vcTitle;
    artistTitleLabel.textColor = [UIColor whiteColor];
    artistTitleLabel.font = [SLStyle polarisFontWithSize:FontSizes.xLarge];
    [artistTitleLabel sizeToFit];
    
    CGRect frame = artistTitleLabel.frame;
    frame.size.height = CGRectGetHeight(self.navigationController.navigationBar.frame);
    artistTitleLabel.frame = frame;
    self.navigationItem.titleView = artistTitleLabel;
}

@end
