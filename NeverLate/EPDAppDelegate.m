//
//  EPDAppDelegate.m
//  NeverLate
//
//  Created by Endika Gutiérrez Salas on 3/29/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "EPDAppDelegate.h"

#import "iRate.h"
#import "ECSlidingViewController.h"

@implementation EPDAppDelegate

@synthesize window = _window;

+ (void)initialize
{
	//set the app and bundle ID. normally you wouldn't need to do this
    //but we need to test with an app that's actually on the store
	//[iRate sharedInstance].appStoreID = 355313284;
    //[iRate sharedInstance].applicationBundleID = @"com.charcoaldesign.rainbowblocks";
	
    [iRate sharedInstance].messageTitle = @"Vota NeverLate";
    [iRate sharedInstance].message = @"Sí te gusta NeverLate ayudanos valorando NeverLate en la AppStore. No te llevará más de un minuto. ¡Gracias!";
    
    //enable debug mode
    //[iRate sharedInstance].debug = YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;

    ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.window.rootViewController;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"RootTabBar"];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
