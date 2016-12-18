//
//  SLListAlbumsVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLListAlbumsVC.h"
#import "SLArtistSearchResultsVC.h"
#import "ItunesSearchAPIController.h"
#import "ItunesSearchArtist.h"
#import "SLAlbumSearchResultVC.h"
#import "SLShortlist.h"
#import "SLStyle.h"
#import "SLShortListAlbum.h"
#import "SLListAbumCell.h"
#import "shortList-Swift.h"
#import "SLAlbumDetailsVC.h"
#import "ItunesSearchTracks.h"
#import "UIViewController+Utilities.h"
#import <BlocksKit+UIKit.h>
#import "UIViewController+SLEmailShortlist.h"
#import "UIViewController+SLToastBanner.h"
#import <QuartzCore/QuartzCore.h>
#import "SLAlbumArtImaging.h"
#import "SLInstagramController.h"
#import "UIViewController+SLAlbumArtImaging.h"
#import "MBProgressHUD.h"
#import "SLPreviewAlbumDetailsVC.h"
#import "ShortList+ShortlistYears.h"

const CGFloat kShortlistAlbumsButtonSize = 50.0;
const CGFloat kShortlistEditToolbarHeight = 30.0;

@interface SLListAlbumsVC () <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UIViewControllerPreviewingDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *blurBackgroundView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) SLArtistSearchResultsVC *searchResultsVC;
@property (nonatomic, strong) SLShortlist *shortList;
@property (nonatomic, strong) UIBarButtonItem *editShortListBarButton;
@property (nonatomic, strong) UIButton *moreOptionsButton;
@property (nonatomic, strong) UIButton *addAlbumButton;
@property (nonatomic, strong) UIButton *sharingButton;
@property (nonatomic, strong) UIButton *editNameButton;
@property (nonatomic, strong) SLEntryVC *editShortlistVC;
@property (nonatomic, assign) BOOL showingOptions;
@property (nonatomic, strong) SLShortListAlbum *previewingAlbum;
@property (nonatomic, strong) UIPickerView *yearPicker;
@property (nonatomic, strong) NSArray *shortlistYearArray;
@property (nonatomic, strong) UIView *pickerViewContainer;

@end

@implementation SLListAlbumsVC

- (instancetype)initWithShortList:(SLShortlist *)shortList {
    self = [super init];
    
    if (self) {
        self.shortList = shortList;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setTitle:self.shortList.shortListName];
 
    self.editShortListBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sortShortlists"] style:UIBarButtonItemStylePlain target:self action:@selector(shortListEditAction:)];
    self.navigationItem.rightBarButtonItem = self.editShortListBarButton;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120.0;
    [self.view addSubview:self.tableView];
    
    self.definesPresentationContext = YES;
    
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![PFUser currentUser]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    if (!self.searchResultsVC) {
        [self setupMoreOptions];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.moreOptionsButton removeFromSuperview];
    [self.addAlbumButton removeFromSuperview];
    [self.sharingButton removeFromSuperview];
    [self.editNameButton removeFromSuperview];
    self.tabBarController.tabBar.alpha = 1.0;
}

- (void)startSearchAlbumFlow {
    self.searchResultsVC = [SLArtistSearchResultsVC new];
    self.searchResultsVC.navController = self.navigationController;
    self.searchResultsVC.shortList = self.shortList;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsVC];
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Add an Album", nil);
    
    self.searchController.searchBar.barStyle = UIBarStyleBlack;
    self.searchController.searchBar.barTintColor = [UIColor blackColor];
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
    UITextField *txtSearchField = [self.searchController.searchBar valueForKey:@"_searchField"];
    txtSearchField.backgroundColor = [UIColor whiteColor];
    
    self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    
    __weak typeof(self)weakSelf = self;
    [self presentViewController:self.searchController animated:YES completion:^{
        [weakSelf showOptions:NO];
    }];
}

#pragma mark - UISearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchItunesWithQuery:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchItunesWithQuery:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self setupMoreOptions];
    [self showOptions:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self setupMoreOptions];
    [self showOptions:(!self.searchResultsVC)];
}

