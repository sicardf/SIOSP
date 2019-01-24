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

@import AVFoundation;

@interface PJSIPIntegration : NSObject

+ (instancetype _Nonnull)sharedInstance;
- (pj_status_t) configurePJSIP;
- (BOOL) activateSoundDevice;
- (BOOL) makeCall: (NSString *)str;
- (void) changeOutputAudioPort: (AVAudioSessionPortOverride)port;
- (void) configureIncomingCall:(void (^)(void))inn;
- (void) configureStarCall:(void (^)(void))inn;
- (void) configureEndCall:(void (^)(void))inn;
- (BOOL) acceptCall;
- (void) declineCall;
- (void) stopCall;

@end

#endif /* PJSIPIntegration_h */
