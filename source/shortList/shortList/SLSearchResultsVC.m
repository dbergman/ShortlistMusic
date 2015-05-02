//
//  SLSearchResultsVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/2/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLSearchResultsVC.h"
#import "ItunesArtist.h"

@interface SLSearchResultsVC ()

@end

@implementation SLSearchResultsVC

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
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setLayoutMargins:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

@end
