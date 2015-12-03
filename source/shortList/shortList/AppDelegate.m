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

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dus.shortList" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"shortList" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"shortList.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
