/**
 ******************************************************************************
 * @file    NskAlgoSdk.h
 * @author  Algo SDK Team
 * @version V0.1
 * @date    12-May-2015
 * @brief   Algo SDK Objective-C wrapper layer
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; COPYRIGHT(c) NeuroSky Inc. All rights reserved.</center></h2>
 *
 *
 ******************************************************************************
 */

#import <Foundation/Foundation.h>
#import "NskProfile.h"

/* EEG data signal quality definitions */
typedef NS_ENUM(NSInteger, NskAlgoSignalQuality) {
    NskAlgoSignalQualityGood,           /* Signal quality is in good level */
    NskAlgoSignalQualityMedium,         /* Signal quality is in medium level */
    NskAlgoSignalQualityPoor,           /* Signal quality is in poor level */
    NskAlgoSignalQualityNotDetected     /* Sensor signal is not detected */
};

/* SDK |  definitions */
typedef NS_ENUM(NSInteger, NskAlgoState) {
    NskAlgoStateInited = 1,             /* Algo SDK initialized */
    NskAlgoStateRunning,                /* Algo SDK is performing analysis (i.e. startProcess() invoked) */
    NskAlgoStateCollectingBaselineData, /* Algo SDK is collecting baseline data */
    NskAlgoStateStop,                   /* Algo SDK stops data analysis/baseline collection */
    NskAlgoStatePause,                  /* Algo SDK pauses data analysis */
    NskAlgoStateUninited,               /* Algo SDK is uninitialized */
    NskAlgoStateAnalysingBulkData       /* Algo SDK is analysing a bulk of EEG data */
};

/* SDK state change reason definitions */
typedef NS_ENUM(NSInteger, NskAlgoReason) {
    NskAlgoReasonConfigChanged = 1,      /* SDK configuration changed */
    NskAlgoReasonUserProfileChanged,     /* RESERVED: Active user profile has been changed */
    NskAlgoReasonUserTrigger,            /* User triggers */
    NskAlgoReasonBaselineExpired,        /* RESERVED: Baseline expired */
    NskAlgoReasonNoBaseline,             /* No baseline data collected yet */
    NskAlgoReasonSignalQuality,          /* Due to signal quality */
    NskAlgoReasonExpired,                /* FOR EVALUATION ONLY: SDK has been expired */
    NskAlgoReasonInternetError,          /* FOR EVALUATION ONLY: internet connection error */
    NskAlgoReasonKeyError                /* FOR EVALUATION ONLY: evaluation license key error */
};

typedef NS_ENUM(NSInteger, NskAlgoF2ProgressLevel) {
    NskAlgoF2ProgressLevelVeryBad = 1,
    NskAlgoF2ProgressLevelBad,
    NskAlgoF2ProgressLevelFlat,
    NskAlgoF2ProgressLevelGood,
    NskAlgoF2ProgressLevelGreat
};

/* EEG algorithm type definitions */
typedef NS_ENUM(NSInteger, NskAlgoType) {
    NskAlgoEegTypeAP            = 0x00000001,            /* Appreciation */
    NskAlgoEegTypeME            = 0x00000002,            /* Mental Effort */
    NskAlgoEegTypeME2           = 0x00000004,            /* Mental Effort Secondary Algorithm */
    NskAlgoEegTypeAtt           = 0x00000008,            /* Attention */
    NskAlgoEegTypeMed           = 0x00000010,            /* Meditation */
    NskAlgoEegTypeF             = 0x00000020,            /* Familiarity */
    NskAlgoEegTypeF2            = 0x00000040,            /* Familiarity Secondary Algorithm */
    NskAlgoEegTypeBlink         = 0x00000080,            /* Eye Blink Detection */
    NskAlgoEegTypeCR            = 0x00000100,            /* Creativity */
    NskAlgoEegTypeAL            = 0x00000200,            /* Alertness */
    NskAlgoEegTypeCP            = 0x00000400,            /* Cognitive Preparedness */
    NskAlgoEegTypeBP            = 0x00000800,            /* EEG Bandpower */
    NskAlgoEcgTypeHeartRate     = 0x00001000,            /* ECG values, basic information including heart rate, RRI */
    NskAlgoEcgTypeStress        = 0x00002000,            /* Stress value */
    NskAlgoEcgTypeMood          = 0x00004000,            /* Mood value */
    NskAlgoEcgTypeHeartAge      = 0x00008000,            /* Heart Age */
    NskAlgoEcgTypeHRV           = 0x00010000,            /* HRV */
    NskAlgoEcgTypeSmooth        = 0x00020000,            /* Smooth Filter */
    NskAlgoEcgTypeRespiratory   = 0x00040000,            /* Respiratory rate */
    NskAlgoEcgTypeAfib          = 0x00080000,            /* AFIB */
    NskAlgoEcgTypeHRVTD         = 0x00100000,            /* HRV Time Domain Analysis */
    NskAlgoEcgTypeHRVFD         = 0x00200000             /* HRV Frequency Domain Analysis */
};

