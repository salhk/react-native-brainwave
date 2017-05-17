//
//  EsenseEvent.h
//  RNBrainwave
//
//  Created by Jimmy Hu on 5/10/17.
//  Copyright © 2017 Facebook. All rights reserved.
//


#import "EEGPower.h"

@interface EsenseEvent : NSObject

@property long timestamp;
@property int poorSignal;
@property NSNumber *attention;
@property NSNumber *meditation;
@property EEGPower* eegPower;



@end
