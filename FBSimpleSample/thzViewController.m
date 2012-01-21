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

@synthesize btnLogin, btnShowLike, btnHideLike, webView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    thzAppDelegate *delegate = (thzAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"FBAccessTokenKey"]
       && [defaults objectForKey:@"FBExpirationDateKey"]){
        [delegate facebook].accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        [delegate facebook].expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![[delegate facebook] isSessionValid])
    {
        [btnLogin setImage:[UIImage imageNamed:@"fbLogin.jpg"] forState:UIControlStateNormal];
        [btnShowLike setHidden:YES];
        [btnHideLike setHidden:YES];
    }
    else{
        [btnLogin setImage:[UIImage imageNamed:@"fbLogOut.jpg"] forState:UIControlStateNormal];
        [btnShowLike setHidden:NO];
        [btnHideLike setHidden:YES];
    }
}

#pragma mark Facebook req'd && callbacks

-(void)fbDidLogin{
    
    thzAppDelegate *delegate = (thzAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[delegate facebook] accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[[delegate facebook] expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

-(void)fbDidLogout{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"FBAccessTokenKey"];
    [defaults setObject:nil forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
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
        // [[delegate facebook] authorize:permissions];
        [[delegate facebook] myAuthorize:permissions];
        [btnLogin setImage:[UIImage imageNamed:@"fbLogOut.jpg"] forState:UIControlStateNormal];
        [btnShowLike setHidden:NO];
    }
    else{
        [btnLogin setImage:[UIImage imageNamed:@"fbLogin.jpg"] forState:UIControlStateNormal];
        [btnShowLike setHidden:YES];
        [[delegate facebook] logout];
    }
}

-(void)showLike{
    //UIWebView *webView;
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 80, 320, 300)];
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    [webView setDelegate:self];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"like" ofType:@"html"]isDirectory:NO]]];
    
    [self.view addSubview:webView];
    
    //[webView release], webView = nil;
    [btnShowLike setHidden:YES];
    [btnHideLike setHidden:NO];
}

-(void)hideLike{
    [btnHideLike setHidden:YES];
    [btnShowLike setHidden:NO];
    [self.webView removeFromSuperview];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"loading");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"load complete");
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
