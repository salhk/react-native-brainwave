//
//  RNBrainwave.m
//  RNBrainwave
//
//  Created by jimmy on 14/02/2017.
//
#import "RNBrainwave.h"
#import <React/RCTLog.h>
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>

#define X_RANGE     256
// in simulator, canned data will be used instead.
#if TARGET_IPHONE_SIMULATOR
//#if 1
#include "canned_data.c"
#else
#define IOS_DEVICE
//#include "canned_data.c"
#endif

#ifdef IOS_DEVICE
#import "TGStream.h"
#include <sys/time.h>
#endif


@implementation RNBrainwave

@synthesize bridge = _bridge;

BOOL bRunning;
BOOL bPaused;

NSMutableString *stateStr;
NSMutableString *signalStr;

int ap_index = 0;
int me_index = 0;
int me2_index = 0;
int f_index = 0;
int f2_index = 0;

float lMeditation = 0;
float lAttention = 0;
float lAppreciation = 0;
float lMentalEffort_abs = 0, lMentalEffort_diff = 0;

NskAlgoType algoTypes;

#ifndef IOS_DEVICE
#define SAMPLE_COUNT        600
float ap[SAMPLE_COUNT];
float me[SAMPLE_COUNT];
float f[SAMPLE_COUNT];
float f2[SAMPLE_COUNT];
#endif
int bp_index = 0;

NSString *const CONNECTION_STATE = @"CONNECTION_STATE";
NSString *const CONNECTION_ERROR = @"CONNECTION_ERROR";
NSString *const SIGNAL_QUALITY = @"SIGNAL_QUALITY";
NSString *const ALGO_STATE = @"ALGO_STATE";
NSString *const ATTENTION_ALGO_INDEX = @"ATTENTION_ALGO_INDEX";
NSString *const MEDITATION_ALGO_INDEX = @"MEDITATION_ALGO_INDEX";
NSString *const APPRECIATION_ALGO_INDEX = @"APPRECIATION_ALGO_INDEX";
NSString *const MENTAL_EFFORT_ALGO_INDEX = @"MENTAL_EFFORT_ALGO_INDEX";
NSString *const MENTAL_EFFORT2_ALGO_INDEX = @"MENTAL_EFFORT2_ALGO_INDEX";
NSString *const FAMILIARITY_ALGO_INDEX = @"FAMILIARITY_ALGO_INDEX";
NSString *const FAMILIARITY2_ALGO_INDEX = @"FAMILIARITY2_ALGO_INDEX";


RCT_EXPORT_MODULE()

- (instancetype)init {
    [[TGStream sharedInstance] setDelegate:self];

    return self;
}

RCT_EXPORT_METHOD(connect)
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        bTGStreamInited= false;
        [[TGStream sharedInstance] initConnectWithAccessorySession];
        bRunning = FALSE;
    });
}

RCT_EXPORT_METHOD(disconnect)
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[TGStream sharedInstance] tearDownAccessorySession];
    });
}

- (void)signalQuality:(NskAlgoSignalQuality)signalQuality {
    if (signalStr == nil) {
        signalStr = [[NSMutableString alloc] init];
    }
    [signalStr setString:@""];
    [signalStr appendString:@"Signal quailty: "];
    int level = 0;
    switch (signalQuality) {
        case NskAlgoSignalQualityGood:
            [signalStr appendString:@"Good"];
            level = 0;
            break;
        case NskAlgoSignalQualityMedium:
            [signalStr appendString:@"Medium"];
            level = 1;
            break;
        case NskAlgoSignalQualityNotDetected:
            [signalStr appendString:@"Not detected"];
            level = 2;
            break;
        case NskAlgoSignalQualityPoor:
            [signalStr appendString:@"Poor"];
            level = 3;
            break;
    }
    [self.bridge.eventDispatcher sendAppEventWithName:SIGNAL_QUALITY
                                                 body:@{@"level": @(level)}];
    
    
    
    printf("%s", [signalStr UTF8String]);
    printf("\n");
}

