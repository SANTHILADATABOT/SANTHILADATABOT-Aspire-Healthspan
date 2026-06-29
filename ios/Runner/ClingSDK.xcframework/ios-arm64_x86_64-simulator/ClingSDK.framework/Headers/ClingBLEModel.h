//
//  ClingBLEModel.h
//  ClingSDK
//
//  Created by Roffa Zhou on 15/4/8.
//  Copyright (c) 2015年 Roffa. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ClingConst.h"

@protocol ClingDeviceMinuteDataSyncDelegate
@optional
- (void) minuteDataUpdate:(id) minData;
@end

@protocol ClingDeviceHelaTestDelegate
@optional
- (void) testDataUpdate:(id) testData;
@end

@interface ClingHelaTestData : NSObject
@property (nonatomic) NSArray * arrayValue;
@property (nonatomic) NSTimeInterval timestamp;
@end


@interface ClingDeviceDiscoveryModel : NSObject
@property(nonatomic, strong) CBPeripheral * peripheral;   //翻转手腕
@property(nonatomic, assign) BOOL isRegistered;   //翻转手腕
@end

//设备设置
@interface ClingDeviceCfg : NSObject
//点亮屏幕设置(Light up screen settings)
@property(nonatomic)BOOL bFlipWrist;   //翻转手腕   (Flip wrist)
@property(nonatomic)BOOL bTouchEnable;  //触摸屏开关 (Touch screen enable switch)
@property(assign, nonatomic) BOOL bBloodP;//血压开关,每天8:00 AM, 2:00 PM, 8:00 PM (Auto Blood Pressure Monitor switch)
@property(assign, nonatomic) BOOL bBloodO;//血氧开关,每天7:00 AM, 1:00 PM, 7:00 PM (Auto SpO2 Monitor switch)
@property(nonatomic)BOOL bHold;         //点击并按住屏幕 (Press and hold screen)
@property(nonatomic)BOOL bTap;          //轻拍屏幕 (Tap screen)
@property(nonatomic)UInt8 uint8Hold;    //按住屏幕时长  有效值：1、3  单位：秒  default:1 (Hold screen duration, valid values: 1, 3, unit: seconds, default: 1)
//关闭屏幕设置(Turn off screen settings)
@property(nonatomic)UInt8 uint8ScreenOff;       //关闭时间 有效值：[2,15]  单位：秒  default:5 (Screen off time, valid values: [2,15], unit: seconds, default: 5)
@property(nonatomic)UInt8 uint8HROff;           //心率监测关闭时间 有效值：[15,60] 单位：秒  default:25 (Heart rate monitoring off time, valid values: [15,60], unit: seconds, default: 25)
//心率监测周期(Heart rate monitoring cycle)
@property(nonatomic)UInt8 uint8HRDay;           //测量间隔(白天)   有效值：[0,120] 单位：分  default:15  ClingLeap有效值可以设置为0,其他是[5,120] (Measurement interval (daytime), valid values: [0,120], unit: minutes, default: 15; ClingLeap valid values: 0, others: [5,120])
@property(nonatomic)UInt8 uint8HRNight;           //测量间隔(夜间)  有效值：[5,120] 单位：分  default:30 (Measurement interval (nighttime), valid values: [5,120], unit: minutes, default: 30)
//体感温度监测周期(Body temperature monitoring cycle)
@property(nonatomic)UInt8 uint8TempDay;           //测量间隔(白天)   有效值：[5,120] 单位：分  default:15 (Measurement interval (daytime), valid values: [5,120], unit: minutes, default: 15)
@property(nonatomic)UInt8 uint8TempNight;           //测量间隔(夜间)  有效值：[5,120] 单位：分  default:30 (Measurement interval (nighttime), valid values: [5,120], unit: minutes, default: 30)
//久坐提醒(Sedentary reminder)
@property(nonatomic)BOOL bIdleAlert;          //是否打开久坐提醒 (Enable idle alert)
@property(nonatomic)UInt8 uint8IdleAlert;       //提醒时间间隔   有效值：[30,150] 单位：分   default:30 (Idle alert interval, valid values: [30,150], unit: minutes, default: 30)
@property(nonatomic)int intIdleHourStart;       //一天中起始小时 (Start hour of the day)
@property(nonatomic)int intIdleHourEnd;       //一天中终止小时 (End hour of the day)

