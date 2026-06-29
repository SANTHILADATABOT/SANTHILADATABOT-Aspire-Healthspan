//
//  SleepModel.h
//  ClingSDK
//
//  Created by LinZhiSong on 07/03/2017.
//  Copyright © 2017 Roffa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepModel : NSObject

// Start time of the sleep session (timestamp)
@property (nonatomic, assign) long mlStartTime;

// End time of the sleep session (timestamp)
@property (nonatomic, assign) long mlEndTime;

// mnSleepState: (0: no value; 1: awake; 2: light sleep; 3: sound(deep) sleep; other: mid)
@property (nonatomic, assign) short mnSleepState;

// Get the duration of the sleep session
- (long) getDuration;

// Get the middle timestamp of the sleep session
- (long) getMiddleTimestamp;

// Convert the sleep model data to a string representation
- (NSString *) toString;

@end

@interface SleepCycle : NSObject

// Sleep cycle number
@property (nonatomic, assign) int mnCycleNumber;

// Start time of the sleep cycle (timestamp)
@property (nonatomic, assign) long mlStartTime;

// End time of the sleep cycle (timestamp)
@property (nonatomic, assign) long mlEndTime;

// Average heart rate during light sleep
@property (nonatomic, assign) int mnHeartRateLightSleep;

// Skin temperature during light sleep
@property (nonatomic, assign) float mfSkinTemperatureLightSleep;

// Average heart rate during deep sleep
@property (nonatomic, assign) int mnHeartRateSoundSleep;

// Skin temperature during deep sleep
@property (nonatomic, assign) float mfSkinTemperatureSoundSleep;

// Body temperature during light sleep
@property (nonatomic, assign) float mfBodyTemperatureLightSleep;

// Body temperature during deep sleep
@property (nonatomic, assign) float mfBodyTemperatureSoundSleep;

// Get the middle timestamp of the sleep cycle
- (long) getMiddleTimestamp;

// Convert the sleep cycle data to a string representation
- (NSString *) toString;

@end


@interface SleepPercentage : NSObject

// Percentage of time spent awake
@property (nonatomic, assign) int iAwakePt;

// Percentage of time spent in light sleep
@property (nonatomic, assign) int iLightPt;

// Percentage of time spent in intermediate sleep (if applicable)
@property (nonatomic, assign) int iMiddlePt;

// Percentage of time spent in deep sleep
@property (nonatomic, assign) int iSoundPt;

@end
