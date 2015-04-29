//
//  SLListsVC.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLListsVC.h"
#import "ItunesSearchAPIController.h"

@interface SLListsVC ()

@end

@implementation SLListsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[ItunesSearchAPIController sharedManager] getSearchResultsWithBlock:@"beatles" completion:^(id responseObject, NSError *error) {
//        NSLog(@"");
//    }];
    
//    [[ItunesSearchAPIController sharedManager] getAlbumsForArtist:@136975 completion:^(id responseObject, NSError *error) {
//        NSLog(@"");
//    }];
    
    [[ItunesSearchAPIController sharedManager] getTracksForAlbumID:@"401186200" completion:^(id responseObject, NSError *error) {
        NSLog(@"");
    }];
    
    
}

@end
