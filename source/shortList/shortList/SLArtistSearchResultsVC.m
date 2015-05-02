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


@interface SLArtistSearchResultsVC ()

@property (nonatomic, copy) ArtistResultsCompletionBlock completion;

@end

@implementation SLArtistSearchResultsVC

- (instancetype)initWithCompletion:(ArtistResultsCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blackColor];
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    ItunesArtist *artist = self.searchResults[indexPath.row];
    [self getArtistReleases:artist.artistId];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setLayoutMargins:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

#pragma mark - Itunes Networking
- (void)getArtistReleases:(NSInteger)artistId {
    __weak typeof(self) weakSelf = self;
    [[ItunesSearchAPIController sharedManager] getAlbumsForArtist:[NSNumber numberWithInteger:artistId] completion:^(ItunesSearchAlbum *albumResult, NSError *error) {
        if (!error) {
            if (weakSelf.completion) {
                weakSelf.completion(albumResult.albumResults);
            }
        }
    }];
}


@end
