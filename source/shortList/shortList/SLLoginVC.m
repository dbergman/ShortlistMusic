//
//  SLLoginVC.m
//  shortList
//
//  Created by Dustin Bergman on 5/13/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "SLLoginVC.h"
#import "SLStyle.h"
#import "UIViewController+SLToastBanner.h"
#import <Facebook-iOS-SDK/FacebookSDK/FBRequest.h>
#import <Parse/Parse.h>
#import "shortList-Swift.h"
#import <ParseTwitterUtils.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


@interface SLLoginVC () <PFLogInViewControllerDelegate>

@property (nonatomic, copy) SLLoginCompletionBlock completion;

@end

@implementation SLLoginVC

- (instancetype)initWithCompletion:(SLLoginCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.logInView.logo = [SLLoginVC getTempLogo:self.logInView.logo.frame];
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PFUser currentUser]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark PFLogInViewControllerDelegate
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    BOOL linkedWithFacebook = [PFFacebookUtils isLinkedWithUser:user];
    BOOL linkedWithTwitter = [PFTwitterUtils isLinkedWithUser:user];

    if (linkedWithFacebook) {
        [self facebookUserCheck:user isLoggedIn:YES];
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(PFUI_NULLABLE NSError *)error {
    [self sl_showToastForAction:NSLocalizedString(@"Login Failed", nil) message:NSLocalizedString(@"Invalid ID or password.", nil) toastType:SLToastMessageFailure completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookUserCheck:(PFUser *)pfuser isLoggedIn:(BOOL)isLoggedIn {
    FBRequest *request = [FBRequest requestForMe];
    __weak typeof(self)weakSelf = self;
    __weak typeof(PFUser *)weakUser = pfuser;
    [request startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user,  NSError *error) {
        if (!error) {
            __block NSString *fbId = [user objectForKey:@"id"];
            [SLParseController doesSocialIdExist:fbId tryfacebook:YES checkAction:^(BOOL exists) {
                if (exists) {
                    if (weakSelf.completion) {
                        weakSelf.completion(weakUser, isLoggedIn);
                    }
                }
                else {
                    [weakSelf createUsernameforUser:weakUser forFacebook:YES socialId:fbId];
                }
            }];
        }
    }];
}

- (void)createUsernameforUser:(PFUser *)user forFacebook:(BOOL)forFace socialId:(NSString *)socialId {
    __weak typeof(self)weakSelf = self;
    SLEnterUserNameVC *vc = [[SLEnterUserNameVC alloc] initWithUser:user onSuccess:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
////THIS NEEDS WORK/////// not saving ID
        user[(forFace) ? @"facebookId" : @"twitterId"] = socialId;

    } onCancel:^{
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [PFUser logOut];
        }];
    }];
    
    [self showViewController:vc sender:self];
}

+ (UILabel *)getTempLogo:(CGRect)parseLogoFrame {
    UILabel *logoLabel = [UILabel new];
    logoLabel.frame = parseLogoFrame;
    logoLabel.backgroundColor = [UIColor clearColor];
    logoLabel.textColor = [UIColor sl_Red];
    logoLabel.font = [SLStyle polarisFontWithSize:28.0];
    logoLabel.text = @"ShortList Music";
    
    return logoLabel;
}

@end