@property(nonatomic)UInt8 uint8SleepSensitivity;        //睡眠灵敏度  0:低   1:中  2:高 (Sleep sensitivity, 0: low, 1: medium, 2: high)
@property(nonatomic)BOOL bWeekendAlarmDisabled;     //周末提醒是否有效 (Whether weekend alarms are enabled)
@property(nonatomic)int intStepSensitivity;         //计步灵敏度   2:低   1:中  0:高 (Step sensitivity, 2: low, 1: medium, 0: high)
@property(nonatomic)int intVocSampleRate;         //voc sample rate 2:低   1:中  0:高  voc手环设置采样率使用 (VOC sample rate, 2: low, 1: medium, 0: high, used for VOC wristband sampling rate setting)
@property(nonatomic)int intAlcoholSensitivity;    // alcohol sensitivity 酒精监测灵敏度 2:低   1:中  0:高 (Alcohol monitoring sensitivity, 2: low, 1: medium, 0: high)
@property(nonatomic,copy)NSString* strCityName;          //天气使用的城市名 (City name used for weather)
@property(nonatomic)int iHrbroadcast;       //心率广播是否开启   0：关闭  1：开启 (Heart rate broadcast enabled: 0: off, 1: on)
@property(nonatomic)int iTimeOut;           //报警超时   有效值：[30,2400] 单位：s  default:30 (Alarm timeout, valid values: [30,2400], unit: seconds, default: 30)


@end
//设备提醒
@interface ClingDeviceReminder : NSObject
@property(nonatomic)int intReminderHour;        //小时
@property(nonatomic)int intReminderMinute;      //分钟
@property(nonatomic,strong)NSString *strName;   //提醒名
@property(nonatomic)int iOpen;                 //是否打开闹钟  <-1为关闭闹钟，其他为打开闹钟
@property(nonatomic) CLING_DEVICE_REMINDER_WEEKDAY weekday;           //周几提醒，default is CLING_DEVICE_REMINDER_WEEKDAY_ALL
- (NSComparisonResult)compareReminders:(ClingDeviceReminder *)reminder;  //根据时分比较闹钟
@end

//服药提醒
@interface ClingPillReminder : NSObject
@property(nonatomic)int iReminderId;            //提醒id [1,65535] (Reminder ID, range [1, 65535])
@property(nonatomic)int iReminderHour;        //小时      [0,23] (Hour, range [0, 23])
@property(nonatomic)int iReminderMinute;      //分钟      [0,59] (Minute, range [0, 59])
@property(nonatomic,strong)NSString *strName;   //提醒名  可选 长度不超过128,目前暂不支持此属性配置 (Reminder name, optional, max length 128, currently this property is not supported for configuration)
@property(nonatomic) CLING_DEVICE_REMINDER_WEEKDAY weekday;           //周几提醒，default is CLING_DEVICE_REMINDER_WEEKDAY_ALL (Weekday for the reminder)
@end

//天气
@interface ClingDeviceWeather : NSObject
@property(nonatomic)int intWeatherTime;        //天气时间戳 (Weather timestamp)
@property(nonatomic)ClingDeviceWeatherStyle style;   //天气 (Weather style)
@property(nonatomic)float fTempLow;             //最低温度 (Lowest temperature)
@property(nonatomic)float fTempHigh;            //最高温度 (Highest temperature)
@property(nonatomic)short aqi;                  // aqi空气质量 (AQI - Air Quality Index)
@end


/*向device发送此设置时，所有属性都需要赋值后再发送*/
@interface ClingPeripheralUserProfileModel : NSObject

#define PERIPHERAL_PROFILE_CLOCK_ORIENTATION_VERTICAL                   0       //垂直显示 Vertical display
#define PERIPHERAL_PROFILE_CLOCK_ORIENTATION_HORIZONTAL                 1       //水平显示 Horizontal display

#define PERIPHERAL_PROFILE_TOUCH_VIRBRATION_OFF                         0       //触屏震动关闭 Touchscreen vibration off
#define PERIPHERAL_PROFILE_TOUCH_VIRBRATION_ON                          1       //触屏震动打开 Touchscreen vibration on

