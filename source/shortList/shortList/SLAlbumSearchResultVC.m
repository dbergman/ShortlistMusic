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
#import "SLAlbumSearchResultsCellTableViewCell.h"

@interface SLAlbumSearchResultVC ()

@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, strong) NSString *artistName;

@end


@implementation SLAlbumSearchResultVC

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
 
    [self setTitle];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = [UITableView new];
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
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setLayoutMargins:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (void)setTitle {
    UILabel *artistTitleLabel = (UILabel *)self.navigationItem.titleView;
    artistTitleLabel = [UILabel new];
    artistTitleLabel.numberOfLines = 2;
    artistTitleLabel.textAlignment = NSTextAlignmentCenter;
    artistTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    artistTitleLabel.text = self.artistName;
    artistTitleLabel.textColor = [UIColor whiteColor];
    [artistTitleLabel sizeToFit];
    
    CGRect frame = artistTitleLabel.frame;
    frame.size.height = CGRectGetHeight(self.navigationController.navigationBar.frame);
    artistTitleLabel.frame = frame;
    self.navigationItem.titleView = artistTitleLabel;
}

@end
