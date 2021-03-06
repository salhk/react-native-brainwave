//
//  MWMEnum.h
//
//  Created by test on 09/06/16.
//  Copyright (c) 2016 neurosky. All rights reserved.
//

#pragma mark -- TGBleConfig --
typedef NS_ENUM(NSUInteger, TGMWMConfigCMD){
    TGMWMConfigCMD_ChangeNotchTo_50,
    TGMWMConfigCMD_ChangeNotchTo_60
};

#pragma mark -- LoggingOptions --
typedef NS_ENUM(NSUInteger, LoggingOptions){
    LoggingOptions_Raw  = 1,
    LoggingOptions_Processed = 1 << 1,
};

//device type MindWaveMobile or CardioStartKit
typedef NS_ENUM(NSInteger, DEVICE_TYPE){
    
    DEVICE_TYPE_UNKNOWN = 0,
    DEVICE_TYPE_MindWaveMobile = 1,
    DEVICE_TYPE_CardioChipStarterKit = 2,
    
};

//data type correspond to different device
typedef NS_ENUM(NSUInteger, MindDataType)
{
    
    MindDataType_CODE_POOR_SIGNAL = 2,
    
    MindDataType_CODE_RAW = 128,
    
    MindDataType_CODE_ATTENTION = 4,
    
    MindDataType_CODE_MEDITATION = 5,
    
    MindDataType_CODE_EEGPOWER = 131,
    
};

typedef NS_ENUM(NSUInteger, BodyDataType)
{
    
    BodyDataType_CODE_POOR_SIGNAL = 2,
    
    BodyDataType_CODE_RAW = 128,
    
    BodyDataType_CODE_HEARTRATE = 3,
    
};

//parser type
typedef NS_ENUM(NSUInteger, ParserType){
    
    PARSER_TYPE_DEFAULT = 0,
    
};


//connection states
typedef NS_ENUM(NSUInteger,ConnectionStates){
    
    STATE_INIT = 0,
    
    STATE_CONNECTING = 1,
    
    STATE_CONNECTED = 2,
    
    STATE_WORKING = 3,
    
    STATE_STOPPED = 4,
    
    STATE_DISCONNECTED = 5,
    
    STATE_COMPLETE = 6,
    
    STATE_RECORDING_START = 7,
    
    STATE_RECORDING_END = 8,
    
    STATE_GET_DATA_TIME_OUT = 9,
    
    STATE_FAILED = 100,
    
    STATE_ERROR = 101
};

//raw data  record error
typedef NS_ENUM(NSUInteger,RecrodError){
    
    RECORD_ERROR_FILE_PATH_NOT_READY =1,
    
    RECORD_ERROR_RECORD_IS_ALREADY_WORKING =2,
    
    RECORD_ERROR_RECORD_OPEN_FILE_FAILED =3,
    
    RECORD_ERROR_RECORD_WRITE_FILE_FAILED =4
    
};