/* EEG data type definitions (data from COMM SDK) */
typedef NS_ENUM(NSInteger, NskAlgoDataType) {
    NskAlgoDataTypeEEG = 0,  /* Raw EEG data */
    NskAlgoDataTypeAtt,      /* Attention data */
    NskAlgoDataTypeMed,      /* Meditation data */
    NskAlgoDataTypePQ,       /* Poor signal quality data */
    NskAlgoDataTypeBulkEEG,  /* Bulk EEG data (must be multiple of 512, i.e. Ns of continuous GOOD EEG data */
    NskAlgoDataTypeECG,      /* ECG data */
    NskAlgoDataTypeECGPQ,    /* ECG data PQ */
    NskAlgoDataTypeBulkECG   /* reserved, not supported */
};

typedef NS_ENUM(NSInteger, NskProfileActionType) {
    NskProfileActionTypeAdd = 0,    /* Add new profile into the profile list and save to persistent storage */
    NskProfileActionTypeRemove,     /* Remove the profile from the list based on the profile id */
    NskProfileActionTypeGetList,    /* Get the profile list from the persistent storage */
    NskProfileActionTypeActive      /* Set the profile as active based on the profile id */
};

/* Brain Conditioning Quantification threshold */
typedef NS_ENUM(NSInteger, NskAlgoBCQThreshold) {
    NskAlgoBCQThresholdLight = 0,
    NskAlgoBCQThresholdMedium,
    NskAlgoBCQThresholdHigh
};

/* Brain Conditioning Quantification return type */
typedef NS_ENUM(NSInteger, NskAlgoBCQIndexType) {
    NskAlgoBCQIndexTypeValue = 0,   /* only cr_value/al_value/cp_value is valid */
    NskAlgoBCQIndexTypeValid,       /* only BCQ_valid is valid */
    NskAlgoBCQIndexTypeBoth         /* both cr_value/al_value/cp_value and BCQ_valid are valid */
};

/* Data calculated from the algorithms */
typedef NS_ENUM(NSInteger, NskAlgoECGValueType) {
    NskAlgoEcgValueTypeHeartRate = 1,         /* Heart Rate */
    NskAlgoEcgValueTypeRobust,                /* Robust Heart Rate */
    NskAlgoEcgValueTypeMood,                  /* Mood */
    NskAlgoEcgValueTypeR2R,                   /* R2R interval */
    NskAlgoEcgValueTypeHRV,                   /* Compute Heart Rate Variability */
    NskAlgoEcgValueTypeHeartage,              /* Heart Age */
    NskAlgoEcgValueTypeAFIB,                  /* AFIB */
    NskAlgoEcgValueTypeRDetected,             /* Detected R peak */
    NskAlgoEcgValueTypeSmoothed,              /* Smoothed data */
    NskAlgoEcgValueTypeStress,                /* Stress level */
    NskAlgoEcgValueTypeHeartbeat,             /* Heart beat count */
    NskAlgoEcgValueTypeRespiratoryRate,       /* Respiratory rate */
    NskAlgoEcgValueTypeBaselineUpdated,       /* ECG baseline is updated */
    NskAlgoEcgValueTypeHRVTimeDomain,         /* Time Domain Analysis */
    NskAlgoEcgValueTypeHRVFreqDomain          /* Frequency Domain Analysis */
};