static ConnectionStates lastConnectionState = -1;
-(void)onStatesChanged:(ConnectionStates)connectionState{
    //NSLog(@"%@\n Connection States:%lu\n",[self NowString],(unsigned long)connectionState);
    
    lastConnectionState = connectionState;
    
    [self.bridge.eventDispatcher sendAppEventWithName:CONNECTION_STATE
                                                 body:@{@"connection_state": @(lastConnectionState)}];
    
    switch (connectionState) {
        case STATE_COMPLETE:
            NSLog(@"TGStream: complete");
            break;
        case STATE_CONNECTED:
            NSLog(@"TGStream: connected");
            //            if (bTGStreamInited == false) {
            //                [[TGStream sharedInstance] initConnectWithAccessorySession];
            //                bTGStreamInited = true;
            //            }
            break;
        case STATE_CONNECTING:
            NSLog(@"TGStream: connecting");
            break;
        case STATE_DISCONNECTED:
            NSLog(@"TGStream: disconnected");
            if (bTGStreamInited == true) {
                [[TGStream sharedInstance] tearDownAccessorySession];
                bTGStreamInited= false;
            }
            break;
        case STATE_ERROR:
            NSLog(@"TGStream: error");
            break;
        case STATE_FAILED:
            NSLog(@"TGStream: failed");
            break;
        case STATE_INIT:
            NSLog(@"TGStream: init");
            break;
        case STATE_RECORDING_END:
            NSLog(@"TGStream: record end");
            break;
        case STATE_RECORDING_START:
            NSLog(@"TGStream: record start");
            break;
        case STATE_STOPPED:
            NSLog(@"TGStream: stopped");
            break;
        case STATE_WORKING:
            NSLog(@"TGStream: working");
            break;
    }
}


int rawCount = 0;

#pragma mark
#pragma COMM SDK Delegate
-(void)onDataReceived:(NSInteger)datatype data:(int)data obj:(NSObject *)obj deviceType:(DEVICE_TYPE)deviceType {
    if (deviceType != DEVICE_TYPE_MindWaveMobile) {
        return;
    }
    switch (datatype) {
            
        case MindDataType_CODE_POOR_SIGNAL:
            //NSLog(@"%@ POOR_SIGNAL %d\n",[self NowString], data);
        {
            long long timestamp = current_timestamp();
            static long long ltimestamp = 0;
            printf("PQ,%lld,%lld,%d\n", timestamp%100000, timestamp - ltimestamp, rawCount);
            ltimestamp = timestamp;
            rawCount = 0;
        }
        {
            int16_t poor_signal[1];
            poor_signal[0] = (int16_t)data;
            [[NskAlgoSdk sharedInstance] dataStream:NskAlgoDataTypePQ data:poor_signal length:1];
        }
            break;
            
        case MindDataType_CODE_RAW:
            rawCount++;
            //[self addValue:@(data) array:self->eegIndex];
            if (bRunning == FALSE) {
                [[NskAlgoSdk sharedInstance] startProcess];
                bRunning = TRUE;
                return;
            }
        {
            int16_t eeg_data[1];
            eeg_data[0] = (int16_t)data;
            [[NskAlgoSdk sharedInstance] dataStream:NskAlgoDataTypeEEG data:eeg_data length:1];
        }
            //NSLog(@"%@\n CODE_RAW %d\n",[self NowString],data);
            break;
            
        case MindDataType_CODE_ATTENTION:
        {
            int16_t attention[1];
            attention[0] = (int16_t)data;
            [[NskAlgoSdk sharedInstance] dataStream:NskAlgoDataTypeAtt data:attention length:1];
        }
            //NSLog(@"%@\n CODE_ATTENTION %d\n",[self NowString],data);
            break;
            
        case MindDataType_CODE_MEDITATION:
        {
            int16_t meditation[1];
            meditation[0] = (int16_t)data;
            [[NskAlgoSdk sharedInstance] dataStream:NskAlgoDataTypeMed data:meditation length:1];
        }
            //NSLog(@"%@\n CODE_MEDITATION %d\n",[self NowString],data);
            break;
            
        case MindDataType_CODE_EEGPOWER:
            //NSLog(@"%@\n CODE_EEGPOWER %d\n",[self NowString],data);
            break;
            
        case BodyDataType_CODE_HEARTRATE:
            //NSLog(@"%@\n CODE_CONFIGURATION %d\n",[self NowString],data);
            break;
            
        default:
            //NSLog(@"%@\n NO defined data type %ld %d\n",[self NowString],(long)datatype,data);
            break;
    }
}

static NSUInteger checkSum=0;
bool bTGStreamInited = false;

-(void) onChecksumFail:(Byte *)payload length:(NSUInteger)length checksum:(NSInteger)checksum{
    checkSum++;
    NSLog(@"%@\n Check sum Fail:%lu\n",[self NowString],(unsigned long)checkSum);
    NSLog(@"CheckSum lentgh:%lu  CheckSum:%lu",(unsigned long)length,(unsigned long)checksum);
}



