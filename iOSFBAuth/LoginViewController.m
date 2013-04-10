//
//  LoginViewController.m
//  iOSFBAuth
//
//  Created by Prabir Shrestha on 4/10/13.
//  Copyright (c) 2013 thuzi. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <Facebook.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    // Check the session for a cached token to show the proper authenticated
    // UI. However, since this is not user intitiated, do not show the login UX.
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        NSArray *noticeObject = notification.object;
        // noticeObject[3] -> isRead
        // noticeObject[4] -> allowLoginUI
        if([[noticeObject objectAtIndex:3] boolValue] && [[noticeObject objectAtIndex:4] boolValue]) {
            dispatch_async(dispatch_get_current_queue(), ^{
                AppDelegate *delegate = [UIApplication sharedApplication].delegate;
                // not a good pattern to ask for publish perms here.
                // it is recommended to ask only when you actually need it
                [delegate openPublishSessionWithAllowLoginUI:YES];
                [self gotoAuthenticatedView];
            });
        }
    } else {
        // user logged out
    }
}

- (IBAction)loginTap:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (FBSession.activeSession.isOpen) {
        [self gotoAuthenticatedView];
    } else {
        // The user has initiated a login, so call the openSession method
        // and show the login UX if necessary.
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
}

- (void)gotoAuthenticatedView {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Logout VC"];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
