//
//  SLListsVC.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLListsVC.h"
#import "ItunesSearchAPIController.h"
#import "SLStyle.h"
#import "SLListAlbumsVC.h"
#import "SLCreateShortListVC.h"
#import <BlocksKit+UIKit.h>

@interface SLListsVC () <SLCreateShortListDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SLCreateShortListVC *createShortListVC;
@property (nonatomic, strong) NSArray *createSLVerticalConstraints;

@end

@implementation SLListsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"ShortLists", nil)];
    
    [self createNewShortListView];
    
    __weak typeof(self) weakSelf = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemSearch handler:^(id sender) {
        [weakSelf.navigationController pushViewController:[SLListAlbumsVC new] animated:YES];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCompose handler:^(id sender) {
        [weakSelf showCreateNewShortListView];
    }];
}

- (void)createNewShortListView {
    self.createShortListVC = [SLCreateShortListVC new];
    self.createShortListVC.delegate = self;
    [self.createShortListVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.createShortListVC.view];
    
    NSDictionary *views = @{@"createShortListVC":self.createShortListVC.view};
    NSDictionary *metrics = @{@"topMargin":@(self.view.frame.size.height), @"viewWidth":@(self.view.frame.size.width * .8), @"viewHeight":@(kSLCreateShortListCellCount * kSLCreateShortListCellHeight), @"sideMargin":@((self.view.frame.size.width * .2)/2.0)};
    
    self.createSLVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[createShortListVC(viewHeight)]" options:0 metrics:metrics views:views];
    
    [self.view addConstraints:self.createSLVerticalConstraints];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sideMargin-[createShortListVC(viewWidth)]-sideMargin-|" options:0 metrics:metrics views:views]];
    
    [self.view updateConstraints];
    }

- (void)showCreateNewShortListView {
    NSLayoutConstraint *topMarginConstraint = [self.createSLVerticalConstraints firstObject];
    topMarginConstraint.constant = 100.0;
    [self.view addConstraints:self.createSLVerticalConstraints];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.2 animations:^{
        [weakSelf.view layoutIfNeeded];
    }];
    
    [self.createShortListVC setCancelButtonAction:^{
        topMarginConstraint.constant = weakSelf.view.frame.size.height;
        
        [weakSelf.view addConstraints:weakSelf.createSLVerticalConstraints];
        [UIView animateWithDuration:.2 animations:^{
            [weakSelf.view layoutIfNeeded];
        }];
    }];
}

#pragma mark SLCreateShortListDelegate
- (void)createShortList:(SLCreateShortListVC *)viewController willDisplayPickerWithHeight:(CGFloat)pickerHeight {
    NSLayoutConstraint *createSLHeightConstraint = self.createSLVerticalConstraints[1];
    createSLHeightConstraint.constant = createSLHeightConstraint.constant + (pickerHeight - kSLCreateShortListCellHeight);
    
    [self.view addConstraints:self.createSLVerticalConstraints];
    
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