#pragma mark
#pragma NSK EEG SDK Delegate
- (void)stateChanged:(NskAlgoState)state reason:(NskAlgoReason)reason {
    if (stateStr == nil) {
        stateStr = [[NSMutableString alloc] init];
    }
    [stateStr setString:@""];
    [stateStr appendString:@"SDK State: "];
    switch (state) {
        case NskAlgoStateCollectingBaselineData:
        {
            bRunning = TRUE;
            bPaused = FALSE;
            [stateStr appendString:@"Collecting baseline"];
        }
            break;
        case NskAlgoStateAnalysingBulkData:
        {
            bRunning = TRUE;
            bPaused = FALSE;
            [stateStr appendString:@"Analysing Bulk Data"];
        }
            break;
        case NskAlgoStateInited:
        {
            bRunning = FALSE;
            bPaused = TRUE;
            [stateStr appendString:@"Inited"];
        }
            break;
        case NskAlgoStatePause:
        {
            bPaused = TRUE;
            [stateStr appendString:@"Pause"];
        }
            break;
        case NskAlgoStateRunning:
        {
            [stateStr appendString:@"Running"];
            bRunning = TRUE;
            bPaused = FALSE;
        }
            break;
        case NskAlgoStateStop:
        {
            [stateStr appendString:@"Stop"];
            bRunning = FALSE;
            bPaused = TRUE;
        }
            break;
        case NskAlgoStateUninited:
            [stateStr appendString:@"Uninit"];
            break;
    }
    switch (reason) {
        case NskAlgoReasonBaselineExpired:
            [stateStr appendString:@" | Baseline expired"];
            break;
        case NskAlgoReasonConfigChanged:
            [stateStr appendString:@" | Config changed"];
            break;
        case NskAlgoReasonNoBaseline:
            [stateStr appendString:@" | No Baseline"];
            break;
        case NskAlgoReasonSignalQuality:
            [stateStr appendString:@" | Signal quality"];
            break;
        case NskAlgoReasonUserProfileChanged:
            [stateStr appendString:@" | User profile changed"];
            break;
        case NskAlgoReasonUserTrigger:
            [stateStr appendString:@" | By user"];
            break;
        case NskAlgoReasonExpired:
            
            break;
        case NskAlgoReasonInternetError:
            
            break;
        case NskAlgoReasonKeyError:
            
            break;
    }
    printf("%s", [stateStr UTF8String]);
    printf("\n");
    
    [self.bridge.eventDispatcher sendAppEventWithName:ALGO_STATE
                                                 body:@{@"state": @(state)}];
}

-(void) onRecordFail:(RecrodError)flag{
    NSLog(@"%@\n Record Fail:%lu\n",[self NowString],(unsigned long)flag);
}




- (void)bpAlgoIndex:(NSNumber *)delta theta:(NSNumber *)theta alpha:(NSNumber *)alpha beta:(NSNumber *)beta gamma:(NSNumber *)gamma {
    NSLog(@"bp[%d] = (delta)%1.6f (theta)%1.6f (alpha)%1.6f (beta)%1.6f (gamma)%1.6f", bp_index, [delta floatValue], [theta floatValue], [alpha floatValue], [beta floatValue], [gamma floatValue]);
    bp_index++;
}

- (void)apAlgoIndex:(NSNumber *)value {
    NSLog(@"ap[%d] = %1.15f", ap_index, [value floatValue]);
    lAppreciation = [value floatValue];
#ifndef IOS_DEVICE
    ap[ap_index] = lAppreciation;
#endif
    ap_index++;
    
    [self.bridge.eventDispatcher sendAppEventWithName:APPRECIATION_ALGO_INDEX
                                                 body:@{@"value": value}];
    
}

- (void)meAlgoIndex:(NSNumber *)abs_me diff_me:(NSNumber *)diff_me max_me:(NSNumber *)max_me min_me:(NSNumber *)min_me {
    
    NSLog(@"me[%d] = ABS:%1.8f DIF:%1.8f [%1.0f:%1.0f]", me_index, [abs_me floatValue], [diff_me floatValue], [min_me floatValue], [max_me floatValue]);
    lMentalEffort_abs = [abs_me floatValue];
    lMentalEffort_diff = [diff_me floatValue];
#ifndef IOS_DEVICE
    me[me_index] = lMentalEffort_abs;
#endif
    me_index++;
    [self.bridge.eventDispatcher sendAppEventWithName:MENTAL_EFFORT_ALGO_INDEX
                                                 body:@{
                                                        @"abs_me": abs_me,
                                                        @"diff_me": diff_me,
                                                        @"max_me": max_me,
                                                        @"min_me": min_me
                                                        }];
    
}

