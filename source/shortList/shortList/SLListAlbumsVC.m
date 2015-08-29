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
#import "Shortlist.h"
#import "SLStyle.h"
#import "ShortListAlbum.h"
#import "SLListAbumCell.h"
#import "shortList-Swift.h"
#import "SLAlbumDetailsVC.h"
#import "ItunesSearchTracks.h"
#import "UIViewController+Utilities.h"
#import <BlocksKit+UIKit.h>
#import "FXBlurView.h"
#import "UIViewController+SLEmailShortlist.h"
#import <QuartzCore/QuartzCore.h>
#import "SLAlbumArtImaging.h"
#import "SLInstagramController.h"
#import "UIViewController+SLAlbumArtImaging.h"

const CGFloat kShortlistAlbumsButtonSize = 50.0;

@interface SLListAlbumsVC () <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *blurBackgroundView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) SLArtistSearchResultsVC *searchResultsVC;
@property (nonatomic, strong) Shortlist *shortList;
@property (nonatomic, strong) UIBarButtonItem *editShortListBarButton;
@property (nonatomic, strong) UIButton *moreOptionsButton;
@property (nonatomic, strong) UIButton *addAlbumButton;
@property (nonatomic, strong) UIButton *sharingButton;
@property (nonatomic, assign) BOOL showingOptions;
@property (nonatomic, strong) NSTimer *keyStrokeTimer;

@end

@implementation SLListAlbumsVC

- (instancetype)initWithShortList:(Shortlist *)shortList {
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
 
    self.editShortListBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(shortListEditAction:)];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupMoreOptions];
    
    if (self.shortList.objectId) {
        [self refreshShortLists];
    }
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
    if (!self.keyStrokeTimer) {
        self.keyStrokeTimer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(timerFinished) userInfo:nil repeats:NO];
        
        [[NSRunLoop currentRunLoop] addTimer:self.keyStrokeTimer forMode:NSRunLoopCommonModes];
    
        [self searchItunesWithQuery:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchItunesWithQuery:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self showOptions:YES];
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
    UIBarButtonItem *editButton = (UIBarButtonItem *)sender;
    
    if (self.tableView.editing) {
        editButton.title = NSLocalizedString(@"Edit", nil);
        [self.tableView setEditing:NO animated:YES];
        [self showOptions:YES];
        
    }
    else {
        editButton.title = NSLocalizedString(@"Done", nil);
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

        ShortListAlbum *album = self.shortList.shortListAlbums[indexPath.row];
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
    
     ShortListAlbum *album = self.shortList.shortListAlbums[indexPath.row];
    __weak typeof(self) weakSelf = self;
    [[ItunesSearchAPIController sharedManager] getTracksForAlbumID:[@(album.albumId) stringValue] completion:^(ItunesSearchTracks *albumSearchResults, NSError *error) {
        if (!error) {
            SLAlbumDetailsVC *albumDetailsVC = [[SLAlbumDetailsVC alloc] initWithShortList:weakSelf.shortList albumDetails:[albumSearchResults getAlbumInfo] tracks:[albumSearchResults getAlbumTracks]];
            [weakSelf.navigationController pushViewController:albumDetailsVC animated:YES];
        }
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (tableView.editing) ?  UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *mutableAlbums = [self.shortList.shortListAlbums mutableCopy];
    
    ShortListAlbum *album = mutableAlbums[sourceIndexPath.row];
    [mutableAlbums removeObjectAtIndex:sourceIndexPath.row];
    [mutableAlbums insertObject:album atIndex:destinationIndexPath.row];
    
    self.shortList.shortListAlbums = [NSArray arrayWithArray:mutableAlbums];
    
    [self reorderShortList];
    
    __weak typeof(self)weakSelf = self;
    [SLParseController updateShortListAlbums:self.shortList completion:^{
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
        [SLParseController removeAlbumFromShortList:self.shortList shortlistAlbum:self.shortList.shortListAlbums[indexPath.row] completion:^(NSArray *albums) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
            
            weakSelf.shortList.shortListAlbums = albums;
            [weakSelf reorderShortList];
            
            [SLParseController updateShortListAlbums:self.shortList completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            }];
         }];
    }
}

#pragma mark Blurring Methods
- (void)addBlurBackground {
    self.blurBackgroundView = [[UIImageView alloc] initWithImage:[self getScreenShot]];
    self.blurBackgroundView.userInteractionEnabled = YES;
    [self.view addSubview:self.blurBackgroundView];
    self.blurBackgroundView.alpha = 0;
    
    FXBlurView *shortListBlurView = [[FXBlurView alloc] init];
    shortListBlurView.frame = self.blurBackgroundView.bounds;
    shortListBlurView.tintColor = [UIColor blackColor];
    shortListBlurView.blurEnabled = YES;
    shortListBlurView.clipsToBounds = YES;
    shortListBlurView.blurRadius = 9;
    [self.blurBackgroundView addSubview:shortListBlurView];

    UITapGestureRecognizer *dismissGesture =  [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(toggleOptionsButton)];
    [shortListBlurView addGestureRecognizer:dismissGesture];
}

#pragma mark Options Button
- (void)setupMoreOptions {
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
    
    self.moreOptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreOptionsButton setImage:[UIImage imageNamed:@"moreOptions"] forState:UIControlStateNormal];
    [self.moreOptionsButton addTarget:self action:@selector(toggleOptionsButton) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *optionButton in @[self.addAlbumButton, self.sharingButton, self.moreOptionsButton]) {
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
        }
        else {
            self.moreOptionsButton.alpha = 0.0;
            self.sharingButton.hidden = YES;
            self.addAlbumButton.hidden = YES;
        }
    }completion:^(BOOL finished) {
        if (show) {
            self.sharingButton.hidden = NO;
            self.addAlbumButton.hidden = NO;
        }
    }];
}

