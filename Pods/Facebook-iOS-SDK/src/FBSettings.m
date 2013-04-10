/*
 * Copyright 2010 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FBError.h"
#import "FBRequest.h"
#import "FBSession.h"
#import "FBSettings.h"
#import "FBSettings+Internal.h"
#import "FBUtility.h"

#import <UIKit/UIKit.h>

NSString *const FBLoggingBehaviorFBRequests = @"fb_requests";
NSString *const FBLoggingBehaviorFBURLConnections = @"fburl_connections";
NSString *const FBLoggingBehaviorAccessTokens = @"include_access_tokens";
NSString *const FBLoggingBehaviorSessionStateTransitions = @"state_transitions";
NSString *const FBLoggingBehaviorPerformanceCharacteristics = @"perf_characteristics";
NSString *const FBLoggingBehaviorInsights = @"insights";
NSString *const FBLoggingBehaviorDeveloperErrors = @"developer_errors";

NSString *const FBLastAttributionPing = @"com.facebook.sdk:lastAttributionPing%@";
NSString *const FBLastInstallResponse = @"com.facebook.sdk:lastInstallResponse%@";
NSString *const FBPublishActivityPath = @"%@/activities";
NSString *const FBMobileInstallEvent = @"MOBILE_APP_INSTALL";

NSTimeInterval const FBPublishDelay = 0.1;

@implementation FBSettings

static NSSet *g_loggingBehavior;
static BOOL g_autoPublishInstall = YES;
static dispatch_once_t g_publishInstallOnceToken;
static NSString *g_clientToken;

+ (NSSet *)loggingBehavior {
    if (!g_loggingBehavior) {
        
        // Establish set of default enabled logging behaviors.  Can completely disable logging by
        // calling setLoggingBehavior with an empty set.
        g_loggingBehavior = [[NSSet setWithObject:FBLoggingBehaviorDeveloperErrors] retain];
    }
    return g_loggingBehavior;
}

+ (void)setLoggingBehavior:(NSSet *)newValue {
    [newValue retain];
    [g_loggingBehavior release];
    g_loggingBehavior = newValue;
}

+ (NSString *)clientToken {
    return g_clientToken;
}

+ (void)setClientToken:(NSString *)clientToken {
    [clientToken retain];
    [g_clientToken release];
    g_clientToken = clientToken;
}

+ (BOOL)shouldAutoPublishInstall {
    return g_autoPublishInstall;
}

+ (void)setShouldAutoPublishInstall:(BOOL)newValue {
    g_autoPublishInstall = newValue;
}

+ (void)autoPublishInstall:(NSString *)appID {
    if ([FBSettings shouldAutoPublishInstall]) {
        dispatch_once(&g_publishInstallOnceToken, ^{
            // dispatch_once is great, but not re-entrant.  Inside publishInstall we use FBRequest, which will
            // cause this function to get invoked a second time.  By scheduling the work, we can sidestep the problem.
            [[FBSettings class] performSelector:@selector(publishInstall:) withObject:appID afterDelay:FBPublishDelay];
        });
    }
}


#pragma mark -
#pragma mark proto-activity publishing code

+ (void)publishInstall:(NSString *)appID {
    [FBSettings publishInstall:appID withHandler:nil];
}

+ (void)publishInstall:(NSString *)appID
           withHandler:(FBInstallResponseDataHandler)handler {
    @try {
        handler = [[handler copy] autorelease];

        if (!appID) {
            appID = [FBSession defaultAppID];
        }

        if (!appID) {
            // if the appID is still nil, exit early.
            if (handler) {
                handler(
                    nil,
                    [NSError errorWithDomain:FacebookSDKDomain
                                        code:FBErrorPublishInstallResponse
                                    userInfo:@{ NSLocalizedDescriptionKey : @"A valid App ID was not supplied or detected.  Please call with a valid App ID or configure the app correctly to include FB App ID."}]
                );
            }
            return;
        }

        // We turn off auto-publish, since this was manually called and the expectation
        // is that it's only ever necessary to call this once.
        [FBSettings setShouldAutoPublishInstall:NO];

        // look for a previous ping & grab the facebook app's current attribution id.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *pingKey = [NSString stringWithFormat:FBLastAttributionPing, appID, nil];
        NSString *responseKey = [NSString stringWithFormat:FBLastInstallResponse, appID, nil];
      
        NSDate *lastPing = [defaults objectForKey:pingKey];
        id lastResponseData = [defaults objectForKey:responseKey];
      
        NSString *attributionID = [FBUtility attributionID];
        NSString *advertiserID = [FBUtility advertiserID];
      
        if (lastPing) {
            // Short circuit
            if (handler) {
                handler(lastResponseData, nil);
            }
            return;
        }
  
        if (!(attributionID || advertiserID)) {
          if (handler) {
              handler(
                nil,
                [NSError errorWithDomain:FacebookSDKDomain
                                    code:FBErrorPublishInstallResponse
                                userInfo:@{ NSLocalizedDescriptionKey : @"A valid attribution ID or advertiser ID was not found.  Publishing install when neither of them is present is a no-op."}]
              );
          }
          return;
        }

        FBRequestHandler publishCompletionBlock = ^(FBRequestConnection *connection,
                                                    id result,
                                                    NSError *error) {
            @try {
                if (!error) {
                    // if server communication was successful, take note of the current time.
                    [defaults setObject:[NSDate date] forKey:pingKey];
                    [defaults setObject:result forKey:responseKey];
                    [defaults synchronize];
                } else {
                    // there was a problem.  allow a repeat execution.
                    g_publishInstallOnceToken = 0;
                }
            } @catch (NSException *ex1) {
                NSLog(@"Failure after install publish: %@", ex1.reason);
            }

            // Callback regardless of exception
            if (handler) {
                handler(result, error);
            }
        };

        [FBUtility fetchAppSettings:appID
                           callback:^(FBFetchedAppSettings *settings, NSError *error) {
            if (!error) {
                @try {
                    if (settings.supportsAttribution) {
                        // set up the HTTP POST to publish the attribution ID.
                        NSString *publishPath = [NSString stringWithFormat:FBPublishActivityPath, appID, nil];
                        NSMutableDictionary<FBGraphObject> *installActivity = [FBGraphObject graphObject];
                        [installActivity setObject:FBMobileInstallEvent forKey:@"event"];
              
                        if (attributionID) {
                            [installActivity setObject:attributionID forKey:@"attribution"];
                        }
                        if (advertiserID) {
                            [installActivity setObject:advertiserID forKey:@"advertiser_id"];
                        }

                        FBRequest *publishRequest = [[[FBRequest alloc] initForPostWithSession:nil graphPath:publishPath graphObject:installActivity] autorelease];
                        [publishRequest startWithCompletionHandler:publishCompletionBlock];
                    } else {
                        // the app has turned off install insights.  prevent future attempts.
                        [defaults setObject:[NSDate date] forKey:pingKey];
                        [defaults setObject:nil forKey:responseKey];
                        [defaults synchronize];

                        if (handler) {
                          handler(
                            nil,
                            [NSError errorWithDomain:FacebookSDKDomain
                                                code:FBErrorPublishInstallResponse
                                            userInfo:@{ NSLocalizedDescriptionKey : @"The application has not enabled install insights.  To turn this on, go to developers.facebook.com and enable install insights for the app."}]
                          );
                        }
                    }
                } @catch (NSException *ex2) {
                    NSString *errorMessage = [NSString stringWithFormat:@"Failure during install publish: %@", ex2.reason];
                    NSLog(@"%@", errorMessage);
                    if (handler) {
                        handler(
                            nil,
                            [NSError errorWithDomain:FacebookSDKDomain
                                                code:FBErrorPublishInstallResponse
                                            userInfo:@{ NSLocalizedDescriptionKey : errorMessage}]
                        );
                    }

                }
            }
        }];
    } @catch (NSException *ex3) {
        NSString *errorMessage = [NSString stringWithFormat:@"Failure before/during install ping: %@", ex3.reason];
        NSLog(@"%@", errorMessage);
        if (handler) {
            handler(
                nil,
                [NSError errorWithDomain:FacebookSDKDomain
                                    code:FBErrorPublishInstallResponse
                                userInfo:@{ NSLocalizedDescriptionKey : errorMessage}]
            );
        }
    }
}

@end