/*以下显示设置，设备包含相应功能设置有效*/
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_STEP                   0x0001      //屏幕显示步数模块 Display step module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_DISTANCE               0x0002      //屏幕显示距离模块 Display distance module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_CALORIES               0x0004      //屏幕显示卡路里模块 Display calories module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_ACTIVE_TIME            0x0008      //屏幕显示运动时间模块 Display active time module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_HEART_RATE             0x0010      //屏幕显示心率模块 Display heart rate module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_WEATHER                0x0020      //屏幕显示天气模块 Display weather module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_PM2P5                  0x0040      //屏幕显示空气质量模块 Display air quality module

#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_START_RUNNING          0x0100      //屏幕显示开始运动模块 Display start running module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_ANALYSIS               0x0200      //屏幕显示运动分析模块 Display analysis module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_SKIN_TEMP              0x0400      //屏幕显示肤温模块 Display skin temperature module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_UV                     0x0800      //屏幕显示uv模块 Display UV module
#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_BLOODPRESSURE          0x1000      //屏幕显示blood pressure模块 Display blood pressure module

#define PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_DEFAULT_VALUE           ( PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_STEP | PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_HEART_RATE | PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_START_RUNNING | PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_SKIN_TEMP | PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION_UV )  // 0xD11  屏幕默认显示模块 Default screen display modules


#define PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_DISTANCE             0x01        //训练页显示距离 Display distance in training page
#define PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_TIME                 0x02        //训练页显示总耗时 Display total time in training page
#define PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_PACE                 0x04        //训练页显示平均配速 Display average pace in training page
#define PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_STRIDE               0x08        //训练页显示平均步长 Display average stride in training page
#define PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_CADENCE              0x10        //训练页显示平均步频 Display average cadence in training page
#define PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_HEART_RATE           0x20        //训练页显示平均心率 Display average heart rate in training page
#define PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_CALORIES             0x40        //训练页显示热量消耗 Display calories burned in training page

#define PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_DEFAULT_VALUE        0x77        //训练页默认配置 Default configuration for training page

#define PERIPHERAL_PROFILE_HEART_ALARM_ENABLE                           0x80        //心率区间震动是否开启(Whether heart rate alarm is enabled) 打开(Whether heart rate alarm is enabled)：hr_alarm_rate |= PERIPHERAL_PROFILE_HEART_ALARM_ENABLE;  关闭(Disable)：hr_alarm_rate &= ~PERIPHERAL_PROFILE_HEART_ALARM_ENABLE;
#define PERIPHERAL_PROFILE_HEART_ALARM_DEFAULT_VALUE                   PERIPHERAL_PROFILE_HEART_ALARM_ENABLE | 0x4B

#define PERIPHERAL_PROFILE_PACE_ALARM_ENABLE                            0x80 //配速区间震动是否开启 打开(Whether pace alarm is enabled. Enable)：pace_alarm_zone |= PERIPHERAL_PROFILE_HEART_ALARM_ENABLE;  关闭(Disable)：pace_alarm_zone &= ~PERIPHERAL_PROFILE_HEART_ALARM_ENABLE;
#define PERIPHERAL_PROFILE_PACE_ALARM_DEFAULT_VALUE                     ( PERIPHERAL_PROFILE_PACE_ALARM_ENABLE | 0x03 )

#define CALORIES_DISPLAY_TYPE_ALL                                       0       //所有卡里路，新陈代谢+运动 Total calories, metabolism + exercise
#define CALORIES_DISPLAY_TYPE_ACTIVE                                    1       //运动卡路里 Exercise calories
//#define CALORIES_DISPLAY_TYPE_METABOLISM                                2


#define DEVICE_UNIT_TYPE_METRIC_ENGLIGH                                 0x1 // 0: international, 1: english
#define DEVICE_UNIT_TYPE_TEMPERATURE                                    0x2 // 0: cel   1: Fara
#define DEVICE_UNIT_TYPE_TIME                                           0x4 // 0: 24h   1: AM/PM




