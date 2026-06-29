//
//  ClingUtilsModel.h
//  ClingSDK
//
//  Created by Roffa's Mac on 16/1/29.
//  Copyright © 2016年 Roffa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClingConst.h"


@interface LoginRequestModel : NSObject
@property(nonatomic,strong)NSString *strUsername;       //用户名
@property(nonatomic,strong)NSString *strPassword;            //密码
@property(nonatomic,strong)NSString *strType;           //登录类型   signup:注册登录   login:已有账号登录
/* 通过获取用户当前经纬度，将用户显示在附近人页面 */
@property(nonatomic)float fLat;                       //用户当前纬度
@property(nonatomic)float fLng;                        //用户当前经度
@end

@interface MinuteDataRequestModel : NSObject
@property(nonatomic,strong)NSString *strStartTime;      //起始时间戳
@property(nonatomic,strong)NSString *strEndTime;        //结束时间戳
@property(nonatomic)uint iUserid;           //需要获取的用户id,不传默认为本人id
@end

//健康挑战等级
@interface ClingUserHealthLevelModel : NSObject
@property (nonatomic, assign) int iLevel;   //健康挑战等级  0:入门级 1:基础级 2:活跃级 3:专业级
@property (nonatomic, assign) int iEntry;   //入门级得分
@property (nonatomic, assign) int iBasic;   //基础级得分
@property (nonatomic, assign) int iActive;  //活跃级得分
@property (nonatomic, assign) int iProf;    //专业级得分
@property (nonatomic, assign) int iTotal;   //总天数
@property (nonatomic, assign) int iEntrydays;   //入门级天数
@property (nonatomic, assign) int iBasicdays;  //基础级天数
@property (nonatomic, assign) int iActivedays;  //活跃级天数
@property (nonatomic, assign) int iProfdays;   //专业级天数
@end

//用户信息
@interface ClingUserInfo : NSObject
@property(nonatomic,strong)NSString *strUsername;       //用户名
@property(nonatomic,strong)NSString *strNickname;           //昵称
@property(nonatomic,strong)NSString *strAvatar;         //头像下载地址
@property(nonatomic,strong)NSString *strSignature;      //个性签名
@property(nonatomic,strong)NSString *strProvince;       //省份
@property(nonatomic,strong)NSString *strCity;           //城市
@property(nonatomic,strong)NSString *strIndustry;       //行业
@property(nonatomic,strong)NSString *strCareer;         //职业
@property(nonatomic,strong)NSString *strBirthday;       //生日 如：2014-01-01
@property(nonatomic)unsigned int intUserid;       //用户id
@property(nonatomic)unsigned int intPoint;              //积分
@property(nonatomic)unsigned int intSteps;              //总步数
@property(nonatomic)unsigned short shortGender;             //1:女   0:男
@property(nonatomic)unsigned short shortLevel;                      //用户积分等级
@property(nonatomic)unsigned short shortHeight;         //身高
@property(nonatomic)unsigned short shortWeight;         //体重
@property(nonatomic)unsigned short shortStridelength;            //步长
@property(nonatomic,strong)ClingUserHealthLevelModel *healthLevel;   //入门级、基础级、活跃级、专业级Model entry/basic/active/professional
@end
//分钟数据详情
@interface ClingMinuteData : NSObject

