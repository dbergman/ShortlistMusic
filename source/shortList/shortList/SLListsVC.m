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
#import "SLShortlist.h"
#import <Parse/Parse.h>
#import "SLAlbumsCollectionCell.h"
#import "shortList-Swift.h"
#import "SLAlbumsCollectionCell.h"
#import "UIViewController+Utilities.h"
#import "UIImage+ImageEffects.h"
#import "UIViewController+SLToastBanner.h"

static const CGFloat SLTableViewHeaderMessageheight = 50.0;

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
            ([PFUser currentUser]) ? [weakSelf showCreateShortListView:nil]:[weakSelf showLoginGate];
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
            if (shortlists.count == 0) {
                [weakSelf addTableViewHeaderMessage:YES];
                weakSelf.shortLists = nil;
            }
            else {
                weakSelf.tableView.tableHeaderView = nil;
                weakSelf.shortLists = shortlists;
            }
            
            [weakSelf.tableView reloadData];
        }];
    }
    else {
        [self addTableViewHeaderMessage:NO];
        self.shortLists = nil;
        [weakSelf.tableView reloadData];
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
    
    SLShortlist *shortList = (SLShortlist *)self.shortLists[indexPath.row];
    [cell configShortListCollection:shortList];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shortListCellSelected:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    cell.tag = indexPath.row;
    [cell addGestureRecognizer:tapGestureRecognizer];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    __block SLShortlist *sl = self.shortLists[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SLParseController removeShortList:sl completion:^(NSArray * shortlists) {
            weakSelf.shortLists = shortlists;
    
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    [weakSelf sl_showToastForAction:NSLocalizedString(@"Removed", nil) message:sl.shortListName toastType:SLToastMessageSuccess completion:nil];
                }];
                
                [tableView beginUpdates];
                 [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
                
                [CATransaction commit];
        }];
    }
}

#pragma mark GestureRecognizers
- (void)shortListCellSelected:(UIGestureRecognizer *)gestureRecognizer {
    SLAlbumsCollectionCell *cell = (SLAlbumsCollectionCell *)[gestureRecognizer view];
    SLShortlist *shortList = self.shortLists[cell.tag];
    [self.navigationController pushViewController:[[SLListAlbumsVC alloc] initWithShortList:shortList] animated:YES];
}

- (void)addTableViewHeaderMessage:(BOOL)loggedIn {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SLTableViewHeaderMessageheight)];
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.numberOfLines = 0;
    messageLabel.font = [SLStyle polarisFontWithSize:FontSizes.large];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = (loggedIn) ? NSLocalizedString(@"You do not have any ShortLists at the moment", nil) :  NSLocalizedString(@"Log in to add Shortlists", nil);
    [messageLabel sizeToFit];

    CGRect frame = messageLabel.frame;
    frame.origin.y = MarginSizes.medium;
    frame.origin.x = (self.view.frame.size.width/2.0) - frame.size.width/2.0;
    messageLabel.frame = frame;

    [headerView addSubview:messageLabel];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)createNewShortListView {
    __weak typeof(self) weakSelf = self;
    self.createShortListVC = [[SLCreateShortListVC alloc] initWithCompletion:^(SLShortlist *shortlist, BOOL newShortlist) {
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
    
    self.createShortListVC.view.layer.borderColor = [UIColor sl_Red].CGColor;
    self.createShortListVC.view.layer.borderWidth = 2.0;
    self.createShortListVC.view.layer.cornerRadius = 8.0;
    self.createShortListVC.view.clipsToBounds = YES;
    
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

- (void)showCreateShortListView:(SLShortlist *)shortList {
    [self addBlurBackground];
    
    (shortList) ? [self.createShortListVC updateShortList:shortList] : [self.createShortListVC newShortList];
    [self.createShortListVC.tableView reloadData];
    
    NSLayoutConstraint *topMarginConstraint = [self.createSLVerticalConstraints firstObject];
    topMarginConstraint.constant = 100.0;
    [self.view addConstraints:self.createSLVerticalConstraints];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:9 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
        self.blurBackgroundView.alpha = 1.0;
    } completion:nil];
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
    UIImage *screenShotImage = [self getBlurredScreenShot];
    
    self.blurBackgroundView = [[UIImageView alloc] initWithImage:screenShotImage];
    self.blurBackgroundView.userInteractionEnabled = YES;
    [self.view insertSubview:self.blurBackgroundView atIndex:1];
    self.blurBackgroundView.alpha = 0;
}

- (void)removeBlurBackground {
    [self.blurBackgroundView removeFromSuperview];
}

@end
