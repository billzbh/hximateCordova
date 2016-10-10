//
//  iMateAppFace+Pinpad.h
//  HXiMateSDK
//
//  Created by hxsmart on 13-12-23.
//  Copyright (c) 2013年 hxsmart. All rights reserved.
//

#import <HXiMateSDK/iMateAppFace.h>

// Pinpad加密算法
#define ALGO_ENCRYPT                    0
#define ALGO_DECRYPT                    1

// 密码键盘类型
#define PINPAD_MODEL_KMY                0   //凯明扬-KMY3512
#define PINPAD_MODEL_XYD                1   //信雅达-P90
#define PINPAD_MODEL_SZB                2   //苏州银行定制-深圳科羽
#define PINPAD_MODEL_M35                3   //联迪M35 mPOS
#define PINPAD_MODEL_TIANYU             4   //天喻mPOS
#define PINPAD_MODEL_HUAXIN             5   //华信401

// Pinpad操作类型枚举
typedef enum {
    PinPadRequestTypePowerOn = 0,
    PinPadRequestTypePowerOff,
    PinPadRequestTypeReset,
    PinPadRequestTypeVersion,
    PinPadRequestTypeDownloadMasterKey,
    PinPadRequestTypeUpdateMasterKey,
    PinPadRequestTypeDownloadWorkingKey,
    PinPadRequestTypeInputPinBlock,
    PinPadRequestTypeEncrypt,
    PinPadRequestTypeMac,
    PinPadRequestTypeHash,
    PinPadRequestTypeSN,
    PinPadRequestTypeInputPlainPin
}PinPadRequestType;

@protocol iMateAppFacePinpadDelegate <iMateAppFaceDelegate>

// PinPad返回数据处理
-(void)pinPadDelegateResponse:(NSInteger)returnCode
                  requestType:(PinPadRequestType)type
                 responseData:(NSData *)data
                        error:(NSString *)error;

@end

@interface iMateAppFace (Pinpad)

/*
 * Pinpad有关
 */

// 绑定蓝牙4.0通讯方式的Pinpad，仅对PINPAD_MODEL_M35和PINPAD_MODEL_TIANYU有效
-(void)pinpadBindDevice:(NSString *)pinpadDeviceName;

// 设置支持的Pinpad类型，目前支持PINPAD_MODEL_KMY，PINPAD_MODEL_XYD，PINPAD_MODEL_SZB
-(void)pinpadSetModel:(int)pinpadModel;

// 替换当前缺省的Delegate
-(void)pinpadReplaceDelegate:(id)delegate;

// Pinpad上电 (通讯波特率为9600 校验方式 0）
-(void)pinPadPowerOn;

// Pinpad下电
-(void)pinPadPowerOff;

// Pinpad取消输入
- (void)pinPadCancel;

// Pinpad复位自检
// initFlag 	YES 清除Pinpad中的密钥
//              NO  不清除密钥
-(void)pinPadReset:(BOOL)initFlag;

// 获取Pinpad的版本号信息
-(void)pinPadVersion;

// Pinpad下装主密钥(明文)
// algorithm	算法，0：DES，1：3DES，2：SM4
// index		主密钥索引
// mastKey		主密钥
// keyLength	主密钥长度
-(void)pinPadDownloadMasterKey:(int)algorithm index:(int)index masterKey:(Byte *)masterKey keyLength:(int)length;

// Pinpad更新主密钥(密文)
// algorithm	算法，0：DES，1：3DES，2：SM4
// index		主密钥索引
// mastKey		主密钥
// keyLength	主密钥长度
-(void)pinPadUpdateMasterKey:(int)algorithm index:(int)index masterKey:(Byte *)masterKey keyLength:(int)length;


// Pinpad下装工作密钥(主密钥加密）
// algorithm		算法，0：DES，1：3DES，2：SM4
// masterIndex		主密钥索引
// workingIndex	    工作密钥索引
// workingKey		工作密钥
// keyLength		工作密钥长度
-(void)pinPadDownloadWorkingKey:(int)algorithm masterIndex:(int)masterIndex workingIndex:(int)workingIndex workingKey:(Byte *)workingKey keyLength:(int)keyLength;

// Pinpad输入密码（PinBlock）
// algorithm		算法，0：DES，1：3DES，2：SM4
// isAutoReturn	    输入到约定长度时是否自动返回（不需要按Enter)
// masterIndex		主密钥索引
// workingIndex	    工作密钥索引
// cardNo			卡号/帐号(最少12位数字)
// pinLength		需要输入PIN的长度
// timeout			输入密码等待超时时间 <= 255 秒
-(void)pinPadInputPinblock:(int)algorithm isAutoReturn:(BOOL)isAutoReturn masterIndex:(int)masterIndex workingIndex:(int)workingIndex cardNo:(NSString *)cardNo pinLength:(int)pinLength timeout:(int)timeout;

/**
 * Pinpad输入明文密码
 * @param   message         提示信息(有的Pinpad不支持)
 * @param   pinLength		需要输入PIN的长度
 * @param   timeout			输入密码等待超时时间 <= 255 秒
 */
-(void)pinPadInputPlainPin:(NSString *)message pinLength:(int)pinLength timeout:(int)timeout;

// Pinpad加解密数据
// algorithm		算法，0：DES，1：3DES，2：SM4
// cryptoMode       加解密方式，取值: ALGO_ENCRYPT, ALGO_DECRYPT, 以ECB方式进行加解密运算
// masterIndex		主密钥索引
// workingIndex	    工作密钥索引，如果工作密钥索引取值-1，使用主密钥索引指定的主密钥进行加解密
// data			    加解密数据
// dataLength		加解密数据的长度,要求8的倍数并小于或等于248字节长度
-(void)pinPadEncrypt:(int)algorithm cryptoMode:(int)cryptoMode masterIndex:(int)masterIndex workingIndex:(int)workingIndex data:(Byte*)data dataLength:(int)dataLength;

// Pinpad数据MAC运算（ANSIX9.9）
// algorithm		算法，0：DES，1：3DES，2：SM4
// masterIndex		主密钥索引
// workingIndex	    工作密钥索引，如果工作密钥索引取值-1，使用主密钥索引指定的主密钥进行加解密
// data			    计算Mac原数据
// dataLength		Mac原数据的长度,要求8的倍数并小于或等于246字节长度
-(void)pinPadMac:(int)algorithm masterIndex:(int)masterIndex workingIndex:(int)workingIndex data:(Byte*)data dataLength:(int)dataLength;

// Pinpad计算数据散列值（散列结果，SHA1算法，长度为20字节，SM3长度为32字节）
// hashAlgorithm	散列算法，0：SHA1，1：SM3
// data			    计算Mac原数据
// dataLength		摘要原数据的长度
-(void)pinPadHash:(int)hashAlgorithm data:(Byte*)data dataLength:(int)dataLength;

//获取设备序列号
-(void)pinPadGetProductSN;

// 获取当前密码键盘类型
-(int)pinpadGetModel;


@end