@property(nonatomic) unsigned int intTimestamp;      // 时间戳 / Timestamp
@property(nonatomic) unsigned short shortWalkStep;   // 一分钟内，走路步数 / Walking steps within one minute
@property(nonatomic) unsigned short shortRunStep;    // 跑步步数 / Running steps
@property(nonatomic) unsigned short shortDistance;   // 距离 单位：米 / Distance in meters
@property(nonatomic) unsigned short shortSleepSecond; // 睡眠时间 (手环返回的分钟数据中，不包括具体睡眠状态，具体请查看：checkSleepState方法) / Sleep duration in seconds (The data from the wristband is in minutes and does not include specific sleep states. For details, see the checkSleepState method)
@property(nonatomic) unsigned short shortSleepState; // 睡眠状态 0:默认 1:醒着 2:潜睡 3:深睡 / Sleep state: 0 - Default, 1 - Awake, 2 - Light Sleep, 3 - Deep Sleep， 4:mid
@property(nonatomic) float fCalories;                // 卡路里 / Calories burned
@property(nonatomic) float fSkinTemperature;          // 体表温度 / Skin temperature
@property(nonatomic) float fBodyTemperature;          // 身体体温 / Body temperature
@property(nonatomic) unsigned short shortHeartRate;   // 心率 / Heart rate
@property(nonatomic) BOOL bWear;                      // 是否穿戴 / Whether the device is worn
@property(nonatomic) ClingMinuteActType acttype;      // 运动类型 / Activity type
@property(nonatomic) short shortUv;                   // uv指数（uv手环有效 如果为cling leap手环，字段用于存放高压值） / UV index (valid for UV wristbands)
@property(nonatomic) int activityData;                // 计算睡眠时会使用该值 / Used in sleep calculation
@property(nonatomic) int iVoc;                        // voc指数 (voc手环有效 如果为cling leap手环，字段用于存放低压值) / VOC index (valid for VOC wristbands)
@property(nonatomic) int iAlcohol;                    // 酒精浓度 (voc手环有效) / Alcohol concentration (valid for VOC wristbands)

@property (nonatomic, assign) double fSweatSugar;     // 汗液糖分 / Sweat glucose level
@property (nonatomic, assign) double fLacticAcid;     // 乳酸值 / Lactic acid level
@property (nonatomic, assign) double fAtmPressure;    // 气压 / Atmospheric pressure

@property (nonatomic, assign) int spo2;               // 血氧 / Blood oxygen level (SpO2), max spo2 = 1000
@property (nonatomic, assign) float fspo2;            // 血氧 (float类型) / Blood oxygen level (float type) fspo2 = spo2 * 0.1
@property (nonatomic, assign) float sdnn;             // 心率变异性 (SDNN) / Heart rate variability (SDNN)
@property (nonatomic, assign) float stress;           // 压力值 / Stress level
@property (nonatomic, assign) float glucose;          // 血糖值 / Blood glucose level
@property (nonatomic, assign) int bp_low;             // 低压 / Diastolic blood pressure
@property (nonatomic, assign) int bp_high;            // 高压 / Systolic blood pressure


@end
//分钟数据详情  bubble模型
@interface ClingSportData : NSObject
@property(nonatomic)unsigned int intStartTime;      //开始时间戳 (Start timestamp)
@property(nonatomic)unsigned int intEndTime;      //结束时间戳 (End timestamp)
@property(nonatomic)ClingSportActType        acttype;       //运动类型 (Type of activity)
@property(nonatomic)int iWStep;           //走路步数.  如果acttype=ClingSportActTypeSleep, 存储深睡时长, (Walking steps. If acttype = ClingSportActTypeSleep, stores deep sleep duration)
@property(nonatomic)int iRStep;           //跑步步数 (Running steps)
@property(nonatomic)int iCalories;          //运动卡路里 (Calories burned during the activity)
@property(nonatomic)int iDistance;      //运动距离 (Distance covered during the activity)
@property(nonatomic)int iSleep;         //睡眠总时间 (Total sleep duration)
@property(nonatomic)float fSkinTemp;    //平均温度 (Average skin temperature)
@property(nonatomic)int iHRAvg;         //平均心跳 (Average heart rate)
@property(nonatomic,strong)NSString *sComment;      //运动描述 (Activity description)
@end
//每日数据 (Daily Data)
//下列字段中，有些字段可能已经不再使用，请根据具体返回的对象去查看具体情况 (Some of the fields below may no longer be in use. Please refer to the specific returned object to check the actual data.)
@interface ClingDailyData : NSObject
@property (nonatomic, assign) unsigned int daybeginTime;    // Start time of the day (timestamp)
@property (nonatomic, assign) int caloriesTotal;            // Total calories burned for the day
@property (nonatomic, assign) int distanceTotal;            // Total distance covered during the day
@property (nonatomic, assign) int heartRate;                // Average heart rate for the day
@property (nonatomic, assign) int rstepTotal;               // Total number of running steps
@property (nonatomic, assign) int sleepTotal;               // Total sleep seconds for the day
@property (nonatomic, assign) int wstepTotal;               // Total number of walking steps
@property (nonatomic, assign) int stepTotal;                // Total steps (walking + running)
@property (nonatomic, assign) double skinTemperature;       // Average skin temperature for the day
@property (nonatomic, assign) int wakeupTimes;              // Number of times the user woke up during the night (invalid)
@property (nonatomic, assign) double sleepEfficent;         // Sleep efficiency (percentage)
@property (nonatomic, assign) int caloriesSport;            // Calories burned from sports activities
@property (nonatomic, assign) int caloriesMetabolism;       // Calories burned from metabolism
@property (nonatomic, assign) int sportsTimeTotal;          // Total time spent on sports activities
@property(nonatomic)BOOL bWear;             //是否穿戴 值可能无效，请慎用 (Whether the wearable device is being worn (value may be invalid, use cautiously))
@property(nonatomic)int iVoc;             //voc指数  (voc手环有效) (VOC index (valid for VOC bracelet))
@property(nonatomic)int iAlcohol;             //酒精浓度  (voc手环有效) (Alcohol concentration (valid for VOC bracelet))
@property(nonatomic)int iBPTime;            //最后一次测量血压时间  cling leap有效 (Last blood pressure measurement time (valid for Cling Leap))
@property(nonatomic)int iMeasureCount;      //测量血压次数        cling leap 有效 (Number of blood pressure measurements taken (valid for Cling Leap))
@property(nonatomic)int iBPHigh;            //最后一次测量高  cling leap有效 (Last measured high blood pressure value (valid for Cling Leap))
@property(nonatomic)int iBPLow;      //最后一次测量低       cling leap 有效 (Last measured low blood pressure value (valid for Cling Leap))

