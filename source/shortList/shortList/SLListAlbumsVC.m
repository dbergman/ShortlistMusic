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

const CGFloat kShortlistAlbumsButtonSize = 50.0;

@interface SLListAlbumsVC () <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) SLArtistSearchResultsVC *searchResultsVC;
@property (nonatomic, strong) Shortlist *shortList;
@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, strong) UIBarButtonItem *editShortListBarButton;
@property (nonatomic, strong) UIButton *moreOptionsButton;
@property (nonatomic, strong) UIButton *addAlbumButton;
@property (nonatomic, strong) UIButton *sharingButton;
@property (nonatomic, assign) BOOL showingOptions;

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
    [self refreshShortLists];
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

- (void)setupMoreOptions {
    CGRect closedStateFrame = CGRectMake(MarginSizes.large, [self getNavigationBarStatusBarHeight] + MarginSizes.large, kShortlistAlbumsButtonSize, kShortlistAlbumsButtonSize);
    
    __weak typeof(self)weakSelf = self;
    
    self.addAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addAlbumButton.backgroundColor = [UIColor sl_Red];
    self.addAlbumButton.layer.cornerRadius = kShortlistAlbumsButtonSize/2.0;
    [self.addAlbumButton setImage:[UIImage imageNamed:@"addAlbum"] forState:UIControlStateNormal];
    self.addAlbumButton.frame = closedStateFrame;
    [self.navigationController.view addSubview:self.addAlbumButton];
    
    [self.addAlbumButton bk_addEventHandler:^(id sender) {
        
    } forControlEvents:UIControlEventTouchUpInside];

    self.sharingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sharingButton.backgroundColor = [UIColor sl_Red];
    self.sharingButton.layer.cornerRadius = kShortlistAlbumsButtonSize/2.0;
    [self.sharingButton setImage:[UIImage imageNamed:@"sharing"] forState:UIControlStateNormal];
    self.sharingButton.frame = closedStateFrame;
    [self.navigationController.view addSubview:self.sharingButton];
    
    [self.sharingButton bk_addEventHandler:^(id sender) {
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.moreOptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreOptionsButton.backgroundColor = [UIColor sl_Red];
    self.moreOptionsButton.layer.cornerRadius = kShortlistAlbumsButtonSize/2.0;
    [self.moreOptionsButton setImage:[UIImage imageNamed:@"moreOptions"] forState:UIControlStateNormal];
    self.moreOptionsButton.frame = closedStateFrame;
    [self.navigationController.view addSubview:self.moreOptionsButton];
    
    [self.moreOptionsButton bk_addEventHandler:^(id sender) {
        CGRect addButtonFrame = closedStateFrame;
        CGRect shareButtonFrame = closedStateFrame;
        if (!weakSelf.showingOptions) {
            addButtonFrame.origin.y = addButtonFrame.origin.y + kShortlistAlbumsButtonSize + MarginSizes.xxLarge;
            shareButtonFrame.origin.y = shareButtonFrame.origin.y + (2 * kShortlistAlbumsButtonSize) + (2 * MarginSizes.xxLarge);
            weakSelf.showingOptions = YES;
        }
        else {
           addButtonFrame = closedStateFrame;
            shareButtonFrame = closedStateFrame;
            weakSelf.showingOptions = NO;
        }
        
        [UIView animateWithDuration:.2 animations:^{
            weakSelf.sharingButton.frame = shareButtonFrame;
            weakSelf.addAlbumButton.frame = addButtonFrame;
        }];

    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)startSearchAlbumFlow {
    self.searchResultsVC = [SLArtistSearchResultsVC new];
    self.searchResultsVC.navController = self.navigationController;
    self.searchResultsVC.shortList = self.shortList;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsVC];
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    
    self.searchController.searchBar.barStyle = UIBarStyleBlack;
    self.searchController.searchBar.barTintColor = [UIColor blackColor];
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
    UITextField *txtSearchField = [self.searchController.searchBar valueForKey:@"_searchField"];
    txtSearchField.backgroundColor = [UIColor whiteColor];
    
    self.searchController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    [self presentViewController:self.searchController animated:YES completion:nil];
}

#pragma mark - UISearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchItunesWithQuery:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchItunesWithQuery:searchBar.text];
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
    }
    else {
        editButton.title = NSLocalizedString(@"Done", nil);
        [self.tableView setEditing:YES animated:YES];
    }

    self.navigationItem.rightBarButtonItem = editButton;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  (section == 0) ? self.albums.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AddAlbumCellIdentifier = @"AddCell";
    static NSString *AlbumCellIdentifier = @"AlbumCell";
    
    if (indexPath.section == 0) {
        SLListAbumCell *cell = [tableView dequeueReusableCellWithIdentifier:AlbumCellIdentifier];
        if (cell == nil) {
            cell = [[SLListAbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlbumCellIdentifier];
        }

        ShortListAlbum *album = self.albums[indexPath.row];
        [cell configureCell:album];
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddAlbumCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddAlbumCellIdentifier];
    }
    
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
    cell.textLabel.text = @"Add Albums to ShortList";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        [self startSearchAlbumFlow];
    }
    else {
         ShortListAlbum *album = self.albums[indexPath.row];
        __weak typeof(self) weakSelf = self;
        [[ItunesSearchAPIController sharedManager] getTracksForAlbumID:[@(album.albumId) stringValue] completion:^(ItunesSearchTracks *albumSearchResults, NSError *error) {
            if (!error) {
                SLAlbumDetailsVC *albumDetailsVC = [[SLAlbumDetailsVC alloc] initWithShortList:weakSelf.shortList albumDetails:[albumSearchResults getAlbumInfo] tracks:[albumSearchResults getAlbumTracks]];
                [weakSelf.navigationController pushViewController:albumDetailsVC animated:YES];
            }
        }];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (tableView.editing) ?  UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *mutableAlbums = [self.albums mutableCopy];
    
    ShortListAlbum *album = mutableAlbums[sourceIndexPath.row];
    [mutableAlbums removeObjectAtIndex:sourceIndexPath.row];
    [mutableAlbums insertObject:album atIndex:destinationIndexPath.row];
    
    self.albums = [NSArray arrayWithArray:mutableAlbums];
    
    [self reorderShortList];
    
    __weak typeof(self)weakSelf = self;
    [SLParseController updateShortListAlbums:self.shortList albums:self.albums completion:^{
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
    return (indexPath.section == 0) ? YES : NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SLParseController removeAlbumFromShortList:self.shortList shortlistAlbum:self.albums[indexPath.row] completion:^(NSArray *albums) {
            NSMutableArray *mutableAlbums = [weakSelf.albums mutableCopy];
            [mutableAlbums removeObjectAtIndex:indexPath.row];
            
            weakSelf.albums = [NSArray arrayWithArray:mutableAlbums];
            [weakSelf reorderShortList];
            
            [SLParseController updateShortListAlbums:self.shortList albums:self.albums completion:^{
                [weakSelf.tableView reloadData];
            }];
         }];
    }
}

#pragma mark Utilities
- (void)refreshShortLists {
    __weak typeof(self) weakSelf = self;
    [SLParseController getShortListAlbums:self.shortList completion:^(NSArray * albums) {
        weakSelf.albums = albums;
        [weakSelf.tableView reloadData];
    }];
}

- (void)reorderShortList {
    [self.albums enumerateObjectsUsingBlock:^(ShortListAlbum *album, NSUInteger idx, BOOL *stop) {
        album.shortListRank = idx + 1;
    }];
}

@end
