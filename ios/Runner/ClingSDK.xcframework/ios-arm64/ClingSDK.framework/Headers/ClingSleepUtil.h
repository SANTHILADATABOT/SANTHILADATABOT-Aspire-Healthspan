//
//  ClingSleepUtil.h
//  ClingSDK
//
//  Created by LinZhiSong on 2018/8/22.
//  Copyright © 2018 Roffa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClingUtilsModel.h"

@interface ClingSleepUtil : NSObject

+ (int) getSleepScore:(NSArray*)arrlstMinuteData level:(int)level gender:(int)gender age:(int)age;
+ (NSArray *) getSleepCycle:(NSArray*)arrlstMinuteData age:(int)age;
+ (NSArray<NSNumber *>*)getStartAndEndSleep:(NSArray<ClingMinuteData *>*)arrlstMinuteData;

@end

@interface ClingSleepCycleModel : NSObject

@property (nonatomic, assign) int mnCycleNumber;
@property (nonatomic, assign) long mlStartTime;
@property (nonatomic, assign) long mlEndTime;

@end