@property(nonatomic)float glucose;   //血糖 (Blood glucose level)
@property(nonatomic)float weightkg;//体重数据 (Body weight in kilograms)
@property(nonatomic)float bodyfat;//体脂率数据 (Body fat percentage)
@property(nonatomic)int iWeightTime;//最后一次测量体重时间 (Last weight measurement time)
@property(nonatomic)int iWeightMeasureCount;//测量体重次数 (Number of weight measurements taken)

@property (nonatomic, assign) int sleepLight;   //浅睡时长  单位：秒 (Duration of light sleep (in seconds))
@property (nonatomic, assign) int sleepSound;   //深睡时长 (Duration of deep sleep)
@property (nonatomic, assign) int sleepRem;     //目前不使用 (Currently not in use)

@property (nonatomic, assign) short shortUv;    //最近uv值 (Latest UV index)
@property (nonatomic, assign) short shortActtype;   //无效值，可不关注 (Invalid value, can be ignored)

@property (nonatomic, assign) int rssi;     //无效值，可不关注 (Invalid value, can be ignored)

@property (nonatomic, assign) double        fSweatSugar;  // Sweat sugar level
@property (nonatomic, assign) double        fLacticAcid;  // Lactic acid level
@property (nonatomic, assign) double        fAtmPressure; // Atmospheric pressure

@property (nonatomic, assign) int   spo2;   // Blood oxygen saturation (SpO2)
@property (nonatomic, assign) float sdnn;   // Standard deviation of normal-to-normal intervals (Heart rate variability)
@property (nonatomic, assign) float stress; // Stress level

@end


@interface ClingHealthReportHRModel : NSObject
@property(nonatomic)int iRestHR;      //静息心率
@property(nonatomic)int iFitnessMinutes;     //热身运动分钟数
@property(nonatomic)int iBurnMinutes;     //脂肪燃烧分钟数
@property(nonatomic)int iStrengthenMinutes;       //心肺强化分钟数
@property(nonatomic)int iMuscleMinutes;           //肌力强化分钟数
@end

