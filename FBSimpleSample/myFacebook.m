//
//  myFacebook.m
//  FBSimpleSample
//
//  Created by James Zimmerman on 1/20/12.
//  Copyright (c) 2012 Thuzi. All rights reserved.
//

#import "myFacebook.h"

@implementation Facebook (FBSimpleSample)

- (void)myAuthorize:(NSArray *)permissions {
    _permissions = permissions;
    //Force the dialog only
    [self authorizeWithFBAppAuth:NO safariAuth:NO];
    //SSO with Facebook APP installed
    // [self authorizeWithFBAppAuth:YES safariAuth:YES];
}

@end