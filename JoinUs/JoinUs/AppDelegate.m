//
//  AppDelegate.m
//  JoinUs
//
//  Created by Liang Qian on 17/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "AppDelegate.h"
#import "Utils.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set app-wide shared cache (first number is megabyte value)
    NSUInteger cacheSizeMemory = 256*1024*1024; // 256 MB
    NSUInteger cacheSizeDisk = 512*1024*1024; // 512 MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    sleep(1); // Critically important line, sadly, but it's worth it!
    
    NSLog(@"DiskCache: %@ of %@", @([[NSURLCache sharedURLCache] currentDiskUsage]), @([[NSURLCache sharedURLCache] diskCapacity]));
    NSLog(@"MemoryCache: %@ of %@", @([[NSURLCache sharedURLCache] currentMemoryUsage]), @([[NSURLCache sharedURLCache] memoryCapacity]));
    
    
    // Tab bar tint color
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    
    // nav bar backgroud color
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRGBValue:0x1093f6]];
    // nav bar item button color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // nav bar title color
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // Programtically create Tab bar
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    
//    UIViewController* personalViewController = [[UIViewController alloc] init];
//    personalViewController.view.backgroundColor = [UIColor whiteColor];
//    UINavigationController* personalNavigationController = [[UINavigationController alloc] initWithRootViewController:personalViewController];
//    
//    personalNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"tab_bar_button_test"] selectedImage:[UIImage imageNamed:@"tab_bar_button_test_selected"]];
//    
//    UIViewController* homeViewController = [[UIViewController alloc] init];
//    homeViewController.view.backgroundColor = [UIColor whiteColor];
//
//    UINavigationController* homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
//    
//    homeNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[[UIImage imageNamed:@"tab_bar_button_test1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_bar_button_test1_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    
//    UITabBarController* tabBarController = [[UITabBarController alloc] init];
//    tabBarController.viewControllers = @[homeNavigationController,personalNavigationController];
//    
//    self.window.rootViewController = tabBarController;
//    [self.window makeKeyAndVisible];
    
    // create a new toast style
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    // this is just one of many style options
    style.messageColor = [UIColor whiteColor];
    // just set the shared style and there's no need to provide the style again
    [CSToastManager setSharedStyle:style];
    // toggle "tap to dismiss" functionality
    [CSToastManager setTapToDismissEnabled:YES];
    // toggle queueing behavior
    [CSToastManager setQueueEnabled:YES];
    // set default postion
    [CSToastManager setDefaultPosition:CSToastPositionCenter];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
