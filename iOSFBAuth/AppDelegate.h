//
//  AppDelegate.h
//  iOSFBAuth
//
//  Created by Prabir Shrestha on 4/10/13.
//  Copyright (c) 2013 thuzi. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (BOOL)openPublishSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;

@end
