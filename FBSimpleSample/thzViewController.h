//
//  thzViewController.h
//  FBSimpleSample
//
//  Created by JOEY SCHLUCHTER on 1/16/12.
//  Copyright (c) 2012 Thuzi, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface thzViewController : UIViewController <UIWebViewDelegate, FBSessionDelegate>{
    UIWebView *webView;
}
@property (nonatomic,retain) IBOutlet UIButton *btnLogin;
@property (nonatomic,retain) IBOutlet UIButton *btnShowLike;
@property (nonatomic,retain) IBOutlet UIButton *btnHideLike;
@property (nonatomic,retain) UIWebView *webView;

-(IBAction)login;
-(IBAction)showLike;
-(IBAction)hideLike;
@end
