//
//  iMateAppFace+Fingerprint.h
//  HXiMateSDK
//
//  Created by hxsmart on 13-12-23.
//  Copyright (c) 2013年 hxsmart. All rights reserved.
//

#import <HXiMateSDK/iMateAppFace.h>


// 指纹模块类型
#define FINGERPRINT_MODEL_JSABC         0   //浙江维尔指纹仪（2种协议）
#define FINGERPRINT_MODEL_SHENGTENG     1   //升腾定制（天诚盛业指纹模块）
#define FINGERPRINT_MODEL_ZHONGZHENG    2   //中正指纹仪
#define FINGERPRINT_MODEL_TIANSHI       3   //深圳天识
#define FINGERPRINT_MODEL_TIANSHI_EXT   4   //深圳天识 （外接串口）

// Fingerprint操作类型枚举
typedef enum {
    FingerprintRequestTypePowerOn = 0,
    FingerprintRequestTypePowerOff,
    FingerprintRequestTypeVersion,
    FingerprintRequestTypeFeature,
    FingerprintRequestType256Feature,
    FingerprintRequestTypeUploadImage,
    FingerprintRequestTypeTemplate,
    FingerprintRequestTypeSetBaudrate,
    FingerprintRequestTypePowerOnThroughout,
    FingerprintRequestTypeUpdateLocalFPDB,
    FingerprintRequestTypeVerify
}FingerprintRequestType;

@protocol iMateAppFaceFingerprintDelegate <iMateAppFaceDelegate>

// Fingerprint返回数据处理
-(void)fingerprintDelegateResponse:(NSInteger)returnCode
                  requestType:(FingerprintRequestType)type
                 responseData:(NSData *)data
                        error:(NSString *)error;
@end



@interface iMateAppFace (Fingerprint)

/*
 * Fingerprint有关
 */

// 设置支持的指纹仪类型，目前支持FINGERPRINT_MODEL_JSABC
-(void)fingerprintSetModel:(int)fingerprintModel;

//取消 获取指纹特征
-(void)fingerprintCancel;

//Fingerprint上电 (通讯波特率为9600 校验方式 0）
-(void)fingerprintPowerOn;

// Fingerprint下电
-(void)fingerprintPowerOff;

// 获取Fingerprint的版本号信息
-(void)fingerprintVersion;

// 读取指纹特征值, 指纹模块超时时间为5秒
-(void)fingerprintFeature;

//读取指纹特征值，256字节 for 中正指纹仪
-(void)fingerprint256FeatureForZHONGZHENG;

//按压三次产生一个指纹模板
-(void)GenerateFingerTemplate;

//更新本地指纹库
-(void)UpdateFingerprintDB:(NSData *)InData Index:(int)index;

//本地比对指纹
-(void)VerifyFingerPrint;

//读取图像，目前支持 中正指纹仪，天诚盛业，其他不支持
-(void)fingerprintImage;

//更改波特率
-(void)setBaudrate:(long)baudrate;

// Fingerprint上电，并进入指纹模块设置模式
// 进入该模式后，将iMate的主串口与指纹模块的串口连接起来
// 该模式可用于指纹模块的参数设置，可通过iMate串口直接操作指纹模块
// 该方法调用后，将通过发送FingerprintRequestTypePowerOnThroughout类型的delegate通知执行的情况。
// 调用fingerprintPowerOff即可退出该模式
-(void)fingerprintPowerOnThroughout;


@end