typedef NS_ENUM(NSInteger, NskAlgoECGStressLevel) {
    NskAlgoEcgStressLevelUnknwon = 0,    /* Invalid stress level */
    NskAlgoEcgStressLevelNo,             /* No stress at all */
    NskAlgoEcgStressLevelLow,            /* Low stress level */
    NskAlgoEcgStressLevelMedium,         /* Medium stress level */
    NskAlgoEcgStressLevelHigh,           /* High stress level */
    NskAlgoEcgStressLevelVeryhigh        /* Very high stress level */
};

/* The data sampling rate, which is required the configuration on the sensor chips */
typedef NS_ENUM(NSInteger, NskAlgoSampleRate) {
    NskAlgoSampleRate256 = 0,
    NskAlgoSampleRate300 = 1,
    NskAlgoSampleRate512 = 2,
    NskAlgoSampleRate600 = 3                // reserved
};

@protocol NskAlgoSdkDelegate <NSObject>

@required
/* notification on SDK state change */
- (void) stateChanged: (NskAlgoState)state reason:(NskAlgoReason)reason;

@optional
/* notification on EEG algorithm index */
- (void) apAlgoIndex: (NSNumber*)ap_index;

- (void) meAlgoIndex: (NSNumber*)abs_me diff_me:(NSNumber*)diff_me max_me:(NSNumber*)max_me min_me:(NSNumber*)min_me;

- (void) me2AlgoIndex: (NSNumber*)total_me me_rate:(NSNumber*)me_rate changing_rate:(NSNumber*)changing_rate;

- (void) fAlgoIndex: (NSNumber*)abs_f diff_f:(NSNumber*)diff_f max_f:(NSNumber*)max_f min_f:(NSNumber*)min_f;

- (void) f2AlgoIndex: (NSNumber*)progress f_degree:(NSNumber*)f_degree;

- (void) attAlgoIndex: (NSNumber*)att_index;

- (void) medAlgoIndex: (NSNumber*)med_index;

- (void) eyeBlinkDetect: (NSNumber*)strength;

- (void) bpAlgoIndex: (NSNumber*)delta theta:(NSNumber*)theta alpha:(NSNumber*)alpha beta:(NSNumber*)beta gamma:(NSNumber*)gamma;

- (void) crAlgoIndex: (NskAlgoBCQIndexType)cr_index_type cr_value:(NSNumber*)cr_value BCQ_valid:(BOOL)BCQ_valid;

- (void) alAlgoIndex: (NskAlgoBCQIndexType)al_index_type al_value:(NSNumber*)al_value BCQ_valid:(BOOL)BCQ_valid;

- (void) cpAlgoIndex: (NskAlgoBCQIndexType)cp_index_type cp_value:(NSNumber*)cp_value BCQ_valid:(BOOL)BCQ_valid;

- (void) ecgAlgoValue: (NskAlgoECGValueType)ecg_value_type ecg_value:(NSNumber*)ecg_valid ECG_valid:(BOOL)ECG_valid;

- (void) ecgHRVTDAlgoValue: (NSNumber*)nn50 sdnn:(NSNumber*)sdnn pnn50:(NSNumber*)pnn50 rrTranIndex:(NSNumber*)rrTranIndex rmssd:(NSNumber*)rmssd;

- (void) ecgHRVFDAlgoValue: (NSNumber*)hf lf:(NSNumber*)lf lfhf_ratio:(NSNumber*)lfhf_ratio hflf_ratio:(NSNumber*)hflf_ratio;

/* notification on signal quality */
- (void) signalQuality: (NskAlgoSignalQuality)signalQuality;

/* notification on overall signal quality */
- (void) overallSignalQuality: (NSNumber*)signalQuality;

@end

@interface NskAlgoSdk : NSObject {
    id <NskAlgoSdkDelegate> delegate;
}

@property (retain) id delegate;

+ (id) sharedInstance;

/* set algorithm type(s)
 Return: 0 - Algo SDK is initialized successfully; Otherwise, something wrong on SDK initialization
 */