@property(nonatomic, assign) int                            height_in_cm;              /**< user height. */  //<所有设备可设置><All devices can be set>
@property(nonatomic, assign) int                            weight_in_kg;                /**< user weight */ //<所有设备可设置><All devices can be set>
@property(nonatomic, assign) int                            stride_length_in_cm;   /**< stride length, i.e., step length */ //<所有设备可设置><All devices can be set>
@property(nonatomic, assign) int                            stride_length_run_in_cm; /**< running stride length */      //<所有设备可设置><All devices can be set>
@property(nonatomic, assign) int                            stepRateForRunLength; /**< 跑步步频 */      //<所有设备可设置> Running step frequency <All devices can be set>
@property(nonatomic, assign) int                            units_type;              /** 0 international or  1 english unit **/
@property(nonatomic, copy)   NSString *                     nickname;                   //启动欢迎词 最大长度16字节 Welcome message at startup, maximum length of 16 bytes
@property(nonatomic, assign) int                            clock_orientation;          //device 时间显示方向 Device time display orientation PERIPHERAL_PROFILE_CLOCK_ORIENTATION_VERTICAL|PERIPHERAL_PROFILE_CLOCK_ORIENTATION_HORIZONTAL
@property(nonatomic, assign) int                            sleep_alarm_day_of_week;            //睡眠闹钟提醒时间（Sleep alarm reminder time） CLING_DEVICE_REMINDER_WEEKDAY
@property(nonatomic, assign) int                            bed_hr;                         //入睡小时 Bedtime hour
@property(nonatomic, assign) int                            bed_min;                    //入睡分钟 Bedtime minute
@property(nonatomic, assign) int                            wakeup_hr;                      //醒来小时 Wake-up hour
@property(nonatomic, assign) int                            wakeup_min;                     //醒来分钟 Wake-up minute
@property(nonatomic, assign) int                            screen_display_option;          //屏幕显示选项（Screen display option）,查看(see)PERIPHERAL_PROFILE_SCREEN_DISPLAY_OPTION  相关宏(related macros)
@property(nonatomic, assign) int                            touch_virbration;               //是否点击屏幕震动(Whether screen touch vibration is enabled) 查看(see)PERIPHERAL_PROFILE_TOUCH_VIRBRATION 相关宏(related macros)
@property(nonatomic, assign) int                            daily_goal;             // 每日公里目标(Daily kilometer goal) in KMs
@property(nonatomic, assign) int                            training_display_option;        //训练显示页面(Training display page) 查看(see)PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION  相关宏(related macros)
@property(nonatomic, assign) int                            age;                        //用户年龄 User's age
@property(nonatomic, assign) int                            sex;                            //用户性别 User's sex
@property(nonatomic, assign) int                            stride_length_run_indoor_in_cm; //室内跑步步长，如跑步机跑步 Indoor running stride length, such as treadmill running
@property(nonatomic, assign) int                            hr_alarm_rate;                          //心率区间报警值(Heart rate zone alarm value), using  PERIPHERAL_PROFILE_HEART_ALARM_ENABLE to enable hr alarm, default value is PERIPHERAL_PROFILE_HEART_ALARM_DEFAULT_VALUE
@property(nonatomic, assign) int                            pace_alarm_zone;  //配速报警值(Pace alarm value), using PERIPHERAL_PROFILE_PACE_ALARM_ENABLE to enable pace alarm, default value is PERIPHERAL_PROFILE_PACE_ALARM_DEFAULT_VALUE
@property(nonatomic, assign) int                            caloryDisplayType; //卡路里显示类型(Calorie display type)：using CALORIES_DISPLAY_TYPE_ALL or CALORIES_DISPLAY_TYPE_ACTIVE
@property(nonatomic)short iHealthInfoLevel;             //健康挑战级别(Health challenge level)  0:入门级(Beginner) 1:基础级(Basic) 2:活跃级(Active) 3:专业级(Professional)