//用于判断用户体感舒适读
@interface ClingHealthReportTempModel : NSObject
@property (nonatomic, assign) int       iTempLess30;   //一天内体温小于30℃的时长(分钟)
@property (nonatomic, assign) int       iTemp30_31;  //一天内体温在30℃与31℃之间的时长(分钟)   包含30.不包含31，下同
@property (nonatomic, assign) int       iTemp31_32;  //一天内体温在31℃与32℃之间的时长(分钟)
@property (nonatomic, assign) int       iTemp32_34; //一天内体温在32℃与34℃之间的时长(分钟)
@property (nonatomic, assign) int       iTemp34_35; //一天内体温在34℃与35℃之间的时长(分钟)
@property (nonatomic, assign) int       iTempGreater35;   //一天内体温大于35摄氏度的时长
@end

//用户计算体温得分
@interface ClingHealthIndexTempModel : NSObject
@property(nonatomic)int iTempLess27;   //低于27度肤温分钟数
@property(nonatomic)int iTempLess28;     //[27,28)分钟数
@property(nonatomic)int iTempLess29;     //[28,29)分钟数
@property(nonatomic)int iTempLess30;     //[29,30)分钟数
@property(nonatomic)int iTempLess31;     //[30,31)分钟数
@property(nonatomic)int iTempLess34;     //[31,34)分钟数
@property(nonatomic)int iTempLess35;     //[34,35)分钟数
@property(nonatomic)int iTempLess36;     //[35,36)分钟数
@property(nonatomic)int iTempLess37;     //[36,37)分钟数
@property(nonatomic)int iTempLess38;     //[37,38)分钟数
@property(nonatomic)int iTempGreater38; //[38, )
@end

@interface ClingHealthReportModel : NSObject
@property (nonatomic, assign)unsigned int      iTimeStamp;     // 时间戳
@property (nonatomic, assign) int       iLevel;    // 健康挑战级别
@property (nonatomic, assign) int       iGender;   // 性别
@property (nonatomic, assign) int       iAge;      // 年龄
@property (nonatomic, assign) int       iIndex;    // 健康指数
@property (nonatomic, assign) int       iHeartIndex;    // 心率指数


@property (nonatomic, assign) int       iSportHRIndex;    // 运动心率指数
@property (nonatomic, assign) int       iRestHRIndex;     // 静息心率指数
@property (nonatomic, assign) int       iRestHRGoal;     // 静息心率目标
@property (nonatomic, assign) int       iFitHRIndex;     //运动热身心率指数
@property (nonatomic, assign) int       iFitHRGoal;     //运动热身心率目标
@property (nonatomic, assign) int       iBurnHRIndex;     //脂肪燃烧心率指数
@property (nonatomic, assign) int       iBurnHRGoal;     //脂肪燃烧心率目标
@property (nonatomic, assign) int       iStrengthenHRIndex;     //心肺强化心率指数
@property (nonatomic, assign) int       iStrengthHRGoal;     //心肺强化心率目标
@property (nonatomic, assign) int       iMuscleHRIndex;     //肌力强化心率指数
@property (nonatomic, assign) int       iMuscleHRGoal;     //肌力强化心率目标
@property (nonatomic,strong)ClingHealthReportHRModel *hrModel;

@property (nonatomic, assign) int       iTempIndex;     //体温指数
@property (nonatomic, assign) float     fAVGTemp;   //平均体温
@property (nonatomic,strong)ClingHealthReportTempModel *tempModel;
@property (nonatomic,strong)ClingHealthIndexTempModel *tempIndexModel;

@property (nonatomic, assign) int       iSleepIndex;    //睡眠指数
@property (nonatomic, assign) int       iSleepTime;      //睡眠时长
@property (nonatomic, assign) int       iSleepGoal;      //睡眠目标
@property (nonatomic, assign) int       iLightSleepTime;      //浅睡眠时长（秒）
@property (nonatomic, assign) int       iDeepSleepTime;      //深度睡眠时长（秒）

@property (nonatomic, assign) int       iStepIndex;     //步数指数
@property (nonatomic, assign) int       iStepNum;       //当日步数
@property (nonatomic, assign) int      iStepNumGoal;      //当日步数目标

@property (nonatomic, assign) int       iCalIndex;      //卡路里指数
@property (nonatomic, assign) int       iCalMetabolism;       //新陈代谢卡路里
@property (nonatomic, assign) long      iCalSport;       //运动消耗卡路里
@property (nonatomic, assign) long      iCalSportGoal;      //运动消耗卡路里目标
- (instancetype)initWithDic:(NSDictionary*)d;  //将服务器返回的字典转model
@end

