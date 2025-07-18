//
//  ClingInternalModel.h
//  ClingSDK
//
//  Created by Roffa's Mac on 16/3/17.
//  Copyright © 2016年 Roffa. All rights reserved.
//



/*
 
 看这里   看这里
 
 ┏┳━━━━━━━━━━━━┓
 ┃┃████████████┃
 ┃┃███████┏━━┓█┃
 ┣┫███████┃翰 ┃█┃
 ┃┃███████┃临 ┃█┃
 ┃┃███████┃真 ┃█┃
 ┣┫███████┃经 ┃█┃
 ┃┃███████┗━━┛█┃
 ┣┫████████████┃
 ┃┃████████████┃
 ┗┻━━━━━━━━━━━━┛
 
 此类为cling内部使用，SDK对外发布时，需要将本类private
 SDK自己使用时，则将本类public
 
 
 
 
 */


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ClingConst.h"


@class CBPeripheral;

@protocol ClingGpsDataListener <NSObject>

- (void) onGpsDataBodyGot:(NSDictionary *) dictBody;
- (void) onGpsDataSumGot:(NSDictionary *) dictSum;

//- (void) onGpsSwimLapGot:(NSDictionary *) dictLap;
//- (void) onGpsSwimEndGot:(NSDictionary *) dictSum;

@end

@interface ClingInternalModel : NSObject

@property(nonatomic)HEALTH_INDEX_CALCULATION_BIT hib;   //当前主页需要显示的块


+ (ClingInternalModel*)sharedInstance;

@property(assign, class, nonatomic) BOOL isPeak;     //是否是peak
@property(readonly, nonatomic, class) NSDictionary *dInfo;
@property(readonly, nonatomic,class) NSString *clingid;

//device 操作相关
+ (ClingDeviceStyle)getDStype;   //获取设备类型
+ (void)backgroundConnectDev;
+ (void)enterBackground;
+ (void)enterForeground;
+ (void)setHomeScreenState:(BOOL)state;
+ (void)setStreamingMode:(BOOL)state;
+ (void)formatDisk;
+ (void)rebootPeripheral;
+ (BOOL)isConnected;
+ (BOOL)isMinuteStreamingFileUploaded;
+ (void) readPeripheralRssi;
+ (NSArray*)connectedServices;
+ (NSString *)getPeripheralCode:(CBPeripheral *)peripheral;
+ (ClingDeviceStyle) getClingTypeByClingId:(NSString *) cid;
/**
 * @brief 返回rssi相关信息
 * key值为CBPeripheral.hash, value为NSNumber类型的rssi值
 */
+ (NSDictionary*)peripheralRSSIs;
+ (BOOL)isRegistered;
+ (BOOL) isVirtualDevice;
+ (void) loadVirtualDeviceInfo;
+ (void)setDeviceSimulationMode:(BOOL)mode;
+ (void)enableDbgMode:(BOOL)mode;
+ (NSString *)getRegisteredDeviceID;
+ (void) enableDeviceStreaming:(bool)bEnable;
+ (void) setOtaDbgCmd:(int)mode data:(char*)data size:(int)size;
+ (NSString *)getClingDevicePrefix;
+ (NSString*)getClingAccesstoken;
+ (NSString*)getClingDomain;        //获取当前服务器域名
+ (void)setSignUpOrgin:(NSString*)origin;        //注册平台  如：clingios  一兆韦德
+ (void)setClingHostDomain:(NSString*)domain;
+ (void)setClingEncrypt:(BOOL)cling;        //选择加密方式
+ (void) setClingBackendServerV2:(BOOL) backendV2; // 选择后端版本
+ (void)setUserId:(NSString *)uid;
+ (void)updateAccessToken:(NSString*)reqToken succ:(void(^)(NSDictionary* result)) succ
                     fail:(void(^)(id result)) fail;
+ (void)setUnUploadMinuteData:(BOOL)unUpload;       //是否取消上传分钟数据

