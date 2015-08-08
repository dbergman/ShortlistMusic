//
//  SLPlayNowController.m
//  shortList
//
//  Created by Dustin Bergman on 8/8/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLPlayNowViewController.h"
#import "ItunesTrack.h"
#import "SLStyle.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SLPlayNowViewController ()

@property (nonatomic, strong) ItunesTrack *albumDetails;
@property (nonatomic, strong) UILabel *albumTitleLabel;
@property (nonatomic, strong) UILabel *artistTitleLabel;
@property (nonatomic, strong) UIImageView *albumArtView;

@end

@implementation SLPlayNowViewController

- (instancetype)initWithAlbum:(ItunesTrack *)albumDetails {
    self = [super init];
    if (self) {
        self.albumDetails = albumDetails;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor orangeColor];
    
    self.albumTitleLabel = [UILabel new];
    self.artistTitleLabel = [UILabel new];
    self.albumArtView = [UIImageView new];
    
    
    
    
    
}


@end
