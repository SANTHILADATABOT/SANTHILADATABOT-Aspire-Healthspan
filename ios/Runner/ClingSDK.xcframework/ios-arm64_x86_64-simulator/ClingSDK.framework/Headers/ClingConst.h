//
//  ClingConst.h
//  ClingSDK
//
//  Created by Roffa Zhou on 15/10/27.
//  Copyright © 2015年 Roffa. All rights reserved.
//

#ifndef ClingConst_h
#define ClingConst_h



/*
 
 分页请求时，每页size
 
 */
#define ClingPageSize       @"15"


/*
 
 开启设备推送后，cling会通过振动来提醒用户
 
 IOS 10及以上
 其他逻辑不变
 下发“新闻”开关的时候需注意：（“社交” "电子邮件" “新闻” 三个类别都捆绑到“新闻”中）
   1> 当“社交” “电子邮件” “新闻” 三个开关同时关闭的情况下才关闭“新闻” 开关
   2> “社交” “电子邮件” “新闻” 三个开关，只要有一个是打开的，不管用户有没有打开“新闻”开关，默认下发“开”的命令。
 */
//typedef NS_ENUM(NSInteger, CLING_WATCH_NOTIFICATION) {
typedef NS_OPTIONS(NSInteger, CLING_WATCH_NOTIFICATION) {
    CLING_WATCH_NOTIFICATION_CLOSE_ALL = 0,
    CLING_WATCH_NOTIFICATION_ID_INCOMING_CALL = 1 << 0,      //来电 (Incoming call)
    CLING_WATCH_NOTIFICATION_ID_MISSED_CALL  = 1 << 1,            //未接来电 (Missed call)
    CLING_WATCH_NOTIFICATION_ID_VOICE_MAIL = 1 << 2,             //语音邮件 (Voicemail)
    CLING_WATCH_NOTIFICATION_ID_SOCIAL = 1 << 3,                 //社交 (Social)
    CLING_WATCH_NOTIFICATION_ID_SCHEDULE = 1 << 4,               //日程 (Schedule)
    CLING_WATCH_NOTIFICATION_ID_EMAIL = 1 << 5,                  //电子邮件 (Email)
    CLING_WATCH_NOTIFICATION_ID_NEWS = 1 << 6,                   //新闻 (News)
    CLING_WATCH_NOTIFICATION_ID_HEALTH_FITNESS = 1 << 7,         //健身健康 (Health & Fitness)
    CLING_WATCH_NOTIFICATION_ID_BUSINESS_FINANCE = 1 << 8,       //商务金融 (Business & Finance)
    CLING_WATCH_NOTIFICATION_ID_LOCATION = 1 << 9,               //位置 (Location)
    CLING_WATCH_NOTIFICATION_ID_ENTERTAINMENT = 1 << 10,          //娱乐 (Entertainment)
};
typedef NS_ENUM(NSInteger, ClingDeviceStyle) {
    ClingDeviceStyleWatch = 0,   //cling watch
    ClingDeviceStyleBand,    //cling band contain uv
    ClingDeviceStyleBandNFC,  //cling band contain nfc
    ClingDeviceStyleBand2NFC,       // Cling 杉德手环
    ClingDeviceStyleBandVoc,        //Cling VOC
    ClingDeviceStylePace,           // Cling Pace
    ClingDeviceStyleBandRiver,      //雨花石
    ClingDeviceStyleTrink,          //长命锁
    ClingDeviceStyleGoG,            //Cling Go GPS 后改名为Cling Leap
    ClingDeviceStyleGoP,            //Cling Go PAY
    ClingDeviceStyleThree,          //Clingband 3 Aura
    ClingDeviceStyleHRM,            //Cling HRM
    ClingDeviceStyleIphone,  //pedometer
    ClingDeviceStyleHela,
    ClingDeviceStyleThermo,
    ClingDeviceStyleSkinThermo,
    ClingDeviceStyleEteTh07,
    ClingDeviceStyleEteTs07,
    ClingDeviceStylePeak,
    ClingDeviceStyleTron,
    ClingDeviceStyleMHEAT,          //MHEAT和AURA一样
    ClingDeviceStyleTRnb,          //Tron NB
    ClingDeviceStyleGE,      //Tron lite
    ClingDeviceStyleDeviceAll,    //search all cling device
    ClingDeviceStyleNone          ////移除设备后，使恢复初始化
};
typedef NS_ENUM(NSInteger, ClingDeviceLanguage) {
    ClingDeviceLanguageEnglish,          //English
    ClingDeviceLanguageSimplified,      //简体中文
    ClingDeviceLanguageTraditional,         //繁体中文
};
typedef NS_ENUM(NSInteger, ClingDeviceWeatherStyle) {
    ClingDeviceWeatherStyleSunny=0, //天气情况
    ClingDeviceWeatherStyleCloudy,  //天气情况
    ClingDeviceWeatherStyleRainy,   //天气情况
    ClingDeviceWeatherStyleSnowy,   //天气情况
};

