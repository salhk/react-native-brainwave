//
//  EEGPower.h
//  RNBrainwave
//
//  Created by Jimmy Hu on 5/17/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#ifndef EEGPower_h
#define EEGPower_h

@interface EEGPower : NSObject

@property int delta;
@property int theta;
@property int lowAlpha;
@property int highAlpha;
@property int lowBeta;
@property int highBeta;
@property int lowGamma;
@property int midGamma;

@end


#endif /* EEGPower_h */
