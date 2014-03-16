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
            
            UIScreenEdgePanGestureRecognizer* popGesture = (id)navC.interactivePopGestureRecognizer;
            
            if (i == 1) {
                popGesture.usesStrictMode = NO;
            }
            else if (i == 2) {
                popGesture.usesStrictMode = NO;
                
                //
                // DEMO:
                // Steal popGesture.delegate from _UINavigationInteractiveTransition
                // not to perform popGesture while content-scrollView is active (like Facebook 7.0 app).
                //
                navC.interactivePopGestureRecognizer.delegate = (id)self;
            }
        }
    });
    
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UITabBarController* tabC = (id)self.window.rootViewController;
    UINavigationController* navC = (id)tabC.selectedViewController;
    
    if (gestureRecognizer == navC.interactivePopGestureRecognizer) {
        
        UITableViewController* tableVC = (id)navC.topViewController;
        
        // don't perform popGesture while dragging
        if (tableVC.tableView.dragging) return NO;
        
        //
        // NOTE:
        // NEVER perform popGesture inside navigationController's rootViewController, or animation-lock occurs
        // (probably same as _UINavigationInteractiveTransition's implementation)
        //
        // http://stackoverflow.com/questions/19054625/changing-back-button-in-ios-7-disables-swipe-to-navigate-back/20330647#comment28683247_19133676
        //
        return [navC.viewControllers count] > 1;
        
    }
    return YES;
}

@end