- (void) me2AlgoIndex: (NSNumber*)total_me me_rate:(NSNumber*)me_rate changing_rate:(NSNumber*)changing_rate {
    NSLog(@"me2[%d] = (total)%1.6f (rate)%1.6f (chg rate)%1.6f", me2_index, [total_me floatValue], [me_rate floatValue], [changing_rate floatValue]);
    
    me2_index++;
    
    [self.bridge.eventDispatcher sendAppEventWithName:MENTAL_EFFORT2_ALGO_INDEX
                                                 body:@{
                                                        @"total_me": total_me,
                                                        @"me_rate": me_rate,
                                                        @"changing_rate": changing_rate
                                                        }];
}

- (void)fAlgoIndex:(NSNumber *)abs_f diff_f:(NSNumber *)diff_f max_f:(NSNumber *)max_f min_f:(NSNumber *)min_f {
    
    
    NSLog(@"f[%d] = ABS:%1.8f DIF:%1.8f [%1.0f:%1.0f]", f_index, [abs_f floatValue], [diff_f floatValue], [min_f floatValue], [max_f floatValue]);
#ifndef IOS_DEVICE
    f[f_index] = [abs_f floatValue];
#endif
    f_index++;
    [self.bridge.eventDispatcher sendAppEventWithName:FAMILIARITY_ALGO_INDEX
                                                 body:@{
                                                        @"abs_f": abs_f,
                                                        @"diff_f": diff_f,
                                                        @"min_f": min_f,
                                                        @"max_f": max_f
                                                        }];
}

- (void)f2AlgoIndex:(NSNumber *)progress_level f_degree:(NSNumber *)f_degree {
    NSLog(@"f2[%d] = %d, %1.15f", f2_index, [progress_level intValue], [f_degree floatValue]);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm:ss"];
        
    });
    f2_index++;
    
    [self.bridge.eventDispatcher sendAppEventWithName:FAMILIARITY2_ALGO_INDEX
                                                 body:@{
                                                        @"progress_level": progress_level,
                                                        @"f_degree": f_degree
                                                        }];
}

- (void)attAlgoIndex:(NSNumber *)value {
    NSLog(@"Attention: %f", [value floatValue]);
    lAttention = [value floatValue];
    
    [self.bridge.eventDispatcher sendAppEventWithName:ATTENTION_ALGO_INDEX
                                                 body:@{
                                                        @"value": value
                                                        }];
}

- (void)medAlgoIndex:(NSNumber *)value {
    NSLog(@"Meditation: %f", [value floatValue]);
    lMeditation = [value floatValue];
    
    [self.bridge.eventDispatcher sendAppEventWithName:MEDITATION_ALGO_INDEX
                                                 body:@{
                                                        @"value": value
                                                        }];
}


BOOL bBlink = NO;
- (void)eyeBlinkDetect:(NSNumber *)strength {
    NSLog(@"Eye blink detected: %d", [strength intValue]);
    dispatch_sync(dispatch_get_main_queue(), ^{
        bBlink = YES;
    });
}






RCT_EXPORT_METHOD(setDefaultAlgos)
{
    algoTypes = 0;
    //algoTypes |= NskAlgoEegTypeAP;
    algoTypes |= NskAlgoEegTypeME;
    //algoTypes |= NskAlgoEegTypeME2;
    algoTypes |= NskAlgoEegTypeF;
    //algoTypes |= NskAlgoEegTypeF2;
    algoTypes |= NskAlgoEegTypeAtt;
    algoTypes |= NskAlgoEegTypeMed;
    //algoTypes |= NskAlgoEegTypeBP;
    //algoTypes |= NskAlgoEegTypeBlink;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self setAlgos:algoTypes];
    });
    
    

}

