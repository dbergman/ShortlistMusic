//
//  UIViewController+SLEmailShortlist.m
//  shortList
//
//  Created by Dustin Bergman on 8/15/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "UIViewController+SLEmailShortlist.h"
#import "SLShortlist.h"
#import "SLShortListAlbum.h"
#import "SLStyle.h"
#import "UIViewController+SLToastBanner.h"
#import <MessageUI/MessageUI.h>

@interface UIViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation UIViewController (SLEmailShortlist)

- (void)shareShortlistByEmail:(SLShortlist *)shortlist albumArtCollectionImage:(UIImage *)albumArtCollectionImage {
    if ([MFMailComposeViewController canSendMail]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
            mailComposeVC.mailComposeDelegate = self;

            NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.large], NSForegroundColorAttributeName: [UIColor whiteColor]};
            [[mailComposeVC navigationBar] setTitleTextAttributes:barButtonAppearanceDict];
            [[mailComposeVC navigationBar] setBarTintColor:[UIColor blackColor]];
            [[mailComposeVC navigationBar] setTintColor:[UIColor whiteColor]];
            
            [mailComposeVC setSubject:[NSString stringWithFormat:@"ShortListMusic: %@", shortlist.shortListName]];
            [mailComposeVC setMessageBody:[self createShortListEmailBody:shortlist] isHTML:YES];
            
            NSData *albumArtCollectionImageData = UIImageJPEGRepresentation(albumArtCollectionImage, 1);
            
            NSString *fileName = @"albumArtCollectionImage";
            fileName = [fileName stringByAppendingPathExtension:@"jpeg"];
            [mailComposeVC addAttachmentData:albumArtCollectionImageData mimeType:@"image/jpeg" fileName:fileName];

            [self presentViewController:mailComposeVC animated:YES completion:nil];
        });
    }
}

- (void)contactMeEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
        mailComposeVC.mailComposeDelegate = self;
        
        NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.large], NSForegroundColorAttributeName: [UIColor whiteColor]};
        [[mailComposeVC navigationBar] setTitleTextAttributes:barButtonAppearanceDict];
        [[mailComposeVC navigationBar] setBarTintColor:[UIColor blackColor]];
        [[mailComposeVC navigationBar] setTintColor:[UIColor whiteColor]];
        
        [mailComposeVC setToRecipients:@[@"shortlistapp01@gmail.com"]];
        [mailComposeVC setSubject:[NSString stringWithFormat:@"Hey Mr.ShortListMusic: "]];

        [self presentViewController:mailComposeVC animated:YES completion:nil];
    }
}
- (NSString *)createShortListEmailBody:(SLShortlist *)shortlist {
    NSString *theEmail = @"";
    NSString *htmlStart = @"<html>";
    NSString *header = @"<head> <style> td, th {  border: 1px solid #E0E0E0 ; } table {  border-collapse: collapse; }  </style> </head><body>";
    NSString *beginTable = @"<table>";
    
    NSString *shortListTitleRow =[NSString stringWithFormat:@"<tr><td colspan = 3><b><font size=\"2\">%@</font></b></td></tr>", shortlist.shortListName];
    
    NSString *tableRow = @"";
    NSString *tableRows = @"";
    
    for (SLShortListAlbum *shortListAlbum in shortlist.shortListAlbums) {
        
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

#pragma maek MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    dispatch_block_t toastAction = ^{};
    if (error) {
        toastAction = ^{
            [self sl_showToastForAction:NSLocalizedString(@"Error Sending Email", nil) message:error.description toastType:SLToastMessageFailure completion:nil];
        };
    }
    else if (result == MFMailComposeResultSent) {
        toastAction = ^{
            [self sl_showToastForAction:NSLocalizedString(@"Sent ShortList Email", nil) message:nil toastType:SLToastMessageSuccess completion:nil];
        };
    }
    else if (result == MFMailComposeResultFailed) {
        toastAction = ^{
            [self sl_showToastForAction:NSLocalizedString(@"Failed Sending Email", nil) message:nil toastType:SLToastMessageFailure completion:nil];
        };
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
        if (toastAction) {
            toastAction();
        }
    }];
}

@end
