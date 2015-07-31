//
//  SLAlbumDetailsVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/3/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumDetailsVC.h"
#import "ItunesTrack.h"
#import "SLStyle.h"
#import "UIImage+AverageColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <BlocksKit+UIKit.h>
#import "SLAlbumDetailsCell.h"
#import "SLAlbumTrackCell.h"
#import "Shortlist.h"
#import "ShortListAlbum.h"
#import "shortList-Swift.h"

static CGFloat const kSLAlbumDetailsCellHeight = 60.0;
static CGFloat const kSLAlbumTrackCellHeight = 44.0;
static CGFloat const kSLSpotifyButtonSize = 44.0;
static NSString * const kSLSpotifyURL = @"spotify://http://open.spotify.com/search/album:%@";

@interface SLAlbumDetailsVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) ItunesTrack *albumDetails;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) Shortlist *shortList;
@property (nonatomic, strong) UIButton *spotifyButton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;

@end

@implementation SLAlbumDetailsVC

- (instancetype)initWithAlbumDetails:(ItunesTrack *)albumDetails Tracks:(NSArray *)tracks {
    self = [super init];
    
    if (self) {
        self.albumDetails = albumDetails;
        self.tracks = tracks;
    }
    
    return self;
}

- (instancetype)initWithShortList:(Shortlist *)shortList albumDetails:(ItunesTrack *)albumDetails tracks:(NSArray *)tracks {
    self = [self initWithAlbumDetails:albumDetails Tracks:tracks];
    
    if (self) {
        self.shortList = shortList;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:([self getShortListAlbum])? NSLocalizedString(@"Remove", nil) : NSLocalizedString(@"Add", nil) style:UIBarButtonItemStylePlain handler:^(id sender) {
        ([self getShortListAlbum]) ? [weakSelf removeAlbumFromShortList] : [weakSelf addAlbumToShortList];
    }];
     
    self.view.backgroundColor = [UIColor blackColor];
    [self setTitle:self.albumDetails.collectionName];
    self.automaticallyAdjustsScrollViewInsets = YES;

    self.coverImageView = [UIImageView new];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.coverImageView];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UITableView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;

    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.albumDetails.artworkUrl400] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
     
        [weakSelf.view addSubview:weakSelf.tableView];
        
        weakSelf.coverImageView.frame = CGRectMake(0.0, weakSelf.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height, weakSelf.view.frame.size.width, weakSelf.view.frame.size.width);
        
        weakSelf.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(weakSelf.coverImageView.frame) - kSLAlbumDetailsCellHeight, 0.0f, CGRectGetHeight(weakSelf.tabBarController.tabBar.frame), 0.0f);
    }];

    [self setupSpotifyButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.spotifyButton removeFromSuperview];
}

- (void)setupSpotifyButton {
    self.spotifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.spotifyButton setImage:[UIImage imageNamed:@"spotifyIcon"] forState:UIControlStateNormal];
    self.spotifyButton.alpha = .7;
    self.spotifyButton.imageView.layer.cornerRadius = 7.0f;
    self.spotifyButton.layer.shadowRadius = 3.0f;
    self.spotifyButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.spotifyButton.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.spotifyButton.layer.shadowOpacity = 0.5f;
    self.spotifyButton.layer.masksToBounds = NO;
    self.spotifyButton.frame = CGRectMake(self.view.frame.size.width - kSLSpotifyButtonSize - MarginSizes.xLarge, self.view.frame.size.height - MarginSizes.large - kSLSpotifyButtonSize - self.tabBarController.tabBar.frame.size.height, kSLSpotifyButtonSize, kSLSpotifyButtonSize);
    [self.spotifyButton bk_addEventHandler:^(id sender) {
        NSString *urlString = [NSString stringWithFormat:kSLSpotifyURL,self.albumDetails.collectionName];
        NSString *escaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:self.spotifyButton];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 1 : self.tracks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0) ? kSLAlbumDetailsCellHeight : kSLAlbumTrackCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AlbumDetailCellIdentifier = @"AlbumDetailCell";
    
    if (indexPath.section == 0) {
        SLAlbumDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:AlbumDetailCellIdentifier];
        if (cell == nil) {
            cell = [[SLAlbumDetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlbumDetailCellIdentifier];
        }
        
        return [self configureAlbumDetails:cell];
    }
    
    static NSString *TrackDetailCellIdentifier = @"TrackDetailCell";
    
    SLAlbumTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:TrackDetailCellIdentifier];
    if (cell == nil) {
        cell = [[SLAlbumTrackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TrackDetailCellIdentifier];
    }

    return [self configureAlbumTrack:cell indexPath:indexPath];
}

- (SLAlbumDetailsCell *)configureAlbumDetails:(SLAlbumDetailsCell *)albumDetailsCell {
    [albumDetailsCell configureAlbumDetailCell:self.albumDetails];
    
    return albumDetailsCell;
}

- (SLAlbumTrackCell *)configureAlbumTrack:(SLAlbumTrackCell *)albumTrackCell indexPath:(NSIndexPath *)indexPath {
    albumTrackCell.backgroundColor = [self getGradientColorWith:indexPath.row];
    [albumTrackCell configureAlbumTrackCell:self.tracks[indexPath.row]];
    
    return albumTrackCell;
}

- (ShortListAlbum *)getShortListAlbum {
    for (ShortListAlbum *slAlbum in self.shortList.shortListAlbums) {
        if (slAlbum.albumId == self.albumDetails.collectionId) {
            return slAlbum;
        }
    }
    
    return nil;
}

#pragma mark - Add to Shortlist
- (void)addAlbumToShortList {
    __weak typeof(self) weakSelf = self;
    
    [SLParseController getShortListAlbums:self.shortList completion:^(NSArray *allAlbums) {
        ShortListAlbum *slAlbum = [ShortListAlbum createShortListAlbum:weakSelf.albumDetails];
        slAlbum.shortListId = weakSelf.shortList.objectId;
        slAlbum.shortListRank = allAlbums.count + 1;

        [SLParseController addAlbumToShortList:slAlbum shortlist:weakSelf.shortList completion:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

#pragma mark - Remove from Shortlist
- (void)removeAlbumFromShortList {
    __weak typeof(self) weakSelf = self;
    [SLParseController removeAlbumFromShortList:self.shortList shortlistAlbum:[self getShortListAlbum] completion:^(NSArray *albums) {
        weakSelf.shortList.shortListAlbums = albums;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - Coloring
- (UIColor *)getGradientColorWith:(NSInteger)row {
    UIColor *color = [self.coverImageView.image averageColor];
    CGFloat hue = 0.0;
    [color getHue:&hue saturation:nil brightness:nil alpha:nil];
    
    return [[UIColor alloc] initWithHue:hue saturation:([self.tracks count] - row)/25.0 brightness:1.0 alpha:.9];
}

@end
