//
//  HttpModel.h
//  ClingSDK
//
//  Created by Roffa Zhou on 15/4/3.
//  Copyright (c) 2015年 Roffa. All rights reserved.
//


/*
 所有时间戳从1970年起始
 status_code/ClingErrorCode返回：
 4002           //token过期  重新获取 accesstoken
 4001           //token异常,用户通过不存在的Token请求接口产生的错误，重新获取 accesstoken
 4003           //非法用户  用户请求中携带的Token和请求用户不匹配  重新登录
 4000           //非法requesttoken  重新登录
 4004           //requesttoken 空 重新登录
 
 6100           //用户名未输入
 6101           //用户密码未输入
 6102           //用户密码输入违规（用户密码8~32、大小写及数字、必须有字母与数字
 6110           //strType输入异常
 6120           未获取到最新版本信息
 6121           手表电量不足百分之十五
 6122           未获取当前固件版本信息
 6123           已经是最新版本
 6124           正在安装最近版本
 6125           下载文件失败
 6126           蓝牙连接异常
 6127           文件crc本地校验失败
 6128           device返回失败
 6129           device空间不足
 
 */



#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ClingUtilsModel.h"

@interface HttpModel : NSObject
+ (HttpModel*)sharedInstance;
+ (NSString*)getUserID;     //获取用户id
+ (NSString*)getClingId;    //获取设备蓝牙码
+ (NSString*)getRequestToken;       //获取requesttoken，accesstoken过期时请求

/* @brief 注册使用SDK权限,请保持网络连接
 * @param appid 从hicling开发者中心申请的APPID
 * @param appsecret 从hicling开发者中心申请的APPsecret
 * @param isEnterprise 是否为企业版（企业版定义：不依赖hicling公司服务器，从SDK获取到的若干数据使用自己的服务器存储；不使用SDK中登录注册逻辑，除固件升级接口，其他网络请求都不可使用，）
 */
- (BOOL)registerClingAppid:(NSString*)appid withAppSecret:(NSString*)appsecret enterprise:(BOOL)isEnterprise;

/* @brief 获取当前设备的最新版本信息,非企业版，可使用本方法或使用getLatestFirmwareVersionRequest方法.  如果设备需要升级，再调用upgradeFirmware方法进行升级
 * @return 成功且有最新版本返回最新版本号latestVersion与版本信息"desc"={
 //固件更新说明
 "zhcn": "新版本功能：\r\n1. 提高系统稳定性\r\n2. 修复遗留问题",
 "enus": "Function of the new version：\r\n1. Improve the system stability\r\n2. Bug fixes"
 }。无最新版本信息: latestVersion=@"0"、 desc值为nil
 */
- (void)checkEnterpriseFirmwareUpdateRequest:(void(^)(NSString* latestVersion,NSDictionary *desc)) success
                                failure:(void(^)(id result)) failure;
//登录或注册接口
- (void)loginWithRequest:(LoginRequestModel*)model success:(void(^)(NSDictionary* result)) success
                                    failure:(void(^)(id result)) failure;
//获取用户注册服务器地址
- (void)getServerAddressByUserName:(NSString *) strUserName url:(NSString *) url success:(void(^)(NSDictionary* result)) success
                           failure:(void(^)(id result)) failure;
//设置用户信息
- (void)setUserInfoRequest:(ClingUserInfo*)userInfo success:(void(^)(NSDictionary* result))success
                   failure:(void(^)(id result))failure;
- (void)getUserInfoRequest:(void(^)(ClingUserInfo* result)) success
                      failure:(void(^)(id result)) failure;
//注销接口
- (void)logoutRequest:(void(^)(NSDictionary* result)) success
                failure:(void(^)(id result)) failure;
//删除账号
- (void)deleteAccountRequest:(void(^)(NSDictionary* result)) success
                     failure:(void(^)(id result)) failure;
//获取分钟数据接口，成功返回ClingMinuteData数组
- (void)minuteDataWithRequest:(MinuteDataRequestModel*)model success:(void(^)(NSArray* result)) success
                failure:(void(^)(id result)) failure;
//获取分钟数据相关类型的最新几条数据
//type: eg. @"o2", top:5
- (void)minuteTopDataWithUserId:(NSInteger)uid type:(NSString *)type top:(NSInteger)top success:(void (^)(NSArray *))success failure:(void (^)(id))failure;
//获取当前设备的最新版本信息,未来可能废弃该方法
- (void)getLatestFirmwareVersionRequest:(void(^)(NSString* latestVersion,NSString *desc)) success
                                    failure:(void(^)(id result)) failure;
- (void)getLatestFirmwareVersionRequest:(BOOL) bEnableEte2Thermo success:(void(^)(NSString* latestVersion,NSString *desc)) success failure:(void(^)(id result)) failure;
//获取服务器运动bubble  starttime:时间戳,方法内会自动将starttime转该日零点时间戳  endtime:截止时间戳.如果endtime<starttime.endtime自动为该日23：59分时间戳，返回[ClingSportData,...]数组
- (void)getSportBubbleRequest:(int)starttime endtime:(int)end success:(void(^)(NSArray* result))success failure:(void(^)(id result))failure;

//上传运动bubble到服务器 array:@[ClingSportData,...]
- (void)uploadSportsRequest:(NSArray*)array success:(void(^)(NSDictionary* result))success failure:(void(^)(id result))failure;
//更新daytotal,调用本方法后，服务器会进行一次天数据计算。否则服务器的天数据将不为最新 time:ClingDailyData.daybeginTime
- (void)updateDaytotalRequest:(int)time success:(void(^)(NSDictionary* result))success failure:(void(^)(id result))failure;
//获取多天daytotal starttime:时间戳,方法内会自动将starttime转当日零点时间戳 [ClingDailyData,...]
- (void)getDaytotalRequest:(int)starttime endtime:(int)end  success:(void(^)(NSArray* result))success failure:(void(^)(id result))failure;
//获取健康指数列表  pageIndex:页号，起始页号为1  返回字典
- (void)getHealthIndexesRequest:(int)pageIndex success:(void(^)(id result))success failure:(void(^)(id result))failure;
//获取健康指数详情 time为健康指数列表中一条对应的时间戳
- (void)getHealthIndexDetailRequest:(int)time success:(void(^)(ClingHealthReportModel *healthIndex))success failure:(void(^)(id result))failure;
- (void)getFiveHealthIndexDetailRequest:(int)time success:(void(^)(ClingHealthReportModel *healthIndex))success failure:(void(^)(id result))failure;
//获取健康评估分值
- (void)getHealthEvalutionScoreRequest:(void(^)(int score))success failure:(void(^)(id result))failure;
//修改健康挑战级别
- (void)setHealthLevelRequest:(int)level success:(void(^)(NSDictionary* result))success
                   failure:(void(^)(id result))failure;

- (void) setFetchMinuteDataApi:(NSString *) api;

@end


 

