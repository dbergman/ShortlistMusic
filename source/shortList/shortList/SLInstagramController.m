//
//  SLInstagramController.m
//  shortList
//
//  Created by Dustin Bergman on 8/16/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLInstagramController.h"
#import "Shortlist.h"

@interface SLInstagramController () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation SLInstagramController

+ (id)sharedInstance {
    static SLInstagramController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [SLInstagramController new];
    });
    
    return sharedInstance;
}

- (void)shareShortlistToInstagram:(Shortlist *)shortlist albumArtCollectionImage:(UIImage *)albumArtCollectionImage attachToView:(UIView *)attachView {
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *saveImagePath = [documentDirectory stringByAppendingPathComponent:@"Image.igo"];
    NSData *imageData = UIImagePNGRepresentation(albumArtCollectionImage);
    [imageData writeToFile:saveImagePath atomically:YES];
    
    NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
    
    self.documentController = [[UIDocumentInteractionController alloc] init];

    self.documentController.delegate=self;
    self.documentController.UTI=@"com.instagram.photo";
    [self.documentController setURL:imageURL];
    self.documentController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:@"#yourHashTagGoesHere",@"InstagramCaption", nil];
    [self.documentController presentOpenInMenuFromRect:CGRectZero inView:attachView animated:YES];
}

@end