RCT_EXPORT_METHOD(setAlgos:(NSInteger)algoTypes)
{
    NskAlgoSdk *handle = [NskAlgoSdk sharedInstance];
    handle.delegate = self;
    
    int ret;
    
    if ((ret = [[NskAlgoSdk sharedInstance] setAlgorithmTypes:algoTypes licenseKey:(char*)"NeuroSky_Release_To_GeneralFreeLicense_Use_Only_Nov 23 2016"]) != 0) {
        
        return;
    }
    
    NSMutableString *version = [NSMutableString stringWithFormat:@"SDK Ver.: %@", [[NskAlgoSdk sharedInstance] getSdkVersion]];
    if (algoTypes & NskAlgoEegTypeAP) {
        [version appendFormat:@"\nAppreciation Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEegTypeAP]];
    }
    if (algoTypes & NskAlgoEegTypeME) {
        [version appendFormat:@"\nMental Effort Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEegTypeME]];
    }
    if (algoTypes & NskAlgoEegTypeME2) {
        [version appendFormat:@"\nMental Effort 2 Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEegTypeME2]];
    }
    if (algoTypes & NskAlgoEegTypeF) {
        [version appendFormat:@"\nFamiliarity Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEegTypeF]];
    }
    if (algoTypes & NskAlgoEegTypeF2) {
        [version appendFormat:@"\nFamiliarity 2 Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEegTypeF2]];
    }
    if (algoTypes & NskAlgoEegTypeAtt) {
        [version appendFormat:@"\nAttention Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEegTypeAtt]];
    }
    if (algoTypes & NskAlgoEegTypeMed) {
        [version appendFormat:@"\nMeditation Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEegTypeMed]];
    }
    if (algoTypes & NskAlgoEegTypeBP) {
        [version appendFormat:@"\nEEG Bandpower Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEegTypeBP]];
    }
    if (algoTypes & NskAlgoEegTypeBlink) {
        [version appendFormat:@"\nBlink Detection Ver.: %@", [[NskAlgoSdk sharedInstance] getAlgoVersion:NskAlgoEegTypeBlink]];
    }
    
    NSLog(@"%@", version);
    
}


- (NSString*)GetCurrentTimeStamp
{
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss:SSS";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:now];
}

- (NSString *) timeInMiliSeconds
{
    NSDate *date = [NSDate date];
    NSString * timeInMS = [NSString stringWithFormat:@"%lld", [@(floor([date timeIntervalSince1970] * 1000)) longLongValue]];
    return timeInMS;
}

-(NSString *) NowString{
    
    NSDate *date=[NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

static long long current_timestamp() {
    struct timeval te;
    gettimeofday(&te, NULL);
    long long milliseconds = te.tv_sec*1000LL + te.tv_usec/1000; // caculate milliseconds
    return milliseconds;
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"CONNECTION_STATE": @"CONNECTION_STATE",
             @"CONNECTION_ERROR": @"CONNECTION_ERROR",
             @"SIGNAL_QUALITY": @"SIGNAL_QUALITY",
             @"ATTENTION_ALGO_INDEX": @"ATTENTION_ALGO_INDEX",
             @"MEDITATION_ALGO_INDEX": @"MEDITATION_ALGO_INDEX",
             @"APPRECIATION_ALGO_INDEX": @"APPRECIATION_ALGO_INDEX",
             @"MENTAL_EFFORT_ALGO_INDEX": @"MENTAL_EFFORT_ALGO_INDEX",
             @"MENTAL_EFFORT2_ALGO_INDEX": @"MENTAL_EFFORT2_ALGO_INDEX",
             @"FAMILIARITY_ALGO_INDEX": @"FAMILIARITY_ALGO_INDEX",
             @"FAMILIARITY2_ALGO_INDEX": @"FAMILIARITY2_ALGO_INDEX",
             
             @"CONNECTION_STATE_INIT": @(STATE_INIT),
             @"CONNECTION_STATE_CONNECTING": @(STATE_CONNECTING),
             @"CONNECTION_STATE_CONNECTED": @(STATE_CONNECTED),
             @"CONNECTION_STATE_WORKING": @(STATE_WORKING),
             @"CONNECTION_STATE_STOPPED": @(STATE_STOPPED),
             @"CONNECTION_STATE_DISCONNECTED": @(STATE_DISCONNECTED),
             @"CONNECTION_STATE_COMPLETE": @(STATE_COMPLETE),
             @"CONNECTION_STATE_RECORDING_START": @(STATE_RECORDING_START),
             @"CONNECTION_STATE_RECORDING_END": @(STATE_RECORDING_END),
             @"CONNECTION_STATE_GET_DATA_TIME_OUT": @(STATE_GET_DATA_TIME_OUT),
             @"CONNECTION_STATE_ERROR": @(STATE_ERROR),
             @"CONNECTION_STATE_FAILED": @(STATE_FAILED),
             
             @"SIGNAL_QUALITY_GOOD": @(0),
             @"SIGNAL_QUALITY_MEDIUM": @(1),
             @"SIGNAL_QUALITY_POOR": @(2),
             @"SIGNAL_QUALITY_NOT_DETECTED": @(3),
             };
}




@end
