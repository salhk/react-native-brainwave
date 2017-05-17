//
//  RNBrainwave.h
//  RNBrainwave
//
//  Created by jimmy on 14/02/2017.
//

#if TARGET_IPHONE_SIMULATOR
#else
#import "TGStreamEnum.h"
#endif
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <AlgoSdk/NskAlgoSdk.h>
#import <React/RCTEventEmitter.h>
#import "MWMDelegate.h"
#import "MWMDevice.h"


#if TARGET_IPHONE_SIMULATOR
@interface RNBrainwave : NSObject<RCTBridgeModule, NskAlgoSdkDelegate>
#else
@interface RNBrainwave : RCTEventEmitter<RCTBridgeModule, NskAlgoSdkDelegate, MWMDelegate>
#endif


@end


