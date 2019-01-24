//
//  PJSIPIntegration.m
//  SIOSP
//
//  Created by Flavien SICARD on 1/19/19.
//  Copyright © 2019 sicardf. All rights reserved.
//

#import "PJSIPIntegration.h"

pjsua_acc_id accountIdentifier;
static void onIncomingCall(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata);
static void on_call_state(pjsua_call_id call_id, pjsip_event *e);

//NSString *idSIP = @"sip:sicardf@sip.antisip.com";
//NSString *uri = @"sip:sip.antisip.com";
//NSString *scheme = @"digest";
//NSString *realm = @"*";
//NSString *username = @"sicardf";
//NSString *password = @"tudkig-mafbuf-masWo0";

NSString *idSIP = @"sip:sicardf2@sip.antisip.com";
NSString *uri = @"sip:sip.antisip.com";
NSString *scheme = @"digest";
NSString *realm = @"*";
NSString *username = @"sicardf2";
NSString *password = @"muSwyc-wekhy0-humcyc";

void (^incomin)(void);
void (^startCall)(void);
void (^endCall)(void);

pjsua_call_id incoming_call_id;

@implementation PJSIPIntegration

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (pj_status_t) configurePJSIP {
    pj_status_t status;
    
    status = pjsua_create();
    if (status != PJ_SUCCESS) {
        return status;
    }

    pjsua_config config;
    pjsua_logging_config logging_config;
    pjsua_media_config media_config;
    pjsua_transport_config transport_config;
    
    pjsua_config_default(&config);
    pjsua_logging_config_default(&logging_config);
    pjsua_media_config_default(&media_config);
    pjsua_transport_config_default(&transport_config);

    media_config.has_ioqueue = PJ_TRUE;
    media_config.thread_cnt = 1;
    media_config.no_vad = PJ_TRUE;
    
    config.use_timer = PJSUA_SIP_TIMER_INACTIVE;
    config.max_calls = 30;
    config.cb.on_incoming_call = &onIncomingCall;
    config.cb.on_call_state = &on_call_state;
    config.cb.on_call_media_state = &on_call_media_state;

    status = pjsua_init(&config, &logging_config, &media_config);
    if (status != PJ_SUCCESS) {
        return status;
    }
    
    pjsua_transport_id transportIdentifier;
    
    status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transport_config, &transportIdentifier);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error creating UDP transport");
        return status;
    }
    
    status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &transport_config, NULL);
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

    acc_cfg.id =  pj_str((char *)[idSIP cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.reg_uri = pj_str((char *)[uri cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.cred_count = 1;
    acc_cfg.cred_info[0].scheme = pj_str((char *)[scheme cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.cred_info[0].realm = pj_str((char *)[realm cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.cred_info[0].username = pj_str((char *)[username cStringUsingEncoding:NSUTF8StringEncoding]);
    acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    acc_cfg.cred_info[0].data = pj_str((char *)[password cStringUsingEncoding:NSUTF8StringEncoding]);
    
    status = pjsua_acc_add(&acc_cfg, PJ_FALSE, &accountIdentifier);
    if (status != PJ_SUCCESS) {
        return status;
    }

    return PJ_SUCCESS;
}

- (BOOL) activateSoundDevice {
    pj_status_t status;
    
    pjsua_set_no_snd_dev();

    status = pjsua_set_snd_dev(PJMEDIA_AUD_DEFAULT_CAPTURE_DEV, PJMEDIA_AUD_DEFAULT_PLAYBACK_DEV);
    if (status != PJ_SUCCESS) {
        NSLog(@"Failure in enabling sound device");
        return NO;
    }
    
    return YES;
}

- (BOOL) makeCall:(NSString *)str {
    pj_status_t status;
    
    pj_str_t uri = pj_str((char *)[str cStringUsingEncoding:NSUTF8StringEncoding]);
    
    status = pjsua_call_make_call(accountIdentifier, &uri, 0, NULL, NULL, NULL);
    
    if (status != PJ_SUCCESS) {
        NSLog(@"Failure in enabling sound device");
        return NO;
    }
    
    return YES;
}

- (char *)cStringFromNSString:(NSString *)string {
    if (!string) {
        return nil;
    }
    
    if (string.length == 0) {
        return "";
    }
    
    char *result = calloc([string length] + 1, 1);
    [string getCString:result maxLength:[string length] + 1 encoding:NSUTF8StringEncoding];
    
    return result;
}

- (void) changeOutputAudioPort:(AVAudioSessionPortOverride)port {
    NSError *audioSessionCategoryError;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioSessionCategoryError];
    [audioSession overrideOutputAudioPort:port error:nil];
}

- (void) configureIncomingCall:(void (^)(void))inn {
    incomin = inn;
}

- (void) configureStarCall:(void (^)(void))inn {
    startCall = inn;
}

- (void) configureEndCall:(void (^)(void))inn {
    endCall = inn;
}

- (BOOL) acceptCall {
    pj_status_t status;
    
    status = pjsua_call_answer((pjsua_call_id)incoming_call_id, PJSIP_SC_ACCEPTED, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error %d while sending status code PJSIP_SC_RINGING", status);
        return NO;
    }
    
    return YES;
}

- (void) declineCall {
    pj_status_t status;
    
    status = pjsua_call_answer((pjsua_call_id)incoming_call_id, PJSIP_SC_DECLINE, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error %d while sending status code PJSIP_SC_RINGING", status);
    }
}

- (void) stopCall {
    pj_status_t status;
    
    status = pjsua_call_hangup(incoming_call_id, 0, NULL, NULL);
}

static void onIncomingCall(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata) {
    pj_status_t status;
    
    incoming_call_id = call_id;
    
    pjsua_call_info info;
    status = pjsua_call_get_info(call_id, &info);

    if (status == PJ_SUCCESS) {
        NSLog(@"ENTRANT");
    }

    status = pjsua_call_answer((pjsua_call_id)call_id, PJSIP_SC_RINGING, NULL, NULL);
    if (status != PJ_SUCCESS) {
        NSLog(@"Error %d while sending status code PJSIP_SC_RINGING", status);
    }
    
    incomin();
}

static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(e);
    
    pjsua_call_get_info(call_id, &ci);

    if (ci.state == PJSIP_INV_STATE_CONNECTING) {
       // startCall();
    }
    
    if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        endCall();
    }
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
