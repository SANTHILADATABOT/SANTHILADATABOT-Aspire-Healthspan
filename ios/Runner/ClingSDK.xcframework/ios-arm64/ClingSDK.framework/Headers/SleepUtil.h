//
//  SleepUtil.h
//  ClingSDK
//
//  Created by LinZhiSong on 07/03/2017.
//  Copyright © 2017 Roffa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SleepModel.h"

@interface SleepUtil : NSObject

/**
 * Classifies the sleep states based on minute-level data.
 * @param arrlstMin An array of minute-level sleep data.
 * @return An array representing classified sleep states. @[SleepModel]
 */
+ (NSArray*) getClassfiedSleepState:(NSArray*) arrlstMin;
/**
 * Classifies sleep cycles based on sleep data and age.
 * @param arrlstSleep An array of sleep data.
 * @param nAge The age of the user.
 * @return An array representing classified sleep cycles. @[SleepCycle]
 */
+ (NSArray*) getClassfiedSleepCycle:(NSArray*) arrlstSleep age:(int) nAge;
/**
 * Calculates the average sports-related parameters for each sleep cycle.
 * @param arrlstCycle An array of sleep cycle data.
 * @param arrlstMin An array of minute-level data.
 */
+ (void) calculateSportParamsAvg:(NSArray*) arrlstCycle minuteData:(NSArray*) arrlstMin;
/**
 * Calculates sports-related parameters for each sleep cycle.
 * @param arrlstCycle An array of sleep cycle data.
 * @param arrlstMin An array of minute-level data.
 */
+ (void) calculateSportParams:(NSArray*) arrlstCycle minuteData:(NSArray*) arrlstMin;
/**
 * Determines whether the given sleep cycle is the best period to wake up based on age.
 * @param nCycleIndex The index of the sleep cycle.
 * @param nAge The age of the user.
 * @return A boolean indicating whether it is the best period to wake up.
 */
+ (BOOL) isBestAwakePeriod:(int) nCycleIndex age:(int) nAge;

/**
 * Calculates the sleep score based on various sleep parameters.
 * @param arrlstData An array of sleep data.
 * @param arrlstCycle An array of sleep cycle data.
 * @param level The level of sleep analysis.
 * @param gender The gender of the user (0 for male, 1 for female).
 * @param age The age of the user.
 * @param sleepSeconds Total sleep duration in seconds.
 * @param deepSeconds Total deep sleep duration in seconds.
 * @return An integer representing the sleep score.
 */
+ (int) getSleepScore:(NSArray*) arrlstData cycle:(NSArray*) arrlstCycle level:(int) level gender:(int)gender age:(int)age sleep:(long) sleepSeconds deepSleep:(long) deepSeconds;
/**
 * Calculates the percentage distribution of different sleep stages.
 * @param arrlstSleep An array of sleep data.
 * @return A SleepPercentage object containing sleep stage percentages.
 */
+ (SleepPercentage *) getSleepPercent:(NSArray*) arrlstSleep;
/**
 * Extracts the start and end sleep times from classified sleep states.
 * @param array An array obtained from getClassfiedSleepState.
 * @return An array where the first object (NSNumber) is the sleep start time and the last object (NSNumber) is the wake-up time.
 */
+ (NSArray*)getStartAndEndSleep:(NSArray*)array;        //根据getClassfiedSleepState获得的数组遍历出，入睡点与醒来点。通过数组返回。firstobject=入睡时间NSnumber  lastobject=醒来时间
@end