#pragma mark - Search Itunes
- (void)searchItunesWithQuery:(NSString *)query {
    __weak typeof(self) weakSelf = self;
    [[ItunesSearchAPIController sharedManager] getSearchResultsWithBlock:query completion:^(ItunesSearchArtist *searchArtistResults, NSError *error) {
        if (!error) {
            weakSelf.searchResultsVC.searchResults = searchArtistResults.artistResults;
            [weakSelf.searchResultsVC.tableView reloadData];
        }
    }];
}

#pragma mark - barbuttonAdctions
-(void)shortListEditAction:(id)sender {
    if (self.showingOptions) {
        [self toggleOptionsButton];
    }
    
    UIBarButtonItem *editButton = (UIBarButtonItem *)sender;
    
    if (self.tableView.editing) {
        editButton.image = [UIImage imageNamed:@"sortShortlists"];
        editButton.title = nil;
        [self.tableView setEditing:NO animated:YES];
        [self showOptions:YES];
        
    }
    else {
        editButton.title = NSLocalizedString(@"Done", nil);
        editButton.image = nil;
        [self.tableView setEditing:YES animated:YES];
        [self showOptions:NO];
    }
    
    self.navigationItem.rightBarButtonItem = editButton;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.shortList.shortListAlbums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AddAlbumCellIdentifier = @"AddCell";
    static NSString *AlbumCellIdentifier = @"AlbumCell";
    
    if (indexPath.section == 0) {
        SLListAbumCell *cell = [tableView dequeueReusableCellWithIdentifier:AlbumCellIdentifier];
        if (cell == nil) {
            cell = [[SLListAbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlbumCellIdentifier];
        }

        SLShortListAlbum *album = self.shortList.shortListAlbums[indexPath.row];
        [cell configureCell:album];
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddAlbumCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddAlbumCellIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SLShortListAlbum *album = self.shortList.shortListAlbums[indexPath.row];
    SLAlbumDetailsVC *albumDetailsVC = [[SLAlbumDetailsVC alloc] initWithShortList:self.shortList albumId:[NSString stringWithFormat:@"%ld",(long)album.albumId]];
    [self.navigationController pushViewController:albumDetailsVC animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (tableView.editing) ?  UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *mutableAlbums = [self.shortList.shortListAlbums mutableCopy];
    
    SLShortListAlbum *album = mutableAlbums[sourceIndexPath.row];
    [mutableAlbums removeObjectAtIndex:sourceIndexPath.row];
    [mutableAlbums insertObject:album atIndex:destinationIndexPath.row];
    
    self.shortList.shortListAlbums = [NSArray arrayWithArray:mutableAlbums];
    
    [self reorderShortList];
    
    __weak typeof(self)weakSelf = self;
    [SLParseController updateShortListAlbumsWithShortlist:self.shortList completion:^{
        [weakSelf.tableView reloadData];
    }];
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setLayoutMargins:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __block SLShortListAlbum *slAbum = self.shortList.shortListAlbums[indexPath.row];
        [SLParseController removeAlbumFromShortListWithShortList:self.shortList shortlistAlbum:slAbum completion:^(NSArray *albums) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
            
            weakSelf.shortList.shortListAlbums = albums;
            [weakSelf reorderShortList];
            
            [SLParseController updateShortListAlbumsWithShortlist:self.shortList completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf sl_showToastForAction:NSLocalizedString(@"Removed", nil) message:slAbum.albumName toastType:SLToastMessageSuccess completion:^{
                        [weakSelf.tableView reloadData];
                    }];
                });
            }];
         }];
    }
}

#pragma mark Blurring Methods
- (void)addBlurBackgroundWithDismisGesture:(BOOL)dismisGesture {
    self.blurBackgroundView = [[UIImageView alloc] initWithImage:[self getBlurredScreenShot]];
    self.blurBackgroundView.userInteractionEnabled = YES;
    [self.view addSubview:self.blurBackgroundView];
    
    if (dismisGesture) {
        self.blurBackgroundView.alpha = 0;
        UITapGestureRecognizer *dismissGesture =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOptionsButton)];
        [self.blurBackgroundView addGestureRecognizer:dismissGesture];
    }
}

