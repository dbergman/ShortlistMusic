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
#import "UIViewController+Utilities.h"
#import "UIViewController+SLPlayNow.h"
#import "SpotifySearchApiController.h"
#import "SpotifyAlbums.h"
#import "SpotifyAlbum.h"

static CGFloat const kSLAlbumDetailsCellHeight = 65.0;
static CGFloat const kSLPlayButtonSize = 50.0;

@interface SLAlbumDetailsVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) ItunesTrack *albumDetails;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) Shortlist *shortList;
@property (nonatomic, strong) UIButton *playNowButton;
@property (nonatomic, assign) BOOL isPlayingOptionsShown;
@property (nonatomic, strong) UIImageView *blurBackgroundView;
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
    [[SpotifySearchApiController sharedManager] spotifySearchByArist:self.albumDetails.artistName album:self.albumDetails.collectionName completion:^(SpotifyAlbums *albums, NSError *error) {
        weakSelf.albumDetails.spotifyDeepLink = [(SpotifyAlbum *)albums.albumResults.firstObject spotifyAlbumUrl];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:([self getShortListAlbum])? NSLocalizedString(@"Remove", nil) : NSLocalizedString(@"Add", nil) style:UIBarButtonItemStylePlain handler:^(id sender) {
        ([weakSelf getShortListAlbum]) ? [weakSelf removeAlbumFromShortList] : [weakSelf addAlbumToShortList];
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
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.coverImageView.frame = CGRectMake(0.0, [self getNavigationBarStatusBarHeight], [self getScreenWidth], [self getScreenWidth]);
    
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.coverImageView.frame) - kSLAlbumDetailsCellHeight, 0.0f, [self getTabBarHeight], 0.0f);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.albumDetails.artworkUrl600] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [weakSelf.view addSubview:weakSelf.tableView];

        [weakSelf buildPlayerViewControllerForAlbum:weakSelf.albumDetails];
        [weakSelf setupPlayNowButton];
        
        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.playNowButton removeFromSuperview];
}

- (void)setupPlayNowButton {
    self.playNowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playNowButton setImage:[UIImage imageNamed:@"playOptions"] forState:UIControlStateNormal];
    self.playNowButton.alpha = .8;
    self.playNowButton.backgroundColor = [self getGradientColorWith:0];
    self.playNowButton.layer.cornerRadius = kSLPlayButtonSize/2.0;
    self.playNowButton.layer.shadowRadius = 3.0f;
    self.playNowButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.playNowButton.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.playNowButton.layer.shadowOpacity = 0.5f;
    self.playNowButton.layer.masksToBounds = NO;
    self.playNowButton.frame = CGRectMake([self getScreenWidth]/2 - kSLPlayButtonSize/2, [self getScreenHeight] - [self getTabBarHeight] - MarginSizes.large - kSLPlayButtonSize, kSLPlayButtonSize, kSLPlayButtonSize);
        [self.navigationController.view addSubview:self.playNowButton];
    [self.playNowButton addTarget:self action:@selector(togglePlayerController) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 1 : self.tracks.count;
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

#pragma mark - PlayerOptionController
- (void)togglePlayerController {
    if (self.isPlayingOptionsShown) {
        [self hidePlayerView];
        [UIView animateWithDuration:.2 animations:^{
            self.blurBackgroundView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeBlurBackground];
            [self.playNowButton setImage:[UIImage imageNamed:@"playOptions"] forState:UIControlStateNormal];
        }];
    }
    else {
        [self addBlurBackground];
        [UIView animateWithDuration:.2 animations:^{
            self.blurBackgroundView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self showPlayerView];
            [self.playNowButton setImage:[UIImage imageNamed:@"closeOptions"] forState:UIControlStateNormal];
        }];
    }
    self.isPlayingOptionsShown = !self.isPlayingOptionsShown;
}

#pragma mark - Add to Shortlist
- (void)addAlbumToShortList {
    __weak typeof(self) weakSelf = self;
    
    [SLParseController getShortListAlbums:self.shortList completion:^(NSArray *allAlbums) {
        ShortListAlbum *slAlbum = [ShortListAlbum createShortListAlbum:weakSelf.albumDetails];
        slAlbum.shortListId = weakSelf.shortList.objectId;
        slAlbum.shortListRank = allAlbums.count + 1;

        [SLParseController addAlbumToShortList:slAlbum shortlist:weakSelf.shortList completion:^{
            [SLParseController getShortListAlbums:self.shortList completion:^(NSArray *allAlbums) {
                weakSelf.shortList.shortListAlbums = allAlbums;
                 [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
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

#pragma mark Blurring Methods
- (void)addBlurBackground {
    self.blurBackgroundView = [[UIImageView alloc] initWithImage:[self getBlurredScreenShot]];
    self.blurBackgroundView.userInteractionEnabled = YES;
    [self.view insertSubview:self.blurBackgroundView atIndex:2];
    self.blurBackgroundView.alpha = 0;
}

- (void)removeBlurBackground {
    [self.blurBackgroundView removeFromSuperview];
}

@end