//封装网络请求方法，使cling App可以直接调用 SDK中网络请求方法
+ (void) setAgent:(NSString *) strAgent;
+ (void)setClingNormalRequestHeaders:(NSMutableURLRequest *)request isPost:(BOOL)ispost;
+ (NSData *)createClingJsonBodyWithParamDic:(NSDictionary *)dic rsa:(BOOL)brsa;
+ (void)httpRequest:(NSURLRequest*)request succ:(void(^)(NSDictionary* result)) succ
               fail:(void(^)(id result)) fail;

+ (int)getPaceSpeed:(int)distance withTime:(int)time;       //获取配速  distance:距离  time:时间
+ (NSArray*)sortArrayUseDescriptor:(NSString*)descroptor sourceArray:(NSArray*)array;       //根据数组中，某个字段进行排序

//获取下载地址数据
+ (void)upWatchIconsFace:(NSString *)strUrl result:(void(^)(NSData* data))complete;

/**
 获取用户连接过的设备id
 author:yuan.liu
 @return 返回用户连接过的历史设备id
 */
+ (NSArray <NSString*>*)getClingIds;

//dictionary 与 data 互相转换
+ (NSData*)dataFromDictionary:(NSDictionary*)dict;
+ (NSDictionary*)dictionaryFromData:(NSData*)data;
//array 与 data 互相转换
+ (NSData *)dataFromArray:(NSArray*)array;
+ (NSArray*)arrayFromData:(NSData*)data;
//校正health  index  bit  值,防止值超过最大值或者某个device不存在的bit处理
- (void)initializeHealthIndexBit;
+ (UIColor *)getColorForSpeed:(float)speed andIsLeapOutDoor:(BOOL)isOutDoor;  //根据速度转换为颜色
//+ (int)getPaceForSpeed:(float)speed;        //速度转配速
////根据配速转换为速度（m/s）
//+ (float)getSpeedForPace:(int)pace;
+ (void)afterTime:(NSTimeInterval)t block:(void(^)(void))b;     //延时执行
+ (CGSize)getImageFitSize:(CGSize)size;     //根据原始图片长宽，计算出需要截取的图片长宽
+ (CGSize)getImageShowSize:(CGSize)size;    //根据原size，缩放图片到目标大小

/*
 * 骑行模式下，发送信息到device
 * @param distance:m
 * @param speed:米(m)/小时(h)
 * 支持的device: pace手环
 **/
+ (void)sendWorkoutMessage:(uint)distance speed:(uint)speed;

/*
 * 手环开始运动后，GPS获取成功后，下发到手环告知
 * @param status: 0:gps定位  1:network定位 2:无定位
 * 支持的device: pace手环
 */
+ (void)sendWorkoutGPSMessage:(uint)status;



//获取当前打开的vc
+ (UIViewController *)getCurrentVC;

//精确计算两数相除的结果。防止精度丢失问题
+ (float)dividingWithString:(NSString *)value1 string:(NSString*)value2;

+ (void) setAppIdValid:(BOOL) ben;

/*
 * 接收到手表GPS信息
 *
 [dict setObj:@(data->timestamp) key:@"ts"];
 [dict setObj:@(data->secondindex) key:@"si"];
 [dict setObj:@(data->speed/100.0) key:@"speed"];
 [dict setObj:@(data->longitude) key:@"lng"];
 [dict setObj:@(data->latitude) key:@"lat"];
 [dict setObj:@(data->altitude) key:@"alt"];
 [dict setObj:@(data->distance_km) key:@"distance"];
 [dict setObj:@(data->distance_km_max) key:@"distmax"];
 [dict setObj:@(data->heartrate) key:@"hr"];
 [dict setObj:@(data->stamina) key:@"stamina"];
 [dict setObj:@(data->stamina_aerobic) key:@"aerobic"];
 [dict setObj:@(data->stamina_anerobic) key:@"anaerobic"];
 [dict setObj:@(data->kcal) key:@"kcal"];
 [dict setObj:@(data->kcal_max) key:@"kcalmax"];
 [dict setObj:@(data->cadance) key:@"cadence"];
 [dict setObj:@(type) key:@"workouttype"];
 
 */
