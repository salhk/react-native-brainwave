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

#ifndef IOS_DEVICE
#define SAMPLE_COUNT        600
float ap[SAMPLE_COUNT];
float me[SAMPLE_COUNT];
float f[SAMPLE_COUNT];
float f2[SAMPLE_COUNT];
#endif
int bp_index = 0;


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
}


- (void)signalQuality:(NskAlgoSignalQuality)signalQuality {
    if (signalStr == nil) {
        signalStr = [[NSMutableString alloc] init];
    }
    [signalStr setString:@""];
    [signalStr appendString:@"Signal quailty: "];
    switch (signalQuality) {
        case NskAlgoSignalQualityGood:
            [signalStr appendString:@"Good"];
            break;
        case NskAlgoSignalQualityMedium:
            [signalStr appendString:@"Medium"];
            break;
        case NskAlgoSignalQualityNotDetected:
            [signalStr appendString:@"Not detected"];
            break;
        case NskAlgoSignalQualityPoor:
            [signalStr appendString:@"Poor"];
            break;
    }

    
    printf("%s", [signalStr UTF8String]);
    printf("\n");
}

- (void)bpAlgoIndex:(NSNumber *)delta theta:(NSNumber *)theta alpha:(NSNumber *)alpha beta:(NSNumber *)beta gamma:(NSNumber *)gamma {
    NSLog(@"bp[%d] = (delta)%1.6f (theta)%1.6f (alpha)%1.6f (beta)%1.6f (gamma)%1.6f", bp_index, [delta floatValue], [theta floatValue], [alpha floatValue], [beta floatValue], [gamma floatValue]);
    bp_index++;
    
    //    [self addValue:delta array:[algoList[SegmentEEGBandpower] getIndex:0]];
    //    [self addValue:theta array:[algoList[SegmentEEGBandpower] getIndex:1]];
    //    [self addValue:alpha array:[algoList[SegmentEEGBandpower] getIndex:2]];
    //    [self addValue:beta array:[algoList[SegmentEEGBandpower] getIndex:3]];
    //    [self addValue:gamma array:[algoList[SegmentEEGBandpower] getIndex:4]];
}

- (void)apAlgoIndex:(NSNumber *)value {
    NSLog(@"ap[%d] = %1.15f", ap_index, [value floatValue]);
    lAppreciation = [value floatValue];
#ifndef IOS_DEVICE
    ap[ap_index] = lAppreciation;
#endif
    ap_index++;
    
    //    [self addValue:value array:[algoList[SegmentAppreciation] getIndex:0]];
}

- (void)meAlgoIndex:(NSNumber *)abs_me diff_me:(NSNumber *)diff_me max_me:(NSNumber *)max_me min_me:(NSNumber *)min_me {
    
    NSLog(@"me[%d] = ABS:%1.8f DIF:%1.8f [%1.0f:%1.0f]", me_index, [abs_me floatValue], [diff_me floatValue], [min_me floatValue], [max_me floatValue]);
    lMentalEffort_abs = [abs_me floatValue];
    lMentalEffort_diff = [diff_me floatValue];
#ifndef IOS_DEVICE
    me[me_index] = lMentalEffort_abs;
#endif
    me_index++;
    //    [self addValue:abs_me array:[algoList[SegmentMentalEffort] getIndex:0]];
    //    [self addValue:diff_me array:[algoList[SegmentMentalEffort] getIndex:1]];
}

- (void) me2AlgoIndex: (NSNumber*)total_me me_rate:(NSNumber*)me_rate changing_rate:(NSNumber*)changing_rate {
    NSLog(@"me2[%d] = (total)%1.6f (rate)%1.6f (chg rate)%1.6f", me2_index, [total_me floatValue], [me_rate floatValue], [changing_rate floatValue]);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm:ss"];
        
    });
    
    me2_index++;
}

- (void)fAlgoIndex:(NSNumber *)abs_f diff_f:(NSNumber *)diff_f max_f:(NSNumber *)max_f min_f:(NSNumber *)min_f {
    
    
    NSLog(@"f[%d] = ABS:%1.8f DIF:%1.8f [%1.0f:%1.0f]", f_index, [abs_f floatValue], [diff_f floatValue], [min_f floatValue], [max_f floatValue]);
#ifndef IOS_DEVICE
    f[f_index] = [abs_f floatValue];
#endif
    f_index++;
    //    [self addValue:abs_f array:[algoList[SegmentFamiliarity] getIndex:0]];
    //    [self addValue:diff_f array:[algoList[SegmentFamiliarity] getIndex:1]];
}

- (void)f2AlgoIndex:(NSNumber *)progress f_degree:(NSNumber *)f_degree {
    NSLog(@"f2[%d] = %d, %1.15f", f2_index, [progress intValue], [f_degree floatValue]);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm:ss"];
        
    });
    f2_index++;
}

- (void)medAlgoIndex:(NSNumber *)med_index {
    //NSLog(@"Meditation: %f", [value floatValue]);
    lMeditation = [med_index floatValue];
    dispatch_sync(dispatch_get_main_queue(), ^{
        //        [_medLevelIndicator setProgress:(lMeditation/100.0f)];
        //        [_medValue setText:[NSString stringWithFormat:@"%3.0f", lMeditation]];
    });
}

- (void)attAlgoIndex:(NSNumber *)att_index {
    //NSLog(@"Attention: %f", [value floatValue]);
    lAttention = [att_index floatValue];
    dispatch_sync(dispatch_get_main_queue(), ^{
        //        [_attLevelIndicator setProgress:(lAttention/100.0f)];
        //        [_attValue setText:[NSString stringWithFormat:@"%3.0f", lAttention]];
    });
}

BOOL bBlink = NO;
- (void)eyeBlinkDetect:(NSNumber *)strength {
    NSLog(@"Eye blink detected: %d", [strength intValue]);
    dispatch_sync(dispatch_get_main_queue(), ^{
        bBlink = YES;
    });
}


RCT_EXPORT_MODULE()



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
             
             @"CONNECTION_STATE_CONNECTING": @"Monday",
             @"CONNECTION_STATE_CONNECTED": @"Monday",
             @"CONNECTION_STATE_WORKING": @"Monday",
             @"CONNECTION_STATE_GET_DATA_TIMEOUT": @"Monday",
             @"CONNECTION_STATE_STOPPED": @"Monday",
             @"CONNECTION_STATE_DISCONNECTED": @"Monday",
             @"CONNECTION_STATE_ERROR": @"Monday",
             @"CONNECTION_STATE_FAILED": @"Monday",
             @"SIGNAL_QUALITY_GOOD": @"0",
             @"SIGNAL_QUALITY_MEDIUM": @"1",
             @"SIGNAL_QUALITY_POOR": @"2",
             @"SIGNAL_QUALITY_NOT_DETECTED": @"3",
             };
}




@end
