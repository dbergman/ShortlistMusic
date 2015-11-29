//
//  SLSearchResultsVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLArtistSearchResultsVC.h"
#import "SLAlbumSearchResultVC.h"
#import "ItunesSearchAPIController.h"
#import "ItunesSearchAlbum.h"
#import "ItunesArtist.h"
#import "SLShortlist.h"
#import "SLStyle.h"

@implementation SLArtistSearchResultsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [UITableView new];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ItunesArtist *artist = self.searchResults[indexPath.row];
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = artist.artistName;
    cell.textLabel.font = [SLStyle polarisFontWithSize:FontSizes.medium];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ItunesArtist *artist = self.searchResults[indexPath.row];
    [self getArtistReleases:artist];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setLayoutMargins:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

#pragma mark - Itunes Networking
- (void)getArtistReleases:(ItunesArtist *)itunesArtist {
    __weak typeof(self) weakSelf = self;
    [[ItunesSearchAPIController sharedManager] getAlbumsForArtist:[NSNumber numberWithInteger:itunesArtist.artistId] completion:^(ItunesSearchAlbum *albumResult, NSError *error) {
        if (!error) {
            [ItunesSearchAPIController filterAlbums:albumResult ByYear:weakSelf.shortList.shortListYear];
            
            SLAlbumSearchResultVC *albumResltsVC = [[SLAlbumSearchResultVC alloc] initWithShortList:weakSelf.shortList ArtistName:itunesArtist.artistName Albums:albumResult.getArtistAlbums];
            [weakSelf.navController pushViewController:albumResltsVC animated:YES];
        }
    }];
}


@end
