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

- (void) someMethod;
- (void) testSIP;

@end

#endif /* PJSIPIntegration_h */