- (void) setGpsDelegate:(id) delegate;

- (void) receivedFirmwareGPSInfo:(NSDictionary *)data;
//运动结束后 接收到运动状态信息
- (void)receivedBodyInfo:(int)dist totalCal:(int)cal type:(short)t startTime:(long)startTime endTime:(long)endTime;
- (void) receivedBodyInfo:(NSDictionary *) dictSummary;

/* 接收到服药提醒
 * @param array  @[@{"id":xxx,"time":xxx},...] 分别为提醒ID、点击关闭提醒时间戳
 */
+ (void)receivedPillReminderArray:(NSArray*)array;

/**
 * @brief 搜索设备时，配置搜索类型
 */
+ (void)setClingSearchDeviceStyle:(ClingDeviceStyle)style;
+ (ClingDeviceStyle)getClingSearchDeviceStyle;

//当前是否正在进行星历传输
+ (BOOL)getStateOfEphemericUpdating;

+ (void) setRequestToken:(NSString *) requestToken;

@property(class, nonatomic, readonly) BOOL isTronSeries;
@property(class, nonatomic, readonly) BOOL isTRnb;

@end


@interface ClingSleepAlg : NSObject

+ (void) getClassfiedSleep:(int*) activity_dat walk:(int*)pwalk heart:(int*)phr isHR:(bool)hr sleepBuf:(int *) sleep_stat_buf length:(int)length;

@end


UIKIT_EXTERN NSString *const ClingInternalDeviceMinuteDataNotification;       //分钟数据更新通知,此通知每分钟会回调两次，最后一次是修正睡眠后分钟数据 返回ClingMinuteData
UIKIT_EXTERN NSString *const ClingInternalDeviceUpBeforeRegNotification;   //设备是否为1.299/1.298问题版本，是则回调，告诉用户先升级
UIKIT_EXTERN NSString *const ClingInternalDeviceInfoUpdategNotification;   //设备信息改变
UIKIT_EXTERN NSString *const ClingInternalAccountDeletedNotification;   //账号删除
UIKIT_EXTERN NSString *const ClingInternalSaveDataNotification;   //通知保存数据 非主线程保存
UIKIT_EXTERN NSString *const ClingInternalSaveRawDataNotification;   //通知保存未加工数据  非主线程保存
UIKIT_EXTERN NSString *const ClingDeviceOrginDataUpdateNotification;  //手表返回的原始分钟数据  dictionary
UIKIT_EXTERN NSString *const ClingDeviceDeregisterStartNotification;  //手表与账号开始解除绑定通知
UIKIT_EXTERN NSString *const ClingInternalDiscoveryPeripheralNotification;   //返回一个CBPeripheral
UIKIT_EXTERN NSString *const ClingInternalReceivedGPSInfoNotification;      //接收到GPS通知
UIKIT_EXTERN NSString *const ClingInternalReceivedBodyInfoNotification;      //接收到body通知
UIKIT_EXTERN NSString *const ClingInternalDeviceDayTotalNotification;       //手表返回今天数据通知， 返回ClingDailyData对象  此通知中返回的天数据与手环显示一致，由于反激活与切换账号等操作，实际一天的数据求和与手环返回的天数据不一致。请根据需求选择是否使用本通知或通过分钟数据求和计算天数据.  如：用户带手环行走了1000步，反激活后，显示步数为零，通知中获取到的总步数也等于0。   会多次响应通知，同步中与同步后响应

UIKIT_EXTERN NSString *const ClingInternalReceivedPillReminderNotification;     //接收到服药提醒通知，通知中会返回一个数组结果  @[@{"id":xxx,"time":xxx},...] 分别为提醒ID、点击关闭提醒时间戳