//支持的设备：aura。  其他设备可不用赋值 Supported device: Aura. Other devices do not need to be set.
@property(nonatomic, assign)BOOL bCalAlarm;         //卡路里报警是否打开  默认关闭 Whether calorie alarm is enabled, default is off
@property(nonatomic, assign)short iCAlarmValue;     //卡路里报警值      默认1300   [1000,5000] Calorie alarm value, default 1300 [1000, 5000]
@property(nonatomic, assign)BOOL bStepAlarm;         //步数报警是否打开  默认打开 Whether step count alarm is enabled, default is on
@property(nonatomic, assign)short iSAlarmValue;     //步数报警值       默认10000   [10000,30000] Step count alarm value, default 10000 [10000, 30000]
@property(nonatomic, assign)short iTempAlarmValue;  //体温报警值 默认373（37.3*10）Temperature alarm value, default 373 (37.3*10)
@property(nonatomic, assign)short iTempLowAlarmValue;  //体温过低报警值 默认273（27.3*10）Low temperature alarm value, default 273 (27.3*10)

@end

@interface ClingBLEModel : NSObject

+ (ClingBLEModel*)sharedInstance;
- (NSString *)getDeviceName;                         //获取设备类型及名称
//1-> 8M flash ,其他值4M
@property(assign, class,readonly) NSInteger flashType;

@property(assign, class,readonly) BOOL traditionalLanguageSupport;

+ (void) setDataSyncDelegate:(id) delegate;

/**
 * @brief 更新本地缓存中与cling device绑定的user id   已绑定cling device需要使用该方法。 如需与已绑定设备建立连接，调用该方法后，再调用tryConnectDevice方法
 * @param bid 新的绑定id.  默认本地缓存的user id为registerDevice方法传入的bid,如cling device已经激活，本地缓存的bid与设备真实绑定的user id不一致，需要将设备绑定的userid传入.
 * @param cid 绑定设备后，获取到的cling id，可通过getDeviceInfo方法获取(企业版，绑定设备后，建议将cling id存储在服务器，作为是否绑定设备的tag)
 *
 */
+ (void)updateBondUid:(u_long)bid clingID:(NSString*)cid;
/**
 * @brief 通过设备蓝牙码激活设备。使用此方法时，请确保需要激活的四位蓝牙码对应的peripheral已经被搜索到,方法内部会自动关闭蓝牙扫描，在激活过程中，获取到complete结果前，请务调用stopDiscoveryDevice方法来寻求关闭蓝牙扫描，否则会造成内部初始化，产生无法获取到complete结果等问题
 * @param code cling device的四位蓝牙码，蓝牙码可以通过cling设备查看
 * @param bid 需要与cling device进行绑定的用户id。 企业版（未使用登录注册接口）需要将APP登录后对应的用户id填入;非企业版该参数无效
 * @return 激活前的一个异常判断，返回yes说明激活条件具备
 */
- (BOOL)registerDevice:(NSString*)code bondUid:(u_long)bid complete:(void(^)(void)) complete;
- (BOOL)registerDeviceByScanCode:(NSString *) scanCode userId:(int) userid complete:(void(^)(NSString * strClingId, NSString * strMac, NSString * strVersion)) complete;
///是否有效
- (BOOL)valiadQrCode:(NSString *)scanCode style:(ClingDeviceStyle)style;
- (void)deregisterDevice;     //反激活手表
- (void)tryConnectDevice;     //连接设备,当设备已经连接，内部将不进行连接操作
- (void)disconnectDevice:(BOOL) autoReconnect;       //已经连接后,设备断开连接. 切换账号或更换设备连接行为，请先调用此方法断开当前连接。 autoReconnect=YES时，断开后会马上尝试重连

/// setup ublox token for online and offline ephemeris download
- (void)setupUbloxToken:(NSString *)token;

- (void)setClingDeviceStyle:(ClingDeviceStyle)style;        //设置cling设备类型，搜索时，会根据style搜索出对应设备。请先调用本方法，再调用startDiscoveryDevice，确保搜索到的类型是想要的。  需搜索所有cling设备，将style置ClingDeviceStyleDeviceAll. 在建立连接时，请务必将setClingDeviceStyle方法置设备为对应style
- (void)startDiscoveryDevice;  //开始搜索设备
- (void)stopDiscoveryDevice;    //停止搜索设备，  进入激活时，激活方法会调用本方法停止新设备搜索。 注意：正在激活时，请务调用此方法，否则造成激活结果无法监测


