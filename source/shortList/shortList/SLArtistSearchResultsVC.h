//
//  SLSearchResultsVC.h
//  shortList
//
//  Created by Dustin Bergman on 5/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ArtistResultsCompletionBlock)(NSString *artistName, NSArray *albums);

@interface SLArtistSearchResultsVC : UITableViewController

@property (nonatomic, strong) NSArray *searchResults;

- (instancetype)initWithCompletion:(ArtistResultsCompletionBlock)completion;

@end
