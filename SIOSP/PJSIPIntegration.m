//
//  PJSIPIntegration.m
//  SIOSP
//
//  Created by Flavien SICARD on 1/19/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

@import AVFoundation;
#import "PJSIPIntegration.h"

static pj_status_t status;
pjsua_acc_id accountIdentifier;
static void onIncomingCall(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata);


@implementation PJSIPIntegration

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void) testPJSIP {
    pjsua_create();
    status = pjsua_start();
    if (status != PJ_SUCCESS) {
        pjsua_destroy();
        return;
    }
}

- (pj_status_t) configurePJSIP {
    pj_status_t status;
    
    pjsua_config ua_cfg;
    pjsua_logging_config log_cfg;
    pjsua_media_config media_cfg;
    pjsua_transport_config transport_cfg;
    
    status = pjsua_create();
    if (status != PJ_SUCCESS) {
        return status;
    }

    pjsua_config_default(&ua_cfg);
    pjsua_logging_config_default(&log_cfg);
    pjsua_media_config_default(&media_cfg);
    pjsua_transport_config_default(&transport_cfg);

    media_cfg.has_ioqueue = PJ_TRUE;
    media_cfg.thread_cnt = 1;
    media_cfg.no_vad = PJ_TRUE;
    
    ua_cfg.use_timer = PJSUA_SIP_TIMER_INACTIVE;
    ua_cfg.max_calls = 30;
    ua_cfg.cb.on_incoming_call = &onIncomingCall;
    ua_cfg.cb.on_call_media_state = &on_call_media_state;

    status = pjsua_init(&ua_cfg, &log_cfg, &media_cfg);
    if (status != PJ_SUCCESS) {
        return status;
    }
    
    pjsua_transport_id transportIdentifier;
    status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transport_cfg, &transportIdentifier);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error creating UDP transport");
        return status;
    }
    status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &transport_cfg, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error creating TCP transport");
        return status;
    }
    
    status = pjsua_start();
    
    pjsua_set_no_snd_dev();
    if (status != PJ_SUCCESS) {
        NSLog(@"Error starting PJSUA");
        return status;
    }
    
    pjsua_acc_config acc_cfg;
    pjsua_acc_config_default(&acc_cfg);

    acc_cfg.id =  pj_str((char *)[@"sip:sicardf@sip.antisip.com" cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.reg_uri = pj_str((char *)[@"sip:sip.antisip.com" cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.cred_count = 1;
    acc_cfg.cred_info[0].scheme = pj_str((char *)[@"digest" cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.cred_info[0].realm = pj_str((char *)[@"*" cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.cred_info[0].username = pj_str((char *)[@"sicardf" cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    acc_cfg.cred_info[0].data = pj_str((char *)[@"" cStringUsingEncoding:NSUTF8StringEncoding]);
    
    status = pjsua_acc_add(&acc_cfg, PJ_FALSE, &accountIdentifier);
    if (status != PJ_SUCCESS) {
        return status;
    }

    return PJ_SUCCESS;
}

- (BOOL)activateSoundDevice {
    pjsua_set_no_snd_dev();
    pj_status_t status;
    status = pjsua_set_snd_dev(PJMEDIA_AUD_DEFAULT_CAPTURE_DEV, PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV);
    if (status == PJ_SUCCESS) {
        NSError *audioSessionCategoryError;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioSessionCategoryError];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        return YES;
    } else {
        NSLog(@"Failure in enabling sound device");
        return NO;
    }
}

- (void) makeCall {
    pj_str_t uri = pj_str((char *)[@"sip:sicardf2@sip.antisip.com" cStringUsingEncoding:NSUTF8StringEncoding]);
    pjsua_call_make_call(accountIdentifier, &uri, 0, NULL, NULL, NULL);
}

- (char *)cStringFromNSString:(NSString *)string {
    if(!string) {
        return nil;
    }
    
    if(string.length == 0) {
        return "";
    }
    
    char *result = calloc([string length] + 1, 1);
    [string getCString:result maxLength:[string length] + 1 encoding:NSUTF8StringEncoding];
    
    return result;
}

- (void) startIncomingCall {
    
}

static void onIncomingCall(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata) {
    NSLog(@"Detected inbound call(%d) for account:%d", call_id, acc_id);
    
    pjsua_call_info info;
    pjsua_call_get_info(call_id, &info);
    

    if (status == PJ_SUCCESS) {
        NSLog(@"ENTRANT");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"incomingCall" object:NULL];
    
//    status = pjsua_call_answer((pjsua_call_id)call_id, PJSIP_SC_OK, NULL, NULL);
//    if (status != PJ_SUCCESS) {
//        NSLog(@"Error %d while sending status code PJSIP_SC_RINGING", status);
//    }
    
}

static void on_call_media_state(pjsua_call_id call_id) {
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);

    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
    }
}

@end
