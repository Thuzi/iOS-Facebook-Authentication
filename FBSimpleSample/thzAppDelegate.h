//
//  thzAppDelegate.h
//  FBSimpleSample
//
//  Created by JOEY SCHLUCHTER on 1/16/12.
//  Copyright (c) 2012 Thuzi, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface thzAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, UIWebViewDelegate> {
    Facebook *facebook;
    NSMutableDictionary *userPermissions;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;


@end
