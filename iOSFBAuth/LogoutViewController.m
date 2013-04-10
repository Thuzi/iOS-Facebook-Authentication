//
//  LogoutViewController.m
//  iOSFBAuth
//
//  Created by Prabir Shrestha on 4/10/13.
//  Copyright (c) 2013 thuzi. All rights reserved.
//

#import "LogoutViewController.h"
#import "AppDelegate.h"

@interface LogoutViewController ()

@end

@implementation LogoutViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)logoutTap:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate closeSession];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
