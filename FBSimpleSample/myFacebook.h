//
//  myFacebook.h
//  FBSimpleSample
//
//  Created by James Zimmerman on 1/20/12.
//  Copyright (c) 2012 Thuzi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface Facebook (Private)
//     NSArray* _permissions;
- (void)authorizeWithFBAppAuth:(BOOL)tryFBAppAuth
                    safariAuth:(BOOL)trySafariAuth;
@end

@interface Facebook (FBSimpleSample)
- (void)myAuthorize:(NSArray *)permissions;
@end