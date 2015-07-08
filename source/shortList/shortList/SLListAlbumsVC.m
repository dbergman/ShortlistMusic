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
#import "ShortListAlbum.h"
#import "SLListAbumCell.h"
#import "shortList-Swift.h"

@interface SLListAlbumsVC () <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) SLArtistSearchResultsVC *searchResultsVC;
@property (nonatomic, strong) Shortlist *shortList;
@property (nonatomic ,strong) NSArray *albums;

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
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
    [self.view addSubview:self.tableView];
    
    self.definesPresentationContext = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [SLParseController getShortListAlbums:self.shortList completion:^(NSArray * albums) {
        weakSelf.albums = albums;
        [weakSelf.tableView reloadData];
    }];
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
    cell.textLabel.text = @"Add Albums to ShortList";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        [self startSearchAlbumFlow];
    }
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
            weakSelf.albums = albums;
            [weakSelf.tableView reloadData];
         }];
    }
}

@end