/*!
 *  @enum CBCentralManagerState
 *
 *  @discussion Represents the current state of a CBCentralManager.
 *
 *  @constant CBCentralManagerStateUnknown       State unknown, update imminent.
 *  @constant CBCentralManagerStateResetting     The connection with the system service was momentarily lost, update imminent.
 *  @constant CBCentralManagerStateUnsupported   The platform doesn't support the Bluetooth Low Energy Central/Client role.
 *  @constant CBCentralManagerStateUnauthorized  The application is not authorized to use the Bluetooth Low Energy Central/Client role.
 *  @constant CBCentralManagerStatePoweredOff    Bluetooth is currently powered off.
 *  @constant CBCentralManagerStatePoweredOn     Bluetooth is currently powered on and available to use.
 *
 */
typedef NS_ENUM(NSInteger, ClingBLEState) {
    ClingBLEStateUnknown = 0,  //蓝牙状态
    ClingBLEStateResetting,    //蓝牙状态
    ClingBLEStateUnsupported,  //蓝牙状态
    ClingBLEStateUnauthorized, //蓝牙状态
    ClingBLEStatePoweredOff,   //蓝牙状态
    ClingBLEStatePoweredOn,    //蓝牙状态
};
//device手环包含的type
typedef NS_ENUM(NSInteger, ClingMinuteActType) {
    ClingMinuteActTypeNone = 0,
    ClingMinuteActTypeWalk,
    ClingMinuteActTypeRun,
    ClingMinuteActTypeCycling,
    ClingMinuteActTypeElliptical,
    ClingMinuteActTypeStairs,
    ClingMinuteActTypeAerobic,
    ClingMinuteActTypeRowing,
    ClingMinuteActTypePiloxing,
    ClingMinuteActTypeMisc,
    ClingMinuteActTypeRoadCycling,
    
    ClingMinuteActTypeTronRun, //11
    ClingMinuteActTypeTronWalk,
    ClingMinuteActTypeTronMountainClimb,
    ClingMinuteActTypeTronTrackRun,     //运动场跑步
    ClingMinuteActTypeTronTrailRun,     //越野跑 15
    ClingMinuteActTypeTronBike,
    ClingMinuteActTypeTronMountainBike,
    ClingMinuteActTypeTronHorseRide,    //18
    ClingMinuteActTypeTronSailing,
    ClingMinuteActTypeTronBoatRowing, //20
    ClingMinuteActTypeTronSki,
    ClingMinuteActTypeTronSnowBoard,
    ClingMinuteActTypeTronIndoorRun,
    ClingMinuteActTypeTronElliptical, //24
    ClingMinuteActTypeTronAerobic,
    ClingMinuteActTypeTronSwim,
    ClingMinuteActTypeTronOthers,     //27
    
    ClingMinuteActTypeTRnbRun,      //28
    ClingMinuteActTypeTRnbWalk,
    ClingMinuteActTypeTRnbMountainClimb,
    ClingMinuteActTypeTRnbTrackRun,     //运动场跑步
    ClingMinuteActTypeTRnbTrailRun,     //越野跑
    ClingMinuteActTypeTRnbBike,
    ClingMinuteActTypeTRnbMountainBike,
    ClingMinuteActTypeTRnbHorseRide,  //35
    ClingMinuteActTypeTRnbSailing,
    ClingMinuteActTypeTRnbBoatRowing,
    ClingMinuteActTypeTRnbSki,
    ClingMinuteActTypeTRnbSnowBoard,
    ClingMinuteActTypeTRnbIndoorRun,  //40
    ClingMinuteActTypeTRnbElliptical,
    ClingMinuteActTypeTRnbAerobic,
    ClingMinuteActTypeTRnbSwim,
    ClingMinuteActTypeTRnbOthers,     //44
    
    ClingMinuteActTypeGERun, //45
    ClingMinuteActTypeGEWalk,
    ClingMinuteActTypeGEMountainClimb,
    ClingMinuteActTypeGETrackRun,     //运动场跑步
    ClingMinuteActTypeGETrailRun,     //越野跑 49
    ClingMinuteActTypeGEBike,
    ClingMinuteActTypeGEMountainBike,
    ClingMinuteActTypeGEHorseRide,    //52
    ClingMinuteActTypeGESailing,
    ClingMinuteActTypeGEBoatRowing, //54
    ClingMinuteActTypeGESki,
    ClingMinuteActTypeGESnowBoard,
    ClingMinuteActTypeGEIndoorRun,
    ClingMinuteActTypeGEElliptical, //58
    ClingMinuteActTypeGEAerobic,
    ClingMinuteActTypeGESwim,
    ClingMinuteActTypeGEOthers,     //61
    
    ClingMinuteActTypeMax
};
typedef NS_ENUM(NSInteger, ClingSportActType) {
    
    ClingSportActTypeSleep,     //睡眠, (Sleep)
    ClingSportActTypeWalk,     //步行, (Walking)
    ClingSportActTypeRemind = 3,  //提醒, (Reminder)
    ClingSportActTypeMap = 4,     //地图, (Map)
    ClingSportActTypeRun,         //跑步, (Running)
    
    
    /**
     *用户手动设置的运动模式
     *以下属性增加或者减少时,请在上面ClingMinuteActType中相应增减，并且保存位置一致
     
     */
    ClingSportActTypeManualWalk = 6,      //跑步机, (Treadmill (manual walking mode))
    ClingSportActTypeManualRun,       //跑步, (Treadmill (manual running mode))
    ClingSportActTypeCycling,   //单车, (Cycling)
    ClingSportActTypeElliptical,    //椭圆机, (Elliptical machine)
    ClingSportActTypeStairs,        //爬楼梯, (Stair climbing)
    ClingSportActTypeAerobic,       //有氧操, (Aerobics)
    ClingSportActTypeRowing,        //划船, (Rowing)
    ClingSportActTypePiloxing,      //搏击健身舞, (Piloxing (boxing + Pilates))
    ClingSportActTypeMisc,          //其他, (Other activities)
    
   /*分割线*/
    
    ClingSportActTypeQuiet,         //安静bubble  完全没有步数超过5分钟, (Quiet bubble (No steps for over 5 minutes))
    ClingSportActTypeActive,        //活动    连续出现步数超过3分钟, (Active (Steps detected for over 3 minutes))
    ClingSportActTypeRoadCycling,   //device骑行, (Device-based cycling)
    ClingSportActTypeNoHeart = 18,       //未佩戴 18, (Not wearing the heart rate monitor (code 18))
    
    //leap bubble 类型
    ClingSportActTypeleap_manual_action_walk,   // (Manual action walking (Leap))
    ClingSportActTypeleap_manual_action_run,    // Manual action running (Leap)
    ClingSportActTypeleap_manual_action_cycling, // Manual action cycling (Leap)
    ClingSportActTypeleap_manual_action_elliptical, //Manual action elliptical (Leap)
    ClingSportActTypeleap_manual_action_stairs, // Manual action stair climbing (Leap)
    ClingSportActTypeleap_manual_action_aerobic,    // Manual action aerobics (Leap)
    ClingSportActTypeleap_manual_action_rowing, // Manual action rowing (Leap)
    ClingSportActTypeleap_manual_action_piloxing,   // Manual action piloxing (Leap)
    ClingSportActTypeleap_manual_action_misc,   // Manual action other (Leap)
    ClingSportActTypeleap_manual_outdoor_cycling = 28,  // Manual action outdoor cycling (Leap)
    
    //peak tron 类型
    ClingSportActTypeTronRun, //29  (Tron Running (Peak))
    ClingSportActTypeTronWalk,  //  (Tron Walking (Peak))
    ClingSportActTypeTronMountainClimb, //(Tron Mountain Climbing (Peak))
    ClingSportActTypeTronTrackRun,     //运动场跑步 (Track Running (Peak))
    ClingSportActTypeTronTrailRun,     //越野跑 (Trail Running (Peak))
    ClingSportActTypeTronBike,         // Tron Cycling (Peak)
    ClingSportActTypeTronMountainBike, // Tron Mountain Biking (Peak)
    ClingSportActTypeTronHorseRide,    // Tron Horse Riding (Peak)
    ClingSportActTypeTronSailing,      // Tron Sailing (Peak)
    ClingSportActTypeTronBoatRowing,   // Tron Boat Rowing (Peak)
    ClingSportActTypeTronSki,          // Tron Skiing (Peak)
    ClingSportActTypeTronSnowBoard,    // Tron Snowboarding (Peak)
    ClingSportActTypeTronIndoorRun,    // Tron Indoor Running (Peak)
    ClingSportActTypeTronElliptical,   // Tron Elliptical (Peak)
    ClingSportActTypeTronAerobic,      // Tron Aerobics (Peak)
    ClingSportActTypeTronSwim,         // Tron Swimming (Peak)
    ClingSportActTypeTronOthers,       // Tron Other Activities (Peak)
    //N1
    ClingSportActTypeTRnbRun,  //46    // Running (TRnb)
    ClingSportActTypeTRnbWalk,         // Walking (TRnb)
    ClingSportActTypeTRnbMountainClimb,// Mountain Climbing (TRnb)
    ClingSportActTypeTRnbTrackRun,     // 运动场跑步 (Track Running (TRnb))
    ClingSportActTypeTRnbTrailRun,     // 越野跑 (Trail Running (TRnb))
    ClingSportActTypeTRnbBike,         // Cycling (TRnb)
    ClingSportActTypeTRnbMountainBike, // Mountain Biking (TRnb)
    ClingSportActTypeTRnbHorseRide,    // Horse Riding (TRnb)
    ClingSportActTypeTRnbSailing,      // Sailing (TRnb)
    ClingSportActTypeTRnbBoatRowing,   // Boat Rowing (TRnb)
    ClingSportActTypeTRnbSki,          // Skiing (TRnb)
    ClingSportActTypeTRnbSnowBoard,    // Snowboarding (TRnb)
    ClingSportActTypeTRnbIndoorRun,    // Indoor Running (TRnb)
    ClingSportActTypeTRnbElliptical,   // Elliptical (TRnb)
    ClingSportActTypeTRnbAerobic,      // Aerobics (TRnb)
    ClingSportActTypeTRnbSwim,         // Swimming (TRnb)
    ClingSportActTypeTRnbOthers,       // Other Activities (TRnb)
    
    //tron lite 类型
    ClingSportActTypeGERun, //63        Tron Lite Running (GE)
    ClingSportActTypeGEWalk,            // Tron Lite Walking (GE)
    ClingSportActTypeGEMountainClimb,   // Tron Lite Mountain Climbing (GE)
    ClingSportActTypeGETrackRun,     //运动场跑步 (Tron Lite Track Running (GE))
    ClingSportActTypeGETrailRun,     //越野跑 (Tron Lite Trail Running (GE))
    ClingSportActTypeGEBike,         // Tron Lite Cycling (GE)
    ClingSportActTypeGEMountainBike, // Tron Lite Mountain Biking (GE)
    ClingSportActTypeGEHorseRide,    // Tron Lite Horse Riding (GE)
    ClingSportActTypeGESailing,      // Tron Lite Sailing (GE)
    ClingSportActTypeGEBoatRowing,   // Tron Lite Boat Rowing (GE)
    ClingSportActTypeGESki,          // Tron Lite Skiing (GE)
    ClingSportActTypeGESnowBoard,    // Tron Lite Snowboarding (GE)
    ClingSportActTypeGEIndoorRun,    // Tron Lite Indoor Running (GE)
    ClingSportActTypeGEElliptical,   // Tron Lite Elliptical (GE)
    ClingSportActTypeGEAerobic,      // Tron Lite Aerobics (GE)
    ClingSportActTypeGESwim,         // Tron Lite Swimming (GE)
    ClingSportActTypeGEOthers,       // Tron Lite Other Activities (GE)
};

