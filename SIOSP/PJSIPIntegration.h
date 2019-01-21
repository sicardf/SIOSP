//
//  PJSIPIntegration.h
//  SIOSP
//
//  Created by Flavien SICARD on 1/19/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

#ifndef PJSIPIntegration_h
#define PJSIPIntegration_h

#import <Foundation/Foundation.h>
#import <pjsua.h>

@interface PJSIPIntegration : NSObject

@property (strong, nonatomic) id someProperty;

+ (instancetype _Nonnull)sharedInstance;
- (void) testPJSIP;
- (void) makeCall;
- (BOOL) activateSoundDevice;
- (pj_status_t) configurePJSIP;

@end

#endif /* PJSIPIntegration_h */