- (NSInteger) setAlgorithmTypes: (NskAlgoType)algoTypes licenseKey:(char *)licenseKey;

/* get algorithm version */
- (NSString*) getAlgoVersion: (NskAlgoType)algoType;

/* get SDK version */
- (NSString*) getSdkVersion;

/* set algorithm index output interval
 Note1: Different algorithms will have different output interval (both minimum and maximum).
 Appreciation: min - 1 seconds, max - 5 seconds
 Note2: NskAlgoEegTypeAtt and NskAlgoEegTypeMed cannot be changed. They are always equal 1.
 Note3: For NskAlgoEegTypeCR, NskAlgoEegTypeAL and NskAlgoEegTypeCP, please use setCreativityAlgoConfig, setAlertnessAlgoConfig and setCognitivePreparednessAlgoConfig correspectively
 */
- (BOOL) setAlgoIndexOutputInterval: (NskAlgoType)algoType outputInterval:(NSInteger)outputInterval;

/* set BCQ creativity algorithm configuration */
- (BOOL) setCreativityAlgoConfig: (NSInteger)outputInterval threshold:(NskAlgoBCQThreshold)threshold window:(NSInteger)window;

/* set BCQ alertness algorithm configuration */
- (BOOL) setAlertnessAlgoConfig: (NSInteger)outputInterval threshold:(NskAlgoBCQThreshold)threshold window:(NSInteger)window;

/* set BCQ cognitive preparedness algorithm configuration */
- (BOOL) setCognitivePreparednessAlgoConfig: (NSInteger)outputInterval threshold:(NskAlgoBCQThreshold)threshold window:(NSInteger)window;

/* set ECG Stress algorithm configuration */
- (BOOL) setECGStressAlgoConfig: (NSInteger)stressPoint stressPara:(NSInteger)stressPara;

/* set ECG HRV algorithm configuration */
- (BOOL) setECGHRVAlgoConfig: (NSInteger)HRVInteval;

/* set ECG AFIB algorithm configuration */
- (BOOL) setECGAFIBAlgoConfig: (float)threshold;

/* set ECG HRV algorithm configuration */
- (BOOL) setECGHeartageAlgoConfig: (NSInteger)heartagePoint;

/* set ECG HRV TD algorithm configuration */
- (BOOL) setECGHRVTDAlgoConfig: (NSInteger)window interval:(NSInteger)interval;

/* set ECG HRV FD algorithm configuration */
- (BOOL) setECGHRVFDAlgoConfig: (NSInteger)window interval:(NSInteger)interval;

/* start data analysis */
- (BOOL) startProcess;

/* pause data analysis */
- (BOOL) pauseProcess;

/* stop data analysis */
- (BOOL) stopProcess;

/* EEG raw data stream (from COMM SDK) */
- (BOOL) dataStream: (NskAlgoDataType)type data:(int16_t*)data length:(int32_t)length;

/* Query the data overall quality */
- (BOOL) queryOveralQuality:(NskAlgoDataType)type;

/* Load the profile from the database */
- (NSArray*) getProfiles;

/* Create new (id = 0) or update existing profile */
- (BOOL) updateProfile:(NskProfile *) profile;

/* Get the profile baseline data */
- (NSData*) getProfileBaseline:(NSInteger)profileId type:(NskAlgoType)type;

/* Set the profile baseline data */
- (BOOL) setProfileBaseline:(NSInteger)profileId type:(NskAlgoType)type data:(NSData*)data;

/* Delete a profile */
- (BOOL) deleteProfile: (NSInteger) id;

/* Set a profile as active profile */
- (BOOL) setActiveProfile: (NSInteger) id;

/* Set baud rate of the stream data */
- (BOOL) setSampleRate:(NskAlgoDataType)type sampleRate:(NskAlgoSampleRate)sampleRate;

/* Set the signal quality watchdog timeout */
- (BOOL) setSignalQualityWatchDog: (NskAlgoDataType)type timeout:(int16_t)timeout recoveryTimeOut:(int16_t)recoveryTimeOut;

@end