//device手环包含的type
typedef NS_ENUM(NSInteger, ClingUpdateFileResult) {
    ClingUpdateFileResultSucc = 0,          //成功
    ClingUpdateFileResultErrorConnect,      //连接错误
    ClingUpdateFileResultErrorCRC,          //文件校验失败
    ClingUpdateFileResultErrorBusy,         //设备忙
    ClingUpdateFileResultErrorFile,         //文件异常
    ClingUpdateFileResultErrorLength,       //文件长度错误
    ClingUpdateFileResultErrorBin,          //bin文件出错
    ClingUpdateFileResultErrorMemory,       //设备内存不足
    ClingUpdateFileResultErrorOther
};

typedef NS_ENUM(NSInteger, CLING_DEVICE_REMINDER_WEEKDAY) {
    CLING_DEVICE_REMINDER_WEEKDAY_MONDAY = 1,           //周一 Monday
    CLING_DEVICE_REMINDER_WEEKDAY_TUESDAY = 1 << 1,     //周二 Tuesday
    CLING_DEVICE_REMINDER_WEEKDAY_WEDNESDAY  = 1 << 2,  //周三 Wednesday
    CLING_DEVICE_REMINDER_WEEKDAY_THURSDAY  = 1 << 3,   //周四 Thursday
    CLING_DEVICE_REMINDER_WEEKDAY_FRIDAY  = 1 << 4,     //周五 Friday
    CLING_DEVICE_REMINDER_WEEKDAY_SATURDAY  = 1 << 5,   //周六 Saturday
    CLING_DEVICE_REMINDER_WEEKDAY_SUNDAY  = 1 << 6,     //周日 Sunday
    CLING_DEVICE_REMINDER_WEEKDAY_ALL  = 0x7f,          //全部 All days
};