//健康评估所选答案model  题目与答案排列顺序请与clingios一致
@interface ClingHealthEvalutionAnswerModel : NSObject
@property(nonatomic)int iQuestionIndex;  //问题索引号，起始为0
@property(nonatomic)int iAnswerIndex;      //答案索引号，起始为0
@property(nonatomic)int iAnswerTotal;       //当前题目对应的答案总数
@end



@interface ClingUtilsModel : NSObject
// 调用获取对应健康指数后，以下属性目标值会相应改变
// After calling the corresponding health index retrieval method, the following target values will be updated accordingly.

//目标值 Step goal
@property(nonatomic,readonly)int iStepGoal;
// Sleep goal
@property(nonatomic,readonly)int iSleepGoal;

//运动卡路里目标 Calorie goal for exercise
@property(nonatomic,readonly)int iCalorieGoal;
+ (ClingUtilsModel*)sharedInstance;


/*
 获取运动得分(Retrieves the exercise score.)
 
 healthLevel:
 0:入门级(Beginner)
 1:基础级(Basic)
 2:活跃级(Active)
 3:专业级(Professional)
 
 gender:
 性别(Gender)
 1:女(Female)
 0:男(Male)
 
 age:
 年龄(User's age.)
 
 steps:
 总步数(Total step count.)
 
 sleepMinutes:
 睡眠分钟数(Total sleep duration in minutes.)
 
 calsSport:
 运动卡路里(Calories burned during exercise.)
 
 restHr:
 静息心率:如有睡眠，静息心率为睡眠状态下心率；无睡眠，静息心率是未发生步数变化下的心率
 Resting heart rate: If sleep data is available, it refers to the heart rate during sleep; otherwise, it is the heart rate recorded when no steps are detected.
 
 
 */
- (float) getStepsPointWithLevel:(int) healthLevel gender:( int) gender age:(int) age steps:(float) steps;  //步数得分
- (float) getSleepPointWithLevel:(int) healthLevel gender:( int) gender age:(int) age sleepMinutes:(float) sleepMinutes;  //睡眠得分
- (float) getCalsPointWithLevel:(int) healthLevel gender:( int) gender age:(int) age cals:(float) calsSport;            //卡路里得分
- (float) getHeartratePointWithLevel:(int) healthLevel gender:( int) gender age:(int) age model:(ClingHealthReportHRModel*)model; //心率得分
- (float) getRestHeartratePointWithLevel:(int) healthLevel gender:( int) gender age:(int) age restHeartrate:(float) restHr;  //静息心率得分
- (float) getSportHeartratePointWithLevel:(int) healthLevel gender:(int) gender age:(int) age model:(ClingHealthReportHRModel*)model; //运动心率得分
- (float) getTempPointWithModel:(ClingHealthIndexTempModel*)model withHr:(ClingHealthReportHRModel*)hr;  //体温得分

/*
 总健康健康指数(Computes the overall health index.)
 
 lv:同上面healthLevel (lv Health level (same as above).)
 heartRate:心率得分 (heartRate Heart rate score.)
 temperature:体温得分，(temperature Body temperature score.)
 sleep:睡眠得分 (sleep Sleep score.)
 calories:卡路里得分 (calories Calorie score.)
 steps:步数得分 (steps Step score.)
 
 如某块功能不存在，则传入-1。比如：device体温不存在或者被关闭，则t=-1
 If a particular feature is unavailable, pass -1. For example, if the device does not support temperature measurement or it is disabled, set temperature = -1.
 
 */
//更改以后
//- (float)socreTotalLev:(int)lv heartRate:(float)hr temperature:(float)t sleep:(float)s calories:(float)c steps:(float)ss bloodPre:(float)bp;
//更改之前
- (float)socreTotalLev:(int)lv heartRate:(float)hr temperature:(float)t sleep:(float)s calories:(float)c steps:(float)ss;
//- (float)socreTotalLev:(int)healthLevel enableBits:(long)healthEnableBits heartRate:(float) hr temperature:(float) temp sleep:(float) sleep calories:(float) cal steps:(float) step;

