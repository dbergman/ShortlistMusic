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
#import "Shortlist.h"
#import <Parse/Parse.h>
#import "SLAlbumsCollectionCell.h"
#import "shortList-Swift.h"
#import "SLAlbumsCollectionCell.h"
#import "FXBlurView.h"
#import "UIViewController+Utilities.h"

@interface SLListsVC () <SLCreateShortListDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *shortLists;
@property (nonatomic, strong) SLCreateShortListVC *createShortListVC;
@property (nonatomic, strong) NSArray *createSLVerticalConstraints;
@property (nonatomic, strong) UIImageView *blurBackgroundView;

@end

@implementation SLListsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:NSLocalizedString(@"ShortLists", nil)];
    self.view.backgroundColor = [UIColor blackColor];
    
    __weak typeof(self) weakSelf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender) {
        [weakSelf showLoginGateWithCompletion:^{
            if ([PFUser currentUser]) {
                [weakSelf showCreateShortListView:nil];
            }
        }];
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];

    [self createNewShortListView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    if ([PFUser currentUser]) {
        [SLParseController getUsersShortLists:^(NSArray *shortlists) {
            weakSelf.shortLists = shortlists;
            [weakSelf.tableView reloadData];
        }];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.shortLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    SLAlbumsCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SLAlbumsCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Shortlist *shortList = (Shortlist *)self.shortLists[indexPath.row];
    [cell configShortListCollection:shortList];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shortListCellSelected:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    cell.tag = indexPath.row;
    [cell addGestureRecognizer:tapGestureRecognizer];
    
    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shortListCellUpdate:)];
    longGestureRecognizer.minimumPressDuration = .5f;
    [cell addGestureRecognizer:longGestureRecognizer];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SLParseController removeShortList:self.shortLists[indexPath.row] completion:^(NSArray * shortlists) {
            weakSelf.shortLists = shortlists;
            [weakSelf.tableView reloadData];
        }];
    }
}

#pragma mark GestureRecognizers
- (void)shortListCellSelected:(UIGestureRecognizer *)gestureRecognizer {
    SLAlbumsCollectionCell *cell = (SLAlbumsCollectionCell *)[gestureRecognizer view];
    Shortlist *shortList = self.shortLists[cell.tag];
    [self.navigationController pushViewController:[[SLListAlbumsVC alloc] initWithShortList:shortList] animated:YES];
}

- (void)shortListCellUpdate:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        SLAlbumsCollectionCell *cell = (SLAlbumsCollectionCell *)[gestureRecognizer view];
        Shortlist *shortList = self.shortLists[cell.tag];
        [self showCreateShortListView:shortList];
    }
}

- (void)createNewShortListView {
    __weak typeof(self) weakSelf = self;
    self.createShortListVC = [[SLCreateShortListVC alloc] initWithCompletion:^(Shortlist *shortlist, BOOL newShortlist){
        NSLayoutConstraint *topMarginConstraint = [self.createSLVerticalConstraints firstObject];
        topMarginConstraint.constant = weakSelf.view.frame.size.height;
        NSLayoutConstraint *createSLHeightConstraint = weakSelf.createSLVerticalConstraints[1];
        createSLHeightConstraint.constant = kSLCreateShortListCellCount * kSLCreateShortListCellHeight;
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        
        [SLParseController getUsersShortLists:^(NSArray *shortlists) {
            weakSelf.shortLists = shortlists;
            [weakSelf.tableView reloadData];
        }];
        
        [weakSelf.view addConstraints:weakSelf.createSLVerticalConstraints];
        [UIView animateWithDuration:.2 animations:^{
            [weakSelf.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [weakSelf removeBlurBackground];
            if (newShortlist) {
                SLListAlbumsVC *listAlbumsVC = [[SLListAlbumsVC alloc] initWithShortList:shortlist];
                [weakSelf.navigationController showViewController:listAlbumsVC sender:weakSelf];
            }
        }];
    }];
    
    self.createShortListVC.delegate = self;
    [self.createShortListVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.createShortListVC.view];
    
    NSDictionary *views = @{@"createShortListVC":self.createShortListVC.view};
    NSDictionary *metrics = @{@"topMargin":@(self.view.frame.size.height), @"viewWidth":@(self.view.frame.size.width * .9), @"viewHeight":@(kSLCreateShortListCellCount * kSLCreateShortListCellHeight), @"sideMargin":@((self.view.frame.size.width * .1)/2.0)};
    
    self.createSLVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[createShortListVC(viewHeight)]" options:0 metrics:metrics views:views];
    
    [self.view addConstraints:self.createSLVerticalConstraints];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sideMargin-[createShortListVC(viewWidth)]-sideMargin-|" options:0 metrics:metrics views:views]];
    
    [self.view updateConstraints];
}

- (void)showCreateShortListView:(Shortlist *)shortList {
    [self addBlurBackground];
    
    (shortList) ? [self.createShortListVC updateShortList:shortList] : [self.createShortListVC newShortList];
    [self.createShortListVC.tableView reloadData];
    
    NSLayoutConstraint *topMarginConstraint = [self.createSLVerticalConstraints firstObject];
    topMarginConstraint.constant = 100.0;
    [self.view addConstraints:self.createSLVerticalConstraints];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
        self.blurBackgroundView.alpha = 1.0;
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

#pragma mark Blurring Methods
- (void)addBlurBackground {
    self.blurBackgroundView = [[UIImageView alloc] initWithImage:[self getScreenShot]];
    self.blurBackgroundView.userInteractionEnabled = YES;
    [self.view insertSubview:self.blurBackgroundView atIndex:1];
    self.blurBackgroundView.alpha = 0;
    
    FXBlurView *shortListBlurView = [[FXBlurView alloc] init];
    shortListBlurView.frame = self.blurBackgroundView.bounds;
    shortListBlurView.tintColor = [UIColor blackColor];
    shortListBlurView.blurEnabled = YES;
    shortListBlurView.clipsToBounds = YES;
    shortListBlurView.blurRadius = 9;
    [self.blurBackgroundView addSubview:shortListBlurView];
}

- (void)removeBlurBackground {
    [self.blurBackgroundView removeFromSuperview];
}

@end
