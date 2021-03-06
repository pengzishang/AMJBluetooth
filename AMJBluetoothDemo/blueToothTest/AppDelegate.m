//
//  AppDelegate.m
//  blueToothTest
//
//  Created by 彭子上 on 2016/11/25.
//  Copyright © 2016年 彭子上. All rights reserved.
//

#import "AppDelegate.h"
#import "BlueToothObject.h"
#import "BlueToothPeripheral.h"
#import <Bugly/Bugly.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //不要在这里修改增加内容
    [[BlueToothPeripheral getInstance]effect];
    [[BluetoothManager getInstance] effect];
#if defined (DEBUG)|| defined (_DEBUG)//开发环境
#else
    [Bugly startWithAppId:@"3dfac8d9e0"];
#endif
//    [[UIApplication sharedApplication] performSelector:@selector(suspend)];系统私有方法
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
