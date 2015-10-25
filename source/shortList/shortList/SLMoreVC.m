//
//  SLMoreVC.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLMoreVC.h"
#import "SLLoginCell.h"
#import <Parse/Parse.h>
#import "UIViewController+SLLoginGate.h"

@interface SLMoreVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SLMoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"More", nil)];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UITableView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *LoginCellIdentifier = @"LoginCell";
    
//    if (indexPath.section == 0) {
//        SLAlbumDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:AlbumDetailCellIdentifier];
//        if (cell == nil) {
//            cell = [[SLAlbumDetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlbumDetailCellIdentifier];
//        }
//        
//        return [self configureAlbumDetails:cell];
//    }
    
    static NSString *LoginCellIdentifier = @"LoginCell";
    
    SLLoginCell *cell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier];
    if (cell == nil) {
        cell = [[SLLoginCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoginCellIdentifier];
    }
    __weak typeof(self)weakSelf = self;
    [cell configLoginButton:([PFUser currentUser]) ?: NO loginButtonAction:^{
        (![PFUser currentUser]) ? [weakSelf showLoginGate] : [PFUser logOutInBackground];
        [cell updateButtonWithLoginStatus:([PFUser currentUser])];
    }];

    return cell;
}

@end