typedef NS_ENUM(NSUInteger, HEALTH_INDEX_CALCULATION_BIT) {  //当前已选中的显示块
    HEALTH_INDEX_CALCULATION_BIT_STEP = 1,           //步数
    HEALTH_INDEX_CALCULATION_BIT_CALORIES = 1 << 1,  //热量
    HEALTH_INDEX_CALCULATION_BIT_SLEEP  = 1 << 2,    //睡眠
    HEALTH_INDEX_CALCULATION_BIT_HR  = 1 << 3,       //平均心率
    HEALTH_INDEX_CALCULATION_BIT_SKINTEMP  = 1 << 4, //体温
    HEALTH_INDEX_CALCULATION_BIT_DISTANCE  = 1 << 5, //里程
    HEALTH_INDEX_CALCULATION_BIT_UV  = 1 << 6,    //uv手环显示
    HEALTH_INDEX_CALCULATION_BIT_VOC = 1 << 7,      //voc手环显示
    HEALTH_INDEX_CALCULATION_BIT_TRACK  = 1 << 8,   //轨迹
    HEALTH_INDEX_CALCULATION_BIT_ME = 1 << 9,       //我的主页
    HEALTH_INDEX_CALCULATION_BIT_BP = 1 << 10,      //血压
    HEALTH_INDEX_CALCULATION_BIT_BF = 1 << 11,      //体脂称
    HEALTH_INDEX_CALCULATION_BIT_BS_SS = 1 << 12,       // 汗糖/血糖
    HEALTH_INDEX_CALCULATION_BIT_LACTIC_ACID = 1 << 13, // 乳酸
    HEALTH_INDEX_CALCULATION_BIT_GENE = 1 << 14,
    HEALTH_INDEX_CALCULATION_BIT_BO = 1 << 15,      //血氧
    HEALTH_INDEX_CALCULATION_BIT_HRV = 1 << 16,      //hrv压力
    HEALTH_INDEX_CALCULATION_BIT_GLUCOSE = 1 << 17,      //血糖
    HEALTH_INDEX_CALCULATION_BIT_ALL = 0xffff,       //全部
};


#define ClingErrorCode @"status_code"



#endif /* ClingConst_h */
