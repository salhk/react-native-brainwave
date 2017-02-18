//
//  RNBrainwave.h
//  RNBrainwave
//
//  Created by jimmy on 14/02/2017.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <AlgoSdk/NskAlgoSdk.h>
#if TARGET_IPHONE_SIMULATOR
#else
#import "TGStreamDelegate.h"
#endif

#if TARGET_IPHONE_SIMULATOR
@interface RNBrainwave : NSObject<RCTBridgeModule, NskAlgoSdkDelegate>
#else
@interface RNBrainwave : NSObject<RCTBridgeModule, NskAlgoSdkDelegate, TGStreamDelegate>
#endif


@end


