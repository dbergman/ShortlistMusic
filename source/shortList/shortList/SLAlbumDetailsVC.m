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
#import "SLShortlist.h"
#import "SLShortListAlbum.h"
#import "ItunesSearchTracks.h"
#import "shortList-Swift.h"
#import "UIViewController+Utilities.h"
#import "UIViewController+SLPlayNow.h"
#import "SpotifySearchApiController.h"
#import "ItunesSearchAPIController.h"
#import "SpotifyAlbums.h"
#import "SpotifyAlbum.h"
#import "MBProgressHUD.h"
#import "UIViewController+SLToastBanner.h"

static CGFloat const kSLAlbumDetailsCellHeight = 65.0;
static CGFloat const kSLPlayButtonSize = 50.0;

@interface SLAlbumDetailsVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *albumCollectionId;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) ItunesTrack *albumDetails;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) SLShortlist *shortList;
@property (nonatomic, strong) UIButton *playNowButton;
@property (nonatomic, assign) BOOL isPlayingOptionsShown;
@property (nonatomic, strong) UIImageView *blurBackgroundView;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SLAlbumDetailsVC

- (instancetype)initWithShortList:(SLShortlist *)shortList albumId:(NSString *)albumCollectionId {
    self = [super init];
    
    if (self) {
        self.shortList = shortList;
        self.albumCollectionId = albumCollectionId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    [self.hud showAnimated:YES];
    [self getAlbumDetails];

    self.coverImageView = [UIImageView new];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.coverImageView];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInsetAdjustmentBehavior = YES;
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

- (SLShortListAlbum *)getShortListAlbum {
    for (SLShortListAlbum *slAlbum in self.shortList.shortListAlbums) {
        
        NSString *albumId = [NSString stringWithFormat:@"%ld", (long)slAlbum.albumId];
        
        if ([albumId isEqualToString:self.albumDetails.collectionId]) {
            return slAlbum;
        }
    }
    
    return nil;
}

#pragma mark UI setup
- (void)setupNavigationController {
    NSString *spotifyDeeplinkUrl = [NSString stringWithFormat:@"spotify:search:%@", self.albumDetails.collectionName];
    NSString* encodedSpotifyDeeplinkUrl = [spotifyDeeplinkUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:encodedSpotifyDeeplinkUrl]]) {
        self.albumDetails.spotifyDeepLink = encodedSpotifyDeeplinkUrl;
    }
    
    [self buildPlayerViewControllerForAlbum:self.albumDetails];
    
    __weak typeof(self) weakSelf = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:([self getShortListAlbum]) ? NSLocalizedString(@"Remove", nil) : NSLocalizedString(@"Add", nil) style:UIBarButtonItemStylePlain handler:^(id sender) {
        ([weakSelf getShortListAlbum]) ? [weakSelf removeAlbumFromShortList] : [weakSelf addAlbumToShortList];
    }];
}

- (void)addAlbumArtWorkHeader {
    __weak typeof(self) weakSelf = self;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.albumDetails.artworkUrl600] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf.view addSubview:weakSelf.tableView];
        [weakSelf setupPlayNowButton];
    }];
}

#pragma mark networking
- (void)getAlbumDetails {
    __weak typeof(self)weakSelf = self;
    [[ItunesSearchAPIController sharedManager] getTracksForAlbumID:self.albumCollectionId completion:^(ItunesSearchTracks *albumSearchResults, NSError *error) {
        [weakSelf.hud removeFromSuperview];
        
        if (!error) {
            weakSelf.albumDetails = [albumSearchResults getAlbumInfo];
            weakSelf.tracks = [albumSearchResults getAlbumTracks];
            [weakSelf setTitle:weakSelf.albumDetails.collectionName];
            [weakSelf setupNavigationController];
            [weakSelf addAlbumArtWorkHeader];
        }
    }];
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
    [SLParseController getShortListAlbumsWithShortList:self.shortList completion:^(NSArray *allAlbums) {
        SLShortListAlbum *slAlbum = [SLShortListAlbum createShortListAlbum:weakSelf.albumDetails];
        slAlbum.shortListId = weakSelf.shortList.objectId;
        slAlbum.shortListRank = allAlbums.count + 1;

        [SLParseController addAlbumToShortListWithShortlistAlbum:slAlbum shortlist:weakSelf.shortList completion:^{
            [SLParseController getShortListAlbumsWithShortList: self.shortList completion:^(NSArray *allAlbums) {
                weakSelf.shortList.shortListAlbums = allAlbums;
                [weakSelf sl_showToastForAction:NSLocalizedString(@"Added", nil) message:weakSelf.albumDetails.collectionName toastType:SLToastMessageSuccess completion:^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }];
    }];
}

#pragma mark - Remove from Shortlist
- (void)removeAlbumFromShortList {
    __weak typeof(self) weakSelf = self;
    [SLParseController removeAlbumFromShortListWithShortList:self.shortList shortlistAlbum:[self getShortListAlbum] completion:^(NSArray *albums) {
        weakSelf.shortList.shortListAlbums = albums;
        [weakSelf reorderShortList];
        [SLParseController updateShortListAlbumsWithShortlist:weakSelf.shortList completion:^{
            [weakSelf sl_showToastForAction:NSLocalizedString(@"Removed", nil) message:weakSelf.albumDetails.collectionName toastType:SLToastMessageSuccess completion:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }];
}

- (void)reorderShortList {
    [self.shortList.shortListAlbums enumerateObjectsUsingBlock:^(SLShortListAlbum *album, NSUInteger idx, BOOL *stop) {
        album.shortListRank = idx + 1;
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
    [self.view addSubview:self.blurBackgroundView];
    self.blurBackgroundView.alpha = 0;
}

- (void)removeBlurBackground {
    [self.blurBackgroundView removeFromSuperview];
}

@end
