//
//  EEGPower.m
//  RNBrainwave
//
//  Created by Jimmy Hu on 5/17/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEGPower.h"

@implementation EEGPower

-(id)init {
    if (self = [super init]) {
        self.delta = -1;
        self.theta = -1;
        self.lowAlpha = -1;
        self.highAlpha = -1;
        self.lowBeta = -1;
        self.highBeta = -1;
        self.lowGamma = -1;
        self.midGamma = -1;
    }
    return self;
}


@end