#pragma mark Options Button
- (void)setupMoreOptions {
    if (self.moreOptionsButton) {
        for (UIButton *optionButton in @[self.editNameButton, self.addAlbumButton, self.sharingButton, self.moreOptionsButton]) {
            [self.navigationController.view addSubview:optionButton];
        }
        
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    self.addAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addAlbumButton setImage:[UIImage imageNamed:@"searchAlbums"] forState:UIControlStateNormal];
    [self.addAlbumButton bk_addEventHandler:^(id sender) {
        [weakSelf toggleOptionsButton];
        [weakSelf startSearchAlbumFlow];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.sharingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *shareImage = [[UIImage imageNamed:@"sharing"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.sharingButton setImage:shareImage forState:UIControlStateNormal];
    [self.sharingButton setTintColor:[UIColor whiteColor]];
    [self.sharingButton addTarget:self action:@selector(showSharingOptions) forControlEvents:UIControlEventTouchUpInside];
    
    self.editNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editNameButton setImage:[UIImage imageNamed:@"editName"] forState:UIControlStateNormal];
    [self.editNameButton setTintColor:[UIColor whiteColor]];
    [self.editNameButton addTarget:self action:@selector(showEditShortListNameFlow) forControlEvents:UIControlEventTouchUpInside];
    
    self.moreOptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreOptionsButton setImage:[UIImage imageNamed:@"moreOptions"] forState:UIControlStateNormal];
    [self.moreOptionsButton addTarget:self action:@selector(toggleOptionsButton) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *optionButton in @[self.editNameButton, self.addAlbumButton, self.sharingButton, self.moreOptionsButton]) {
        optionButton.backgroundColor = [UIColor sl_Red];
        optionButton.layer.cornerRadius = kShortlistAlbumsButtonSize/2.0;
        optionButton.frame = [self getOptionsCloseFrame];
        
        optionButton.layer.shadowRadius = 3.0f;
        optionButton.layer.shadowColor = [UIColor blackColor].CGColor;
        optionButton.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        optionButton.layer.shadowOpacity = 0.5f;
        optionButton.layer.masksToBounds = NO;
        
        [self.navigationController.view addSubview:optionButton];
    }
}

- (void)showOptions:(BOOL)show {
    [UIView animateWithDuration:.2 animations:^{
        if (show) {
            self.moreOptionsButton.alpha = 1.0;
            self.showingOptions = YES;
        }
        else {
            self.moreOptionsButton.alpha = 0.0;
            self.sharingButton.hidden = YES;
            self.addAlbumButton.hidden = YES;
            self.editNameButton.hidden = YES;
            self.showingOptions = NO;
        }
    }completion:^(BOOL finished) {
        if (show) {
            self.moreOptionsButton.alpha = 1.0;
            self.sharingButton.hidden = NO;
            self.addAlbumButton.hidden = NO;
            self.editNameButton.hidden = NO;
            self.showingOptions = YES;
        }
    }];
}

- (void)toggleOptionsButton {
    CGRect addButtonFrame = [self getOptionsCloseFrame];
    CGRect shareButtonFrame = [self getOptionsCloseFrame];
    CGRect editNameButtonFrame = [self getOptionsCloseFrame];

    if (!self.showingOptions) {
        addButtonFrame.origin.x = MarginSizes.large;
        editNameButtonFrame.origin.x = CGRectGetWidth(self.view.frame)/2.0/2.0 + MarginSizes.large;
        shareButtonFrame.origin.x = (CGRectGetMaxX(editNameButtonFrame) + self.moreOptionsButton.frame.origin.x)/2.0 - kShortlistAlbumsButtonSize/2.0;

        self.showingOptions = YES;
        [self addBlurBackgroundWithDismisGesture:YES];
    }
    else {
        [self.blurBackgroundView removeFromSuperview];
        self.blurBackgroundView = nil;
        self.showingOptions = NO;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        self.blurBackgroundView.alpha = 1.0;
        self.sharingButton.frame = shareButtonFrame;
        self.addAlbumButton.frame = addButtonFrame;
        self.editNameButton.frame = editNameButtonFrame;
    }];
}

