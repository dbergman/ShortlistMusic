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
#import "UIViewController+SLLoginGate.h"
#import "SLParseController.h"
#import "Shortlist.h"
#import <Parse/Parse.h>

@interface SLListsVC () <SLCreateShortListDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *shortLists;
@property (nonatomic, strong) SLCreateShortListVC *createShortListVC;
@property (nonatomic, strong) NSArray *createSLVerticalConstraints;

@end

@implementation SLListsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"ShortLists", nil)];
    
    __weak typeof(self) weakSelf = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemSearch handler:^(id sender) {
        [weakSelf.navigationController pushViewController:[SLListAlbumsVC new] animated:YES];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender) {
        [weakSelf showLoginGateWithCompletion:^{
            if ([PFUser currentUser]) {
                [weakSelf showCreateNewShortListView];
            }
        }];
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [SLParseController getUsersShortLists:^(NSArray *shortLists){
        weakSelf.shortLists = shortLists;
        [weakSelf.tableView reloadData];
    }];
    
    [self createNewShortListView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.shortLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Shortlist *shortList = (Shortlist *)self.shortLists[indexPath.row];
    cell.textLabel.text = shortList.shortListName;
    
    return cell;
}

- (void)createNewShortListView {
    __weak typeof(self) weakSelf = self;
    self.createShortListVC = [[SLCreateShortListVC alloc] initWithCompletion:^{
        NSLayoutConstraint *topMarginConstraint = [self.createSLVerticalConstraints firstObject];
        topMarginConstraint.constant = weakSelf.view.frame.size.height;
        NSLayoutConstraint *createSLHeightConstraint = weakSelf.createSLVerticalConstraints[1];
        createSLHeightConstraint.constant = kSLCreateShortListCellCount * kSLCreateShortListCellHeight;
        
        [weakSelf.view addConstraints:weakSelf.createSLVerticalConstraints];
        [UIView animateWithDuration:.2 animations:^{
            [weakSelf.view layoutIfNeeded];
            //[[self navigationController] setNavigationBarHidden:NO animated:YES];
        }];
    }];
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
    
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
        //[[self navigationController] setNavigationBarHidden:YES animated:YES];
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