//用户手动对设备进行设置前，先对ClingDeviceInitCfgNotification通知进行监听，接收到回调并在回调里调用downloadPhoneSettingFinished后，设置才能生效
- (void)setPushInfo:(CLING_WATCH_NOTIFICATION)cnotif ;   //设置手表推送相关信息
- (void)setDeviceCfg:(ClingDeviceCfg*)device;           //配置设备
- (void)setDeviceLanguage:(ClingDeviceLanguage)language;        //设置设备语言(watch之外的设备支持语言设置)
- (void)setDeviceReminderInfo:(NSArray*)array;          //设置提醒(最多32个提醒)  空数组则清空提醒 ClingDeviceReminder
- (void)updateDeviceReminderDirectly;                   //执行reminder更新到设备 调用本方法，闹钟会马上设置于设备上。否则将等待statemachine唤醒后配置
- (void)setDeviceWeatherInfo:(NSArray*)array;           //设置设备天气信息（最多设置今天到未来5天内） ClingDeviceWeather数组

///@@@[sample --> App -> Device]

/// 设置马达信息
/// @param interval 震动间隔，单位：秒，默认1秒     范围 1s ~ 3600s
/// @param dur 震动时长，单位：秒，默认1秒        范围 1s ~ 3600s  不得超过震动间隔
/// @param freq 震动频率,  范围 1hz ~ 100hz
/// @param enable 震动开关
- (void)setVibrationWithInterval:(int)interval
                        duration:(int)dur
                            freq:(int)freq
                          enable:(BOOL)enable;

/// 设置箭头信息
/// @param interval 闪烁间隔，shine为true时有效 单位：秒 范围 1s ~ 24 * 3600
/// @param dur 闪烁时长，单位：秒       范围 1s ~ 3600s，不大于interval
/// @param freq 闪烁频率    1~5 Hz
/// @param angle 箭头方向
/// @param backColor 背景色，只支持8种(0xFF0000 | 0x00FF00 |0x0000FF |0xFFFF00  | 0xFF00FF  | 0x00FFFF| 0xFFFFFF | 0x000000 )
/// @param forgroundColor 箭头色，只支持8种 (0xFF0000 | 0x00FF00 |0x0000FF |0xFFFF00  | 0xFF00FF  | 0x00FFFF| 0xFFFFFF | 0x000000 )
/// @param shine 闪烁
- (void)setArrowControlWithInterval:(long)interval
                           duration:(int)dur
                               freq:(int)freq
                              angle:(int)angle
                          backColor:(int)backColor
                     forgroundColor:(int)forgroundColor
                              shine:(BOOL)shine;

/// 设置ACC信息
/// @param interval 采样间隔，单位：秒    范围 300s ~ 3600s
/// @param dur 采样时长，单位：秒，默认15分钟    范围 60s ~ 1200s 且 小于采样间隔
/// @param rate 采样频率  两个值可选 50,100
/// @param autoSync 自动同步开关
- (void)setACCConfigWithInterval:(int)interval
                        duration:(int)dur
                            rate:(int)rate
                        autoSync:(BOOL)autoSync;

- (void)startGetRRI;
/**
 *  @brief 设置设备的身高、体重、步长等信息。每次设置需要对profileData所有属性赋值
 *  @param profileData ClingPeripheralUserProfileModel对象
 *  tips： 在downloadPhoneSettingFinished方法前调用updateUserProfile方法，需要将该方法放于setDeviceCfg或setDeviceLanguage方法前;在downloadPhoneSettingFinished后调用无此逻辑
 */
- (void) updateUserProfile:(ClingPeripheralUserProfileModel*) profileData;
- (ClingBLEState)getPhoneBLEState;  //获取手机蓝牙状态
- (NSDictionary*)getDeviceInfo;     //获取设备信息,有时由于设备service改变，造成连接成功却获取不到service.此时需要尝试如下方法，忽略手机蓝牙中对应的设备、关闭蓝牙再重开、手机飞行模式、设备重启、手机重启。其中有一个方法能解决无法获取设备信息问题
- (NSString *)getDeviceBLECode;
+ (BOOL)isDConnected;       //手环是否已经建立连接，连接成功返回YES

+ (BOOL)isDisconnected;     //是否断开链接

