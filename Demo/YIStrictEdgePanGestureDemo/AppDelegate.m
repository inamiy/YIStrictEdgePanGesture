//
//  AppDelegate.m
//  YIStrictEdgePanGestureDemo
//
//  Created by Yasuhiro Inami on 2014/03/15.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

#import "AppDelegate.h"
#import "YIStrictEdgePanGesture.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UITabBarController* tabC = (id)self.window.rootViewController;
        
        for (NSInteger i = 0; i < tabC.viewControllers.count; i++) {
            UINavigationController* navC = tabC.viewControllers[i];
            [navC.topViewController performSegueWithIdentifier:@"PushSegue" sender:self];
            
            if (i == 1) {
                UIScreenEdgePanGestureRecognizer* popGesture = (id)navC.interactivePopGestureRecognizer;
                popGesture.usesStrictMode = NO;
            }
        }
    });
    
    // Override point for customization after application launch.
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