- (void)showEditShortListNameFlow {
    [self toggleOptionsButton];
    
    __weak typeof(self)weakSelf = self;
    self.editShortlistVC = [[SLEntryVC alloc] initWithExistingShortList:self.shortList onSuccess:^(NSString *shortlistName) {
        weakSelf.title = shortlistName;
        [weakSelf dismissEditShortListName];
    } onCancel:^{
        [weakSelf dismissEditShortListName];
    }];
    
    [self hidePickerView];
    
    [self.editShortlistVC setShowPickerView:^(BOOL showPicker) {
        if (showPicker && !weakSelf.yearPicker) {
            weakSelf.shortlistYearArray = [ShortList generateYearList];
            weakSelf.yearPicker = [UIPickerView new];
            weakSelf.yearPicker.delegate = weakSelf;
            weakSelf.yearPicker.dataSource = weakSelf;
            weakSelf.yearPicker.backgroundColor = [UIColor blackColor];
            weakSelf.yearPicker.showsSelectionIndicator = YES;
            [weakSelf showPickerView];
        }
        else {
            [weakSelf hidePickerView];
        }
    }];
    
    self.editShortlistVC.view.layer.borderColor = [UIColor sl_Red].CGColor;
    self.editShortlistVC.view.layer.borderWidth = 2.0;
    self.editShortlistVC.view.layer.cornerRadius = 8.0;
    self.editShortlistVC.view.clipsToBounds = YES;
    
    CGSize editShortlistSize = [self.editShortlistVC.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGRect frame = CGRectMake(CGRectGetWidth(self.view.frame)/2.0 - editShortlistSize.width/2.0, CGRectGetHeight([UIScreen mainScreen].bounds), editShortlistSize.width, editShortlistSize.height);
    self.editShortlistVC.view.frame = frame;
    
    [self addBlurBackgroundWithDismisGesture:NO];
    
    [self.view addSubview:self.editShortlistVC.view];

    [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:9 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.editShortlistVC.view.center = CGPointMake(self.view.center.x, CGRectGetHeight([UIScreen mainScreen].bounds)/2.0 - editShortlistSize.height/2.0 - 12.0);
    } completion:^(BOOL finished) {
        [self showOptions:NO];
    }];
}

- (void)dismissEditShortListName {
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = CGRectMake(CGRectGetWidth(self.view.frame)/2.0 - CGRectGetWidth(self.editShortlistVC.view.frame)/2.0, CGRectGetHeight([UIScreen mainScreen].bounds), self.editShortlistVC.view.frame.size.width, self.editShortlistVC.view.frame.size.height);
        self.editShortlistVC.view.frame = frame;
        [self hidePickerView];
    } completion:^(BOOL finished) {
        [self.blurBackgroundView removeFromSuperview];
        self.blurBackgroundView = nil;
        self.editShortlistVC = nil;
        [self showOptions:YES];
    }];
}

- (void)showSharingOptions {
    [self toggleOptionsButton];
    
    __weak typeof(self)weakSelf = self;
    UIAlertController * alert=   [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Share Shortlist", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *email = [UIAlertAction actionWithTitle:NSLocalizedString(@"Email", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:weakSelf.navigationController.view];
                            [weakSelf.navigationController.view addSubview:hud];
                            hud.label.text = NSLocalizedString(@"Building Image", nil);
                            
                            [hud showAnimated:YES whileExecutingBlock:^{
                                [weakSelf shareShortlistByEmail:weakSelf.shortList albumArtCollectionImage:[weakSelf getAlbumArtCollectionImage]];
                            }];
                        }];
    [alert addAction:email];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
       UIAlertAction *instagram =  [UIAlertAction actionWithTitle:NSLocalizedString(@"Instagram", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:weakSelf.navigationController.view];
            [weakSelf.navigationController.view addSubview:hud];
            hud.label.text = NSLocalizedString(@"Building Image", nil);
            [hud showAnimated:YES whileExecutingBlock:^{
                [[SLInstagramController sharedInstance] shareShortlistToInstagram:weakSelf.shortList  albumArtCollectionImage:[weakSelf getAlbumArtCollectionImage] attachToView:weakSelf.view];
            }];
        }];
        
        [alert addAction:instagram];
    }

    UIAlertAction *saveImage =  [UIAlertAction actionWithTitle:NSLocalizedString(@"Save Image", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:weakSelf.navigationController.view];
        [weakSelf.navigationController.view addSubview:hud];
        hud.label.text = NSLocalizedString(@"Building Image", nil);
        [hud showAnimated:YES whileExecutingBlock:^{
            UIImageWriteToSavedPhotosAlbum([weakSelf getAlbumArtCollectionImage], nil, nil, nil);
        }];
    }];
    
    [alert addAction:saveImage];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)   style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    

    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (CGRect)getOptionsCloseFrame {
    return CGRectMake(self.view.frame.size.width - kShortlistAlbumsButtonSize - MarginSizes.large, [self getNavigationBarStatusBarHeight] + MarginSizes.large, kShortlistAlbumsButtonSize, kShortlistAlbumsButtonSize);
}

