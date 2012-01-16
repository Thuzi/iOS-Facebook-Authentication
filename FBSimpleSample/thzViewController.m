//
//  thzViewController.m
//  FBSimpleSample
//
//  Created by JOEY SCHLUCHTER on 1/16/12.
//  Copyright (c) 2012 Thuzi, LLC. All rights reserved.
//

#import "thzViewController.h"

@implementation thzViewController

@synthesize facebook, wv, btnLogin;

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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [facebook handleOpenURL:url];
}

-(void)fbDidLogin{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [btnLogin setTitle:@"Logout" forState:UIControlStateNormal];
    //load up the web view from the like.html file
    [wv loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"like" ofType:@"html"]isDirectory:NO]]];
    [self.view addSubview:wv];
}

-(void)fbDidLogout{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"FBAccessTokenKey"];
    [defaults setObject:nil forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
}

-(void)login{
    facebook = [[Facebook alloc] initWithAppId:@"YOUR_APP_ID" andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"FBAccessTokenKey"]
       && [defaults objectForKey:@"FBExpirationDateKey"]){
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![facebook isSessionValid])
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"user_likes", @"user_about_me", nil];
        [facebook authorize:permissions];
        
    }
    else{
        [facebook logout];
    }
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
