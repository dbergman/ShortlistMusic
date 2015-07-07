//
//  SLAlbumSearchResultTableVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumSearchResultVC.h"
#import "ItunesSearchAPIController.h"
#import "ItunesAlbum.h"
#import "ItunesSearchTracks.h"
#import "SLAlbumSearchResultsCellTableViewCell.h"
#import "SLAlbumDetailsVC.h"
#import "Shortlist.h"

@interface SLAlbumSearchResultVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) Shortlist *shortList;

@end


@implementation SLAlbumSearchResultVC

- (instancetype)initWithShortList:(Shortlist *)shortList ArtistName:(NSString *)artistName Albums:(NSArray *)albums {
    self = [self initWithArtistName:artistName Albums:albums];
    
    if (self) {
        self.shortList = shortList;
    }
    
    return self;
}

- (instancetype)initWithArtistName:(NSString *)artistName Albums:(NSArray *)albums {
    self = [super init];
    
    if (self) {
        self.albums = albums;
        self.artistName = artistName;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self setTitle:self.artistName];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [UITableView new];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    SLAlbumSearchResultsCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SLAlbumSearchResultsCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ItunesAlbum *album = self.albums[indexPath.row];
    [cell configCellWithItunesAlbum:album];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ItunesAlbum *album = [self.albums objectAtIndex:indexPath.row];
    [self getAlbumTracks:album];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setLayoutMargins:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

#pragma mark - Itunes Networking
- (void)getAlbumTracks:(ItunesAlbum *)album {
    __weak typeof(self) weakSelf = self;
    [[ItunesSearchAPIController sharedManager] getTracksForAlbumID:[@(album.collectionId) stringValue] completion:^(ItunesSearchTracks *albumSearchResults, NSError *error) {
        if (!error) {
            SLAlbumDetailsVC *albumDetailsVC = [[SLAlbumDetailsVC alloc] initWithShortList:weakSelf.shortList albumDetails:[albumSearchResults getAlbumInfo] tracks:[albumSearchResults getAlbumTracks]];
            [weakSelf.navigationController pushViewController:albumDetailsVC animated:YES];
        }
    }];
}

@end
