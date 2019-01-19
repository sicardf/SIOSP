//
//  PJSIPIntegration.m
//  SIOSP
//
//  Created by Flavien SICARD on 1/19/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

#import "PJSIPIntegration.h"

@implementation PJSIPIntegration

- (void) someMethod {
    NSLog(@"SomeMethod Ran");
}

- (void) testSIP {
    
    pjsua_create();
    
    pjsua_config ua_cfg;
    pjsua_logging_config log_cfg;
    pjsua_media_config media_cfg;
    
    pjsua_config_default(&ua_cfg);
    pjsua_logging_config_default(&log_cfg);
    pjsua_media_config_default(&media_cfg);
    
    pjsua_init(&ua_cfg, &log_cfg, &media_cfg);
    
    pjsua_transport_config transportConfig;
    
    pjsua_transport_config_default(&transportConfig);
    
    transportConfig.port = 5060;
    
    pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transportConfig, NULL);
    pjsua_transport_create(PJSIP_TRANSPORT_TCP, &transportConfig, NULL);
    
    pjsua_start();
}

@end
