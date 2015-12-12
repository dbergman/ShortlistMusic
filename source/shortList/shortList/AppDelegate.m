//
//  AppDelegate.m
//  shortList
//
//  Created by Dustin Bergman on 4/26/15.
//  Copyright (c) 2015 Dustin Bergman. All rights reserved.
//

#import "AppDelegate.h"
#import "SLNavigationController.h"
#import "SLTabBarController.h"
#import "SLFeedVC.h"
#import "SLListsVC.h"
#import "SLProfileVC.h"
#import "SLMoreVC.h"
#import "SLStyle.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SLShortlist.h"
#import "SLShortListAlbum.h"
#import "SLStyle.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import <Parse/Parse.h>

@interface AppDelegate ()



@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [self turnOnNSURLCache];
    [self setUpParse];
    [self setupAppearance];
    
    self.window.rootViewController = [self shortListTabController];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
    [[PFFacebookUtils session] close];
}

- (UIViewController *)shortListTabController {
    SLFeedVC *slFeedVC = [SLFeedVC new];
    SLNavigationController *shortListFeedNav = [[SLNavigationController alloc] initWithRootViewController:slFeedVC];
    shortListFeedNav.tabBarItem.title = NSLocalizedString(@"Feed", nil);

    SLListsVC *slListsVC = [SLListsVC new];
    SLNavigationController *shortListsNav = [[SLNavigationController alloc] initWithRootViewController:slListsVC];
    shortListsNav.tabBarItem.title = NSLocalizedString(@"ShortLists", nil);
    shortListsNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"myShortLists"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    shortListsNav.tabBarItem.image = [[UIImage imageNamed:@"myShortLists"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    SLProfileVC *slProfileVC = [SLProfileVC new];
    SLNavigationController *shortListProfileNav = [[SLNavigationController alloc] initWithRootViewController:slProfileVC];
    shortListProfileNav.tabBarItem.title = NSLocalizedString(@"Profile", nil);
    
    SLMoreVC *slMoreVC = [SLMoreVC new];
    SLNavigationController *shortListMoreNav = [[SLNavigationController alloc] initWithRootViewController:slMoreVC];
    shortListMoreNav.tabBarItem.title = NSLocalizedString(@"More", nil);
    shortListMoreNav.tabBarItem.selectedImage = [[UIImage imageNamed:@"moreTab"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    shortListMoreNav.tabBarItem.image = [[UIImage imageNamed:@"moreTab"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    SLTabBarController *tabBarController = [SLTabBarController new];
    //[tabBarController setViewControllers:@[shortListFeedNav, shortListsNav, shortListProfileNav, shortListMoreNav]];
    [tabBarController setViewControllers:@[shortListsNav, shortListMoreNav]];
    tabBarController.tabBar.backgroundColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;

    tabBarController.selectedViewController=[tabBarController.viewControllers objectAtIndex:0];

    return tabBarController;
}

- (void)setUpParse {
    NSDictionary *appKeys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"appKeys" ofType:@"plist"]];
    NSAssert(appKeys, @"You Must Add /opt/shortList/appKeys to your local File System!!!");

    [Parse setApplicationId:appKeys[@"ParseAppId"] clientKey:appKeys[@"ParseClientKey"]];
    [PFFacebookUtils initializeFacebook];

    [SLShortlist registerSubclass];
    [SLShortListAlbum registerSubclass];
}

- (void)setupAppearance {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:YES];

    [[UITabBar appearance] setTintColor:[UIColor sl_Red]];
    
    [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.xSmall]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor sl_Red], NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.xSmall]} forState:UIControlStateSelected];
    
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor sl_Red]];
    NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [SLStyle polarisFontWithSize:FontSizes.medium] , NSForegroundColorAttributeName: [UIColor whiteColor]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url  sourceApplication:sourceApplication  withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)turnOnNSURLCache {
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024  diskCapacity:100 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

@end