- (void)toggleOptionsButton {
    CGRect addButtonFrame = [self getOptionsCloseFrame];
    CGRect shareButtonFrame = [self getOptionsCloseFrame];
    
    if (!self.showingOptions) {
        addButtonFrame.origin.y = addButtonFrame.origin.y + kShortlistAlbumsButtonSize + MarginSizes.xxLarge;
        shareButtonFrame.origin.y = shareButtonFrame.origin.y + (2 * kShortlistAlbumsButtonSize) + (2 * MarginSizes.xxLarge);
        self.showingOptions = YES;
        [self addBlurBackground];
    }
    else {
        addButtonFrame = [self getOptionsCloseFrame];
        shareButtonFrame = [self getOptionsCloseFrame];
        self.showingOptions = NO;
        [self.blurBackgroundView removeFromSuperview];
    }
    
    [UIView animateWithDuration:.2 animations:^{
        self.blurBackgroundView.alpha = 1.0;
        self.sharingButton.frame = shareButtonFrame;
        self.addAlbumButton.frame = addButtonFrame;
    }];
}

- (void)showSharingOptions {
    [self toggleOptionsButton];
    
    __weak typeof(self)weakSelf = self;
    UIActionSheet *slSharingSheet = [UIActionSheet bk_actionSheetWithTitle:NSLocalizedString(@"Share Shortlist", nil)];
    
    [slSharingSheet bk_addButtonWithTitle:NSLocalizedString(@"Email", nil) handler:^{
        [weakSelf shareShortlistByEmail:weakSelf.shortList albumArtCollectionImage:[weakSelf getAlbumArtCollectionImage]];
    }];
    [slSharingSheet bk_addButtonWithTitle:NSLocalizedString(@"Facebook", nil) handler:^{ NSLog(@"Facebook!"); }];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [slSharingSheet bk_addButtonWithTitle:NSLocalizedString(@"Instagram", nil) handler:^{
            [[SLInstagramController sharedInstance] shareShortlistToInstagram:weakSelf.shortList  albumArtCollectionImage:[weakSelf getAlbumArtCollectionImage] attachToView:weakSelf.view];
        }];
    }

    [slSharingSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    [slSharingSheet showInView:self.view];
}

- (CGRect)getOptionsCloseFrame {
    return CGRectMake(self.view.frame.size.width - kShortlistAlbumsButtonSize - MarginSizes.large, [self getNavigationBarStatusBarHeight] + MarginSizes.large, kShortlistAlbumsButtonSize, kShortlistAlbumsButtonSize);
}

- (UIImage *)getAlbumArtCollectionImage {
    SLAlbumArtImaging *albumArtImaging = [SLAlbumArtImaging new];
    
    return [albumArtImaging buildShortListAlbumArt:self.shortList];
}

#pragma mark Utilities
- (void)refreshShortLists {
    __weak typeof(self) weakSelf = self;
    [SLParseController getShortListAlbums:self.shortList completion:^(NSArray * albums) {
        weakSelf.shortList.shortListAlbums = albums;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)reorderShortList {
    [self.shortList.shortListAlbums enumerateObjectsUsingBlock:^(ShortListAlbum *album, NSUInteger idx, BOOL *stop) {
        album.shortListRank = idx + 1;
    }];
}

#pragma mark KeyStroke timer
- (void)timerFinished {
    if (self.keyStrokeTimer) {
        [self.keyStrokeTimer invalidate];
        self.keyStrokeTimer = nil;
    }
}

@end