@property(nonatomic, readonly)BOOL isSyncing;         //是否在同步数据
/**
 * @brief 后台进入前台蓝牙处理逻辑
 * tips: 当手环已经连接，将下发获取手环分钟数据请求，进行分钟数据接收； 当手环未连接，将进行蓝牙连接，与调用tryConnectDevice方法相同
 */
+ (void)enterForeground;     
/**
 * @brief 判断设备是否需要升级
 * @param 目标版本号，一般是服务器返回的版本号
 * @param 当前版本号  通过getDeviceInfo获取当前版本号
 */
+ (BOOL) compareFirmwareVersionWithTarget:(NSString *)strtarget current:(NSString*)strcurrent;

/**
 * @brief 升级设备
 * @param data 手环升级包，如通过SDK中checkEnterpriseFirmwareUpdateRequest或getLatestFirmwareVersionRequest方法获取到升级包，此字段传nil；其他方法获取到的.bin升级包，转为nsdata传入，此时将不对升级包的版本做检查
 * block中返回升级中的错误码信息，为空或nil表示成功，其他为错误码
 * "status_code": 6120->未获取到最新版本 6121->电量低于15% 6122->当前版本号未获取到 6124->正在升级中 6126->蓝牙未开启 6127->文件CRC校验失败 6129->检测到手环空间不足,自动调用手环格式化命令，请重新尝试升级 6128->手环其他报错  6125->下载升级包失败
 */

- (void)upgradeFirmwareWithData:(NSData*)data complete:(void(^)(NSDictionary* result)) complete;
+ (void)reloadDeviceData;  //发送获取device分钟数据命令，用于处理实时性问题
- (void) downloadPhoneSettingFinished;      //所有蓝牙配置方法完后，调用此方法,此方法一定要写，否则会造成后期配置设备失败的情况  手环历史配置的相关方法放于ClingDeviceInitCfgNotification通知中执行
- (BOOL) isClingDistanceNormalizationValid;
- (BOOL) isClingDistanceNormalizationValidV2;

/**
 * @brief 发送血压校正值到cling 设备
 * @param hp 高压
 * @param lp 低压
 * 支持的device：lemon3-aura、leap
 * tips: 使用医用血压设备测量后，将数值发送到手环，使手环测量更精确.
 */
+ (void)sendBPCMessage:(u_char)hp lowPressure:(u_char)lp;


/// 血糖校准
/// @param type 0,1,2,3,4,5 -- 早餐前后，午餐前后，晚餐前后
/// @param value 血糖值
+ (void)sendGlucoseAdjustForType:(int)type value:(CGFloat)value;


/*
 * @brief 发送服药提醒数据到手环  当array=nil或者array的长度小于1时，方法将执行清空设备服药提醒
 * @param array @[ClingPillReminder,...]  数组按ClingPillReminder中的hour、minute顺序排列,下发过程中务必保持localid唯一性
 * 支持的device： aura手环,一次最多发送25条服药提醒
 */
+ (void)sendPillReminderArray:(NSArray*)array;

/*
 * @brief 运动中发送经纬度信息到aura 手环
 * @param timestamp 运动时时间戳
 * @param dLon/dLat 经纬度
 * @param ds 运动时速度 m/s
 * 支持的device: aura手环
 */
+ (void)sendGPSInfoTimstamp:(uint)ts longitude:(double)lng latitude:(double)lat speed:(float)spd;

/**
 * @brief 更新Cling Leap设备信息。如：表盘、星历
 * @param currentData 需要更新的data
 * @param idx 选择需要更新的表盘号 0或者1  idx=100为下发星历数据
 */
- (void)updateFileToFirmware:(NSData*)currentData index:(short)idx succ:(void(^)(NSDictionary* result)) complete;

/**
 * @brief 设置扫描检测设备是否注册的设备前缀
 * @param arrayDevNames: 设备前缀数组
 */
- (void) setDiscoverySkipDeviceName:(NSArray *) arrayDevNames;

- (void) removeAllFoundDevice;

#pragma mark - hela test
- (void) sendHelaTestOnOff:(BOOL) on isAcid:(BOOL) acid;

- (void) setHelaTestDelegate:(id) delegate;
///更新离线星历
+ (void)updateGpsAlmanacComplete:(void(^)(NSDictionary* result)) complete;
///是否在下载星历
+ (BOOL)ephemericUpdating;