- (UIImage *)getAlbumArtCollectionImage {
    SLAlbumArtImaging *albumArtImaging = [SLAlbumArtImaging new];
    
    return [albumArtImaging buildShortListAlbumArt:self.shortList];
}


#pragma mark UIViewControllerPreviewingDelegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    
    CGPoint cellPostion = [self.tableView convertPoint:location fromView:self.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cellPostion];
    
    SLListAbumCell *shortListAlbumCell = (SLListAbumCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    SLShortListAlbum *album = self.shortList.shortListAlbums[indexPath.row];
    
    self.previewingAlbum = album;
    
    SLPreviewAlbumDetailsVC *previewAlbumDetailsVC = [[SLPreviewAlbumDetailsVC alloc] initWithShortListAlbum:album];
    
    CGSize previewSize = [previewAlbumDetailsVC.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    previewAlbumDetailsVC.preferredContentSize = CGSizeMake(previewSize.width, previewSize.height);
    
    previewingContext.sourceRect = [self.view convertRect:shortListAlbumCell.frame fromView:self.tableView];
    
    return previewAlbumDetailsVC;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    SLAlbumDetailsVC *albumDetailsVC = [[SLAlbumDetailsVC alloc] initWithShortList:self.shortList albumId:[NSString stringWithFormat:@"%ld",(long)self.previewingAlbum.albumId]];
    [self.navigationController pushViewController:albumDetailsVC animated:YES];
}

#pragma mark UIPickerView Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.shortlistYearArray.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.shortlistYearArray[row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.shortlistYearArray[row] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *selectedYear = [NSString stringWithFormat:@"Year: %@", self.shortlistYearArray[row]];
    
    self.editShortlistVC.existingShortList.shortListYear = self.shortlistYearArray[row];
    [self.editShortlistVC.changeYearButton setTitle:selectedYear forState:UIControlStateNormal];
}

- (void)showPickerView {
    self.pickerViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(self.yearPicker.frame) + kShortlistEditToolbarHeight)];
    self.pickerViewContainer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.pickerViewContainer];
    [self.pickerViewContainer addSubview:self.yearPicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kShortlistEditToolbarHeight)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    
    __weak typeof(self)weakSelf = self;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemDone handler:^(id sender) {
        [weakSelf hidePickerView];
    }];
    
    [toolBar setItems:[NSArray arrayWithObjects:doneButton, nil]];
    [self.pickerViewContainer addSubview:toolBar];
    toolBar.userInteractionEnabled = YES;

    __block CGRect frame = self.pickerViewContainer.frame;
    frame.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds);
    self.pickerViewContainer.frame = frame;
    
    self.yearPicker.frame = CGRectMake(self.view.frame.size.width/2.0 - self.yearPicker.frame.size.width/2.0, kShortlistEditToolbarHeight, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(self.yearPicker.frame));

    [UIView animateWithDuration:0.3 animations:^{
        frame.origin.y = frame.origin.y - frame.size.height;
        self.pickerViewContainer.frame = frame;
        self.tabBarController.tabBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        NSInteger selectedIndex = [self.shortlistYearArray indexOfObject:self.shortList.shortListYear];
        [self.yearPicker selectRow:selectedIndex inComponent:0 animated:YES];
    }];
}

- (void)hidePickerView {
    __block CGRect frame = self.pickerViewContainer.frame;
    frame.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds);
   
    [UIView animateWithDuration:0.3 animations:^{
        self.pickerViewContainer.frame = frame;
        self.tabBarController.tabBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.yearPicker = nil;
        self.pickerViewContainer = nil;
    }];
}

#pragma mark Utilities
- (void)refreshShortLists {
    __weak typeof(self) weakSelf = self;
    [SLParseController getShortListAlbumsWithShortList:self.shortList completion:^(NSArray * albums) {
        weakSelf.shortList.shortListAlbums = albums;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)reorderShortList {
    [self.shortList.shortListAlbums enumerateObjectsUsingBlock:^(SLShortListAlbum *album, NSUInteger idx, BOOL *stop) {
        album.shortListRank = idx + 1;
    }];
}

@end
