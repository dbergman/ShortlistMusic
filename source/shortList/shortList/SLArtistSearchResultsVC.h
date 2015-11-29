//
//  SLSearchResultsVC.h
//  shortList
//
//  Created by Dustin Bergman on 5/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLShortlist;

@interface SLArtistSearchResultsVC : UITableViewController

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) SLShortlist *shortList;

@end
