//
//  thzAppDelegate.m
//  FBSimpleSample
//
//  Created by JOEY SCHLUCHTER on 1/16/12.
//  Copyright (c) 2012 Thuzi, LLC. All rights reserved.
//

#import "thzAppDelegate.h"
#import "thzViewController.h"

static NSString* kAppId = @"328595423827568";

@implementation thzAppDelegate
@synthesize window = _window;
@synthesize facebook;


- (void)dealloc
{
    [_window release];
    [facebook release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    thzViewController *vc = [[thzViewController alloc] init];
        
    // Initialize Facebook
    facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:vc];
    //self.window.rootViewController = vc;
    //[vc release];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark Facebook

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url];
}


@end
