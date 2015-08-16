//
//  UIViewController+SLEmailShortlist.m
//  shortList
//
//  Created by Dustin Bergman on 8/15/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+SLEmailShortlist.h"
#import "Shortlist.h"
#import "ShortListAlbum.h"
#import "SLStyle.h"
#import <MessageUI/MessageUI.h>

@interface UIViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation UIViewController (SLEmailShortlist)

- (void)shareShortlistByEmail:(Shortlist *)shortlist {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
        mailComposeVC.mailComposeDelegate = self;

        NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.large], NSForegroundColorAttributeName: [UIColor whiteColor]};
        [[mailComposeVC navigationBar] setTitleTextAttributes:barButtonAppearanceDict];
        [[mailComposeVC navigationBar] setBarTintColor:[UIColor blackColor]];
        [[mailComposeVC navigationBar] setTintColor:[UIColor whiteColor]];
        
        [mailComposeVC setSubject:[NSString stringWithFormat:@"ShortListMusic: %@", shortlist.shortListName]];
        [mailComposeVC setMessageBody:[self createShortListEmailBody:shortlist] isHTML:YES];

        [self presentViewController:mailComposeVC animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    }
}

- (NSString *)createShortListEmailBody:(Shortlist *)shortlist {
    NSString *theEmail = @"";
    NSString *htmlStart = @"<html>";
    NSString *header = @"<head> <style> td, th {  border: 1px solid #E0E0E0 ; } table {  border-collapse: collapse; }  </style> </head><body>";
    NSString *beginTable = @"<table>";
    
    NSString *shortListTitleRow =[NSString stringWithFormat:@"<tr><td colspan = 3><b><font size=\"2\">%@</font></b></td></tr>", shortlist.shortListName];
    
    NSString *tableRow = @"";
    NSString *tableRows = @"";
    
    for (ShortListAlbum *shortListAlbum in shortlist.shortListAlbums) {
        
        tableRow = [NSString stringWithFormat:@"<tr>\n"
                    "<td rowspan = 2><font size=\"1\">%ld.</font></td> \n" //rank
                    "<td><b><font size=\"1\">%@</font></b></td> \n"             //album name
                    "</tr><tr><td><font size=\"1\">%@</font></td> \n"    //artistName
                    "</tr>"
                    , (long)shortListAlbum.shortListRank, [shortListAlbum.albumName substringToIndex: MIN(50, [shortListAlbum.albumName length])], [shortListAlbum.artistName substringToIndex: MIN(50, [shortListAlbum.artistName length])]];
        tableRows = [NSString stringWithFormat:@"%@%@",tableRows , tableRow];
    }
    
    NSString *endTable = @"</table>";
    NSString *footer = @"</body></html>";
    
    NSString *shortListTag = @"#shortListMusic";
    NSString *shortListTagFilter = [NSString stringWithFormat:@"#shortListMusic_%@", shortlist.shortListYear];
    
    theEmail = [NSString stringWithFormat:@" %@%@<br>%@%@%@%@%@ <br><font size=\"1\">%@</font><br><font size=\"1\">%@</font>", htmlStart, header, beginTable, shortListTitleRow,tableRows, endTable, footer,shortListTag, shortListTagFilter];
    
    return theEmail;
}

@end
