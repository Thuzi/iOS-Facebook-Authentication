//
//  AppDelegate.m
//  iOSFBAuth
//
//  Created by Prabir Shrestha on 4/10/13.
//  Copyright (c) 2013 thuzi. All rights reserved.
//

#import "AppDelegate.h"
#import <Facebook.h>

NSString *const FBSessionStateChangedNotification = @"com.example.iOSFBAuth:FBSessionStateChangedNotification";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // We open the session up front, as long as we have a cached token, otherwise rely on the user
    // to login explicitly
    [FBSession openActiveSessionWithAllowLoginUI:NO];

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
    
    // It is possible for the user to switch back to your application, from the native Facebook application,
    // when the user is part-way through a login; You can check for the FBSessionStateCreatedOpenening
    // state in applicationDidBecomeActive, to identify this situation and close the session; a more sophisticated
    // application may choose to notify the user that they switched away from the Facebook application without
    // completely logging in
    
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Whether it is in applicationWillTerminate, in applicationDidEnterBackground, or in some other part
    // of your application, it is important that you close an active session when it is no longer useful
    // to your application; if a session is not properly closed, a retain cycle may occur between the block
    // and an object that holds a reference to the session object; close releases the handler, breaking any
    // inadvertant retain cycles
    
    // if the app is going away, we close the session if it is open
    // this is a good idea because things may be hanging off the session, that need
    // releasing (completion block, etc.) and other components in the app may be awaiting
    // close notification in order to do cleanup
    [FBSession.activeSession close];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // The native facebook application transitions back to an authenticating application when the user
    // chooses to either log in, or cancel. The url passed to this method contains the token in the
    // case of a successful login. By passing the url to the handleOpenURL method of a session object
    // the session object can parse the URL, and capture the token for use by the rest of the authenticating
    // application; the return value of handleOpenURL indicates whether or not the URL was handled by the
    // session object, and does not reflect whether or not the login was successful; the session object's
    // state, as well as its arguments passed to the state completion handler indicate whether the login
    // was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
    // will be boolean NO, meaning the URL was not handled by the authenticating application
    
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

# pragma mark - facebook

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
                     isRead:(BOOL)isRead
               allowLoginUI:(BOOL)allowLoginUI
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:@[session ? session : [NSNull null], @(state), error ? error : [NSNull null], @(isRead), @(allowLoginUI)]];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            @"user_likes",
                            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error
                                                                isRead:YES
                                                          allowLoginUI:allowLoginUI];
                                         }];
    
//    return [FBSession openActiveSessionWithReadPermissions:nil
//                                              allowLoginUI:allowLoginUI
//                                         completionHandler:^(FBSession *session,
//                                                             FBSessionState state,
//                                                             NSError *error) {
//                                             [self sessionStateChanged:session
//                                                                 state:state
//                                                                 error:error];
//                                         }];
}

- (BOOL)openPublishSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                                 allowLoginUI:allowLoginUI
                                            completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                                [self sessionStateChanged:session state:status error:error isRead:NO allowLoginUI:allowLoginUI];
                                            }];
}

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

@end
