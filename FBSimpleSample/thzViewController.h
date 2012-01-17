//
//  thzViewController.h
//  FBSimpleSample
//
//  Created by JOEY SCHLUCHTER on 1/16/12.
//  Copyright (c) 2012 Thuzi, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface thzViewController : UIViewController <UIWebViewDelegate, FBSessionDelegate>
@property (nonatomic,retain) IBOutlet UIButton *btnLogin;
@property (nonatomic,retain) IBOutlet UIWebView *wv;


-(IBAction)login;
-(IBAction)reloadWebView;
@end
