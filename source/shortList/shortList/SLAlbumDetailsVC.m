//
//  SLAlbumDetailsVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/3/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLAlbumDetailsVC.h"
#import "ItunesTrack.h"
#import "UIImage+AverageColor.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SLAlbumDetailsVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *coverImageView;

@end

@implementation SLAlbumDetailsVC

- (instancetype)initWithAlbumName:(NSString *)albumName Tracks:(NSArray *)tracks {
    self = [super init];
    if (self) {
        self.albumName = albumName;
        self.tracks = tracks;
        
        ItunesTrack *firstTrack = (ItunesTrack *)[tracks firstObject];
        self.coverImageView = [UIImageView new];
        NSURL *albumArtURL = [NSURL URLWithString:[firstTrack.artworkUrl100 stringByReplacingOccurrencesOfString:@"100x100-75.jpg" withString:@"400x400-75.jpg"]];
        [self.coverImageView sd_setImageWithURL:albumArtURL];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:self.albumName];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UITableView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    [self.view addSubview:self.tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    ItunesTrack *track = [self.tracks objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [self getGradientColorWith:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = track.trackName;
    
    return cell;
}

- (UIColor *)getGradientColorWith:(NSInteger)row {
    UIColor *color = [self.coverImageView.image averageColor];
    CGFloat hue = 0.0;
    [color getHue:&hue saturation:nil brightness:nil alpha:nil];
    return [[UIColor alloc] initWithHue:hue saturation:([self.tracks count] - row)/25.0 brightness:1.0 alpha:1.0];
}

-(void)dealloc {
}

@end