+ (int)updatingIndex;

+ (BOOL)isUpdating;

@end

UIKIT_EXTERN NSString *const ClingDeviceRegisterSucceedNotification;  //手表与账号绑定错误成功  object中返回NSString类型的cling_id
UIKIT_EXTERN NSString *const ClingDeviceRegisterErrorNotification;  //手表与账号绑定错误通知  object中返回NSString类型的错误信息
UIKIT_EXTERN NSString *const ClingDeviceDeregisterNotification;  //手表与账号解除绑定错误通知  服务器报错返回NSDictionary类型，本地报错返回NSString  nil时解除绑定成功
UIKIT_EXTERN NSString *const ClingDeviceMinuteDataUpdateNotification;  //设备获取到分钟数据数据  ClingMinuteData类型
UIKIT_EXTERN NSString *const ClingDeviceDataSyncDoneNotification;  // all data syncing finished notification, including minute data, gps data if exist, etc. No parameters transferred
UIKIT_EXTERN NSString *const ClingServiceDidChangeStatusNotification;   //设备连接状态改变，已连接"1"或未连接"0"
UIKIT_EXTERN NSString *const ClingBLEDidChangeStatusNotification;   //设备蓝牙状态改变  在通知中通过[[ClingBLEModel sharedInstance] getPhoneBLEState]获取状态
UIKIT_EXTERN NSString *const ClingDiscoveryDidRefreshNotification;  //发现设备  返回CBPeripheral数组
UIKIT_EXTERN NSString *const ClingDeviceDataSyncingNotification;    //正在同步数据进度通知  @{@"total":xx,@"current":xx}

UIKIT_EXTERN NSString *const ClingDeviceGPSDataSyncingNotification; //正在同步GPS进度通知 
UIKIT_EXTERN NSString *const ClingDeviceGPSDataReceivedNotification; //GPS数据同步通知
UIKIT_EXTERN NSString *const ClingDeviceGPSDataSumInfoNotification; //GPS数据总和通知

UIKIT_EXTERN NSString *const ClingDeviceSendSOSNotification;        //sos通知
UIKIT_EXTERN NSString *const ClingDeviceSendFinderNotification;
UIKIT_EXTERN NSString *const ClingDeviceUpgradeFirmwareProgressNotification;        //升级固件进度通知  {@"progress":xx}  【0，1】
UIKIT_EXTERN NSString *const ClingDeviceRegisterProgressNotification;        //注册进度通知  {@"progress":xx}
UIKIT_EXTERN NSString *const ClingDeviceInitCfgNotification;        //在本通知中将原所有配置写入device，当device连接或重连，需要对device重新配置，以保证原配置有效。如：天气配置、提醒配置等。  设置后，请再调用downloadPhoneSettingFinished,此方法一定要写，否则会造成后期配置设备失败的情况
UIKIT_EXTERN NSString *const ClingDeviceCfgAuthNotification;        //在authorization过程中设置语言等配置
UIKIT_EXTERN NSString *const ClingDeviceUpdateFileProgressNotification;     //下发数字表盘到手环进度通知 {@"progress":xx} 【0，1】 cling leap支持
UIKIT_EXTERN NSString *const ClingDeviceDayTotalNotification;       //手表返回今天数据通知， 返回ClingDailyData对象  此通知中返回的天数据与手环显示一致，由于反激活与切换账号等操作，实际一天的数据求和与手环返回的天数据不一致。请根据需求选择是否使用本通知或通过分钟数据求和计算天数据.  如：用户带手环行走了1000步，反激活后，显示步数为零，通知中获取到的总步数也等于0。

UIKIT_EXTERN NSString *const ClingDeviceSendPaceRecordNotification; // pace轨迹记录通知,当pace开始运动后，每分钟发送一个响应通知 返回@{@“paceId”:@(运动id),@"sportType":@(ClingMinuteActType)}
UIKIT_EXTERN NSString *const ClingDeviceUpdateFileCompleteNotification;    //升级固件或者下发数字表盘结果通知  返回 number对象(ClingUpdateFileResult枚举)
UIKIT_EXTERN NSString *const ClingDeviceReceiveAccData;             //收到ACC消息

