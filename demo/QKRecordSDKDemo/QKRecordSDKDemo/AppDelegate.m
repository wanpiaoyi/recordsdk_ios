//
//  AppDelegate.m
//  QKRecordSDKDemo
//
//  Created by yangpeng on 2020/7/13.
//  Copyright © 2020 yangpeng. All rights reserved.
//

#import "AppDelegate.h"
#import "QKRecordViewController.h"
#import "Commav.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    UIViewController *root = [[QKRecordViewController alloc] init];
    self.window.rootViewController = [[Commav alloc] initWithRootViewController:root];;

    return YES;
}



@end
