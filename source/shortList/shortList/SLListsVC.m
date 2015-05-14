//
//  SLListsVC.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLListsVC.h"
#import "ItunesSearchAPIController.h"
#import "SLListAlbumsVC.h"
#import <BlocksKit+UIKit.h>

@interface SLListsVC ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SLListsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"ShortLists", nil)];
    
    __weak typeof(self) weakSelf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemSearch handler:^(id sender) {
        [weakSelf.navigationController pushViewController:[SLListAlbumsVC new] animated:YES];
    }];
}

@end
