//
//  ClingInternalHttpModel.h
//  ClingSDK
//
//  Created by Roffa's Mac on 16/8/30.
//  Copyright © 2016年 Roffa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClingSetFaceModel : NSObject

@property (nonatomic) int iFaceid;
@property (nonatomic,copy) NSString *strCode;

@end

/***********************************************************************************************/
//  @Description                    : 表盘模型
//  @param                          : None
//  @return                         : None
//  @Author: yuan.liu
//  Note:
/***********************************************************************************************/
@interface ClingWatchIconsModel : NSObject

//表盘id 用于接口/file/setface，换取表盘代码文件
@property (nonatomic) int iFaceid;

//url表盘图片
@property (nonatomic,copy) NSString *strUrl;

//数量 表盘使用次数
@property (nonatomic) int iCount;

//适配版本
@property (nonatomic) double dVersion;

@end




@interface ConnectStatusModel : NSObject
@property(nonatomic)int iTime;
@property(nonatomic)double dLng;
@property(nonatomic)double dLat;
@property(nonatomic)BOOL bConn;
@property(nonatomic)BOOL bUpload;       //是否已上传到服务器
@property(nonatomic,strong)NSString *strAddress;
@property(nonatomic)int iDuration;
@property(nonatomic,strong)NSString *strBleCode;
@property(nonatomic)int iTZ;        //不同时区相对北京时区时间差
@end


//寻找手环
@interface ClingSearchDeviceModel : NSObject
@property(nonatomic, copy)NSString *sDID;           //device id
@property(nonatomic, copy)NSString *sMAC;           //device mac
@property(nonatomic)int64_t iLostId;         //丢失id
@property(nonatomic, assign)int iUID;               //bond user id
@property(nonatomic, copy)NSString *sLocation;      //地址
@property(nonatomic, copy)NSString *sPhone;         //手机号
@property(nonatomic, assign)float fLongitude;
@property(nonatomic, assign)float fLatitude;
@property(nonatomic)uint32_t iLostTime;             //丢失时间
@property(nonatomic,strong)NSString *sDName;        //设备名

@end



@interface ClingInternalHttpModel : NSObject

//用来更新表盘的face1id和face2id
+ (void)updateWatchFacesIdWithFace1ID:(int)face1ID;
+ (void)updateWatchFacesIdWithFace2ID:(int)face1ID;
+ (void)updateWatchFacesId:(int)i1 id2:(int)i2 id3:(int)i3 id4:(int)i4;

//watchIcon接口
+ (void)trinkWatchWithRequest:(int)userid withPageIndex:(int)pageindex withpagesSie:(int)pagesize success:(void(^)(NSArray* result,NSDictionary *faces)) success failure:(void(^)(id result)) failure;

//选中单个某个表盘
+ (void)trinkWatchWithRequest:(int)faceId face1Or2:(int)indx success:(void(^)(NSDictionary* result)) success failure:(void(^)(id result)) failure;

+ (ConnectStatusModel *)getConnectStatusModel:(NSDictionary*)d;

+ (ClingSetFaceModel *)getClingWatchFacesModel:(NSDictionary *)d;

//上报trinkgps接口
+ (void)trinkReportWithRequest:(NSArray*)model success:(void(^)(NSDictionary* result)) success
                      failure:(void(^)(id result)) failure;
//get trink map接口
+ (void)trinkMapWithRequest:(int)userid withTime:(int)time withTZ:(int)tz success:(void(^)(NSArray* result)) success
                    failure:(void(^)(id result)) failure;
//get trink connect接口
+ (void)trinkConnectWithRequest:(int)userid withTime:(int)time withEndTime:(int)endTime success:(void(^)(NSDictionary* result)) success
                        failure:(void(^)(id result)) failure;
//奥美健康接口
+ (void)getAcmeWayHealthRequest:(uint)userid success:(void(^)(NSDictionary* result)) success
                        failure:(void(^)(id result)) failure;
//获取天气aqi
+ (void)getWeatherRequest:(NSString*)city province:(NSString*)p success:(void(^)(NSDictionary* result)) success

                  failure:(void(^)(id result)) failure;
//上报设备丢失
+ (void)reportDeviceLossRequest:(ClingSearchDeviceModel*)model success:(void(^)(int64_t lostid))success failure:(void(^)(id result)) failure;
//获取丢失设备列表接口
+ (void)getDeviceLossListRequest:(uint)userid success:(void(^)(NSDictionary* result)) success
                        failure:(void(^)(id result)) failure;
//上报找到设备
+ (void)reportLossFoundRequest:(ClingSearchDeviceModel*)model success:(void(^)(NSDictionary *result))success failure:(void(^)(id result)) failure;
//手表与账号绑定
+ (void)bindDeviceRequest:(NSDictionary*)dict success:(void(^)(NSDictionary* result)) success
                  failure:(void(^)(id result)) failure;


//获取外网IP与国家地域  release:是否为正式版  0:release 1:debug

/*{
    data =     {
        city = "\U4e0a\U6d77\U5e02";
        country = "\U4e2d\U56fd";
        ip = "180.168.53.142\n";
        ischina = 1;
        province = "\U4e0a\U6d77\U5e02";
        "suggest_server" =         {
            domain = "tpi.hicling.com";
            ip = "114.80.0.226";
            ishttps = 0;
        };
    };
    status = 200;
}
 */
+ (void)getIPLocation:(int)release success:(void(^)(NSDictionary* result)) success
                  failure:(void(^)(id result)) failure;

+ (void) setAccessToken:(NSString *) accessToken;

@end
