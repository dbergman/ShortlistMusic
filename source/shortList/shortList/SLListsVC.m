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
#import "SLPreviewAlbumDetailsVC.h"
#import "SLShortListAlbum.h"
#import "SLAlbumCell.h"
#import "SLAlbumDetailsVC.h"
#import "SLNavigationController.h"

static NSString *const kShowedVersionUpdateMessage = @"showedVersionUpdateMessage";
static const CGFloat SLTableViewHeaderMessageHeight = 50.0;

@interface SLListsVC () <SLCreateShortListDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <SLShortlist *> *shortLists;
@property (nonatomic, strong) SLCreateShortListVC *createShortListVC;
@property (nonatomic, strong) NSArray *createSLVerticalConstraints;
@property (nonatomic, strong) UIImageView *blurBackgroundView;
@property (nonatomic, strong) SLShortlist *previewingShortlist;
@property (nonatomic, strong) SLShortListAlbum *previewingAlbum;

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"sortShortlists"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        SLSortOptionsVC *sortVC = [[SLSortOptionsVC alloc] init];
        SLNavigationController *nvc = [[SLNavigationController alloc] initWithRootViewController:sortVC];
        [weakSelf presentViewController:nvc animated:YES completion:nil];
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];

    [self createNewShortListView];

    if ([PFUser currentUser]) {
        NSData *shortlistData = [NSData dataWithContentsOfFile:[self getStorageLocation]];
        NSSet *allowedClasses = [NSSet setWithObjects:[NSArray class], [SLShortlist class], [SLShortListAlbum class], nil];
        self.shortLists = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:shortlistData error:nil];
        
        if (self.shortLists.count > 0) {
            [self.tableView reloadData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    __weak typeof(self) weakSelf = self;
    if ([PFUser currentUser]) {
        [SLParseController getUsersShortListsWithCompletion:^(NSArray *shortlists) {
            if (shortlists.count == 0) {
                [weakSelf addTableViewHeaderMessage:YES];
                weakSelf.shortLists = nil;
                weakSelf.navigationItem.leftBarButtonItem.enabled = NO;
            }
            else {
                weakSelf.tableView.tableHeaderView = nil;
                weakSelf.shortLists = [SLSortOptionsVC orderShortListForDisplayWithShortlists: shortlists];
                weakSelf.navigationItem.leftBarButtonItem.enabled = YES;
  
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:weakSelf.shortLists requiringSecureCoding:NO error:nil];
                [data writeToFile:[weakSelf getStorageLocation] options:NSDataWritingAtomic error:nil];
            }
            
            [weakSelf.tableView reloadData];
        }];
    }
    else {
        [self addTableViewHeaderMessage:NO];
        self.shortLists = nil;
        [self.tableView reloadData];
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL showedMessage = [userDefaults boolForKey:kShowedVersionUpdateMessage];
    
    if (showedMessage == false && [PFUser currentUser]) {
        [self showVersioningMessage];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

- (void)showVersioningMessage {
    UIAlertController * alert = [UIAlertController
                                alertControllerWithTitle:@"Hi There"
                                message:@"This is my last update for this version of the app. Exciting new features are underway, but make sure to use the export tool ASAP, as your existing Shortlists will be lost in this process. Feel free to contact me with any questions or feature requests!"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    NSLog(@"closed");
                                }];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:kShowedVersionUpdateMessage];
    [userDefaults synchronize];
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

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    __weak typeof(self) weakSelf = self;
    __block SLShortlist *shortlist = self.shortLists[indexPath.row];
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [weakSelf deleteShortlist:shortlist atIndexPath:indexPath];
        
        completionHandler(YES);
    }];
    
    UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:@[delete]];
    swipeActionConfig.performsFirstActionWithFullSwipe = NO;
    
    return swipeActionConfig;
}

#pragma mark GestureRecognizers
- (void)shortListCellSelected:(UIGestureRecognizer *)gestureRecognizer {
    SLAlbumsCollectionCell *cell = (SLAlbumsCollectionCell *)[gestureRecognizer view];
    SLShortlist *shortList = self.shortLists[cell.tag];
    [self.navigationController pushViewController:[[SLListAlbumsVC alloc] initWithShortList:shortList] animated:YES];
}

- (void)deleteShortlist:(SLShortlist *)shortlist atIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [SLParseController removeShortListWithShortlist:shortlist completion:^(NSArray * shortlists) {
        weakSelf.shortLists = shortlists;
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [weakSelf sl_showToastForAction:NSLocalizedString(@"Removed", nil) message:shortlist.shortListName toastType:SLToastMessageSuccess completion:nil];
        }];
        
        [self.tableView beginUpdates];
        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        [CATransaction commit];
    }];
}

- (void)addTableViewHeaderMessage:(BOOL)loggedIn {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SLTableViewHeaderMessageHeight)];
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.numberOfLines = 0;
    messageLabel.font = [SLStyle polarisFontWithSize:FontSizes.large];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = (loggedIn) ? NSLocalizedString(@"You do not have any ShortLists at the moment", nil) :  NSLocalizedString(@"Log in to add Shortlists", nil);
    CGSize messageSize = [messageLabel sizeThatFits:CGSizeMake(self.view.frame.size.width - MarginSizes.large, SLTableViewHeaderMessageHeight)];

    CGRect frame = messageLabel.frame;
    frame.origin.y = MarginSizes.medium;
    frame.size= messageSize;
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
        weakSelf.navigationItem.leftBarButtonItem.enabled = YES;
        
        [SLParseController getUsersShortListsWithCompletion:^(NSArray *shortlists) {
            weakSelf.shortLists = [SLSortOptionsVC orderShortListForDisplayWithShortlists: shortlists];
            weakSelf.navigationItem.leftBarButtonItem.enabled = YES;
            [weakSelf.tableView reloadData];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:weakSelf.shortLists requiringSecureCoding:NO error:nil];
            [data writeToFile:[weakSelf getStorageLocation] options:NSDataWritingAtomic error:nil];
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
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
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


- (NSString *)getStorageLocation {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex: 0];
    NSString *storageURLString = [docDir stringByAppendingPathComponent: @"ShortListStorage"];
    
    return storageURLString;
}

@end
