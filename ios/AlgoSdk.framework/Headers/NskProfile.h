//
//  NskProfile.h
//  AlgoSdk
//
//  Created by Terence Yeung on 4/4/2016.
//  Copyright © 2016 NeuroSky. All rights reserved.
//

#ifndef NskProfile_h
#define NskProfile_h

@interface NskProfile : NSObject
@property (nonatomic) NSInteger userId;                 /* System generated unique id */
@property (nonatomic, strong) NSString * userName;      /* Name of the profile */
@property (nonatomic) NSDate * dob;                     /* Date of birth, UTC time */
@property (nonatomic) NSInteger height;                 /* Height, unit in cm */
@property (nonatomic) NSInteger weight;                 /* Weight, unit in kg */
@property BOOL gender;                                  /* true = female, false = male */
@end

#endif /* NskProfile_h */