//设置生成走路bubble与跑步bubble时间  如：连续走路10分钟生成走路bubble，则walk=10
//Sets the time threshold for generating walking and running bubbles.Example: If a continuous walk lasts for 10 minutes, a walking bubble is generated.
- (void)setGenerateTimelineWalkBubble:(int)walk runBubble:(int)run;

//根据分钟数据生成对应bubble  array:@[ClingMinuteData,...] (Generates corresponding bubbles based on minute-level data.)
//@return @[ClingSportData,...] (An array of ClingSportData objects.)
- (NSArray*)generateSportBubble:(NSArray*)array;


//合并前后两个bubble是同一个bubble的问题 array:@[ClingSportData,...] (Merges consecutive bubbles if they belong to the same activity.)
- (NSArray*)mergeBubble:(NSArray*)array;

/*
 @brief generate daily total data from minute data array
 @param array minute data array {@link ClingMinuteData}, from last day 12:00 to 23:59, for sleep total data usage.
    this array should be sorted by minute data iTimestamp variable, ascending.
*/
- (ClingDailyData *) calculateDayTotalData:(NSArray *) array daybegingtime:(NSTimeInterval) daybegin;

/*
 
 计算健康评估分值(Computes the health evaluation score.)
 
 pageSelection：所选答案集合  @[ClingHealthEvalutionAnswerModel,...] (pageSelection An array of selected answers. @[ClingHealthEvalutionAnswerModel,...])
 gender: User's gender.
 @return The computed health evaluation score.
 
 */
- (int)calculateHealthEvalutionScore:(NSArray*)pageSelection  gender:(int)gender;


/*
 
 运动目标值(Computes daily activity goals.)
 
 healthLevel:
 0:入门级 (Beginner)
 1:基础级 (Basic)
 2:活跃级 (Active)
 3:专业级 (Professional)
 
 gender:
 性别 (Gender)
 1:女 (Female)
 0:男 (Male)
 
 age:
 年龄 (User's age)
 
 type:
 0:步数目标 (Step goal)
 1:睡眠目标 (Sleep goal)
 2:卡路里目标 (Calorie goal)
 3:静息心率目标 (Resting heart rate goal)
 @return The computed daily goal.

 */

- (float)getDayGoal:(int)healthLevel gender:(int)gender age:(int)age type:(int)type;

//获得睡眠bubble生成间隔时间 (Retrieves the sleep bubble generation interval time.)
+ (int)getSleepInterval;
//获得活动bubble生成间隔时间 (Retrieves the activity bubble generation interval time.)
+ (int)getActivityInterval;
//获得默认生成bubble间隔时间 (Retrieves the default bubble generation interval time.)
+ (int)getNormalInterval;

/**
 * @brief 根据整天的分钟数据，识别睡眠状态  整天: 12：00--11：59为一天 (Identifies sleep states based on minute-level data.)
 * @param minuteDatas 一天分钟数据.  如不到一天，则为12：00到当前时间,比如：下午时，给入分钟数据为中午12：00到下午具体时间
 * Minute-level data for an entire day (12:00 PM to 11:59 AM of the next day), If the data is incomplete, it covers 12:00 PM to the current time.
 *
 * @param isHR 当前设备是否支持心率监测 (Indicates whether the current device supports heart rate monitoring.)
 *
 * tips: ClingMinuteData对象中intTimestamp|shortWalkStep|shortRunStep|shortDistance|shortHeartRate|activityData可能用于睡眠状态计算，请保持上述属性值有效
 *   调用完毕后，minuteDatas中睡眠状态为有效值。
 *   未调用此方法，非企业版分钟数据将不会在服务器保存
 *
 * @note The following properties in ClingMinuteData objects may be used for sleep state calculation:
 *       intTimestamp, shortWalkStep, shortRunStep, shortDistance, shortHeartRate, and activityData.
 *       Ensure these values are valid.
 *       If this method is not called, non-enterprise version minute data will not be saved on the server.
 */
+ (void)checkSleepState:(NSArray <ClingMinuteData *> * )minuteDatas isHR:(BOOL)bHr;
@end


