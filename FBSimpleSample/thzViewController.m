//
//  thzViewController.m
//  FBSimpleSample
//
//  Created by JOEY SCHLUCHTER on 1/16/12.
//  Copyright (c) 2012 Thuzi, LLC. All rights reserved.
//

#import "thzViewController.h"
#import "Facebook.h"
#import "thzAppDelegate.h"

@implementation thzViewController

@synthesize wv, btnLogin;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark Facebook req'd && callbacks

-(void)fbDidLogin{
    
    thzAppDelegate *delegate = (thzAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[delegate facebook] accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[[delegate facebook] expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self reloadWebView];
}

-(void)fbDidLogout{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"FBAccessTokenKey"];
    [defaults setObject:nil forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self reloadWebView];
}

-(void)login{
    thzAppDelegate *delegate = (thzAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"FBAccessTokenKey"]
       && [defaults objectForKey:@"FBExpirationDateKey"]){
        [delegate facebook].accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        [delegate facebook].expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![[delegate facebook] isSessionValid])
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"user_likes", @"user_about_me", nil];
        [[delegate facebook] authorize:permissions];
        [btnLogin setTitle:@"Logout" forState:UIControlStateNormal];
        
    }
    else{
        [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
        [[delegate facebook] logout];
    }
}

-(void)reloadWebView{
        [wv loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"like" ofType:@"html"]isDirectory:NO]]];
        [self.view addSubview:wv];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
