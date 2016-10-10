//
//  GenAppFace.h
//  HXiMateSDK
//
//  Created by zbh on 16/6/20.
//  Copyright © 2016年 hxsmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
// 指纹模块类型
#define FINGERPRINT_MODEL_JSABC         0   //浙江维尔指纹仪（2种协议）
#define FINGERPRINT_MODEL_SHENGTENG     1   //升腾定制（天诚盛业指纹模块）
#define FINGERPRINT_MODEL_ZHONGZHENG    2   //中正指纹仪
#define FINGERPRINT_MODEL_TIANSHI       3   //深圳天识
#define FINGERPRINT_MODEL_TIANSHI_EXT   4   //深圳天识 （外接串口）

//密码键盘类型
#define PINPAD_MODEL_KMY                0   //凯明扬-KMY3512
#define PINPAD_MODEL_XYD                1   //信雅达-P90
#define PINPAD_MODEL_SZB                2   //苏州银行定制-深圳科羽
#define PINPAD_MODEL_M35                3   //联迪M35 mPOS
#define PINPAD_MODEL_TIANYU             4   //天喻mPOS
#define PINPAD_MODEL_HUAXIN             5   //华信401


// Fingerprint操作类型枚举
typedef enum {
    CRBankFingerprintRequestTypePowerOn = 0,
    CRBankFingerprintRequestTypePowerOff,
    CRBankFingerprintRequestTypeFeature
}CRBankFingerprintRequestType;

// Pinpad操作类型枚举
typedef enum {
    CRBankPinPadRequestTypeDownloadMasterKey,
    CRBankPinPadRequestTypeDownloadWorkingKey,
    CRBankPinPadRequestTypeInputPlainPin,
    CRBankPinPadRequestTypeInputPinBlock,
    CRBankPinPadRequestTypeMac,
    CRBankPinPadRequestTypeHash,
}CRBankPinPadRequestType;


// Pinpad操作类型枚举
typedef enum {
    PBOC_IC = 0,
    PBOC_RF = 1
}CardType;

@protocol CRBankAppFaceDelegate <NSObject>

@optional

// 对蓝牙4.0的设备(例如，iMate401)提供搜索结果通知，不支持通过蓝牙对码的设备（例如，iMate101）
// 当openSession时, 如果未绑定设备(仅蓝牙4.0设备)，将自动查找支持的设备，查找到设备后，返回设备蓝牙名称
// 如果调用startSearchBLE，搜索到的设备将通过该delegate通知
- (void)DelegateFoundAvailableDevice:(NSString *)deviceName;

// 当iMate蓝牙连接连通或者中断时，该方法被调用，通知目前的蓝牙连接状态
- (void)DelegateConnectStatus:(BOOL)isConnecting;

// 刷卡操作执行结束后，该方法被调用，返回结果
- (void)DelegateSwipeCard:(NSInteger)returnCode
                        track2:(NSString*)track2
                        track3:(NSString *)track3
                         error:(NSString *)error;

// 读PBOC卡信息操作执行结束后，该方法被调用，返回结果。
// cardInfo中的数据用","间隔，包括：卡号，持卡人姓名，持卡人证件号码，应用失效日期、卡序列号
- (void)DelegateReadBankIcInfo:(NSInteger)returnCode
                           cardInfo:(NSString *)cardInfo
                              error:(NSString *)error;


// 读身份证操作执行结束后，该方法被调用(直接得到图片)，返回结果。可调用processIdCardInfo对information拆分成数组
- (void)DelegateIDReadMessage:(NSInteger)returnCode
                       information:(NSData *)information
                             photo:(UIImage*)photo
                             error:(NSString *)error;

// Fingerprint返回数据处理
-(void)DelegateFingerprintResponse:(NSInteger)returnCode
                       requestType:(CRBankFingerprintRequestType)type
                      responseData:(NSData *)data
                             error:(NSString *)error;

// PinPad返回数据处理
-(void)DelegatePinpadResponse:(NSInteger)returnCode
                  requestType:(CRBankPinPadRequestType)type
                 responseData:(NSData *)data
                        error:(NSString *)error;

// 等待事件结束后，该方法被调用，返回结果
// 如果returnCode不为0，error有错误信息
// eventId ：1检测到刷卡；2检测到IC卡；4检测到射频卡
// data    ：刷卡时返回二磁道、三磁道数据；IC返回复位数据；射频卡返回4字节的序列号
- (void)DelegateWaitCardEvent:(NSInteger)returnCode
                       eventId:(NSInteger)eventId
                          data:(NSData *)data
                         error:(NSString *)error;


//PBOC High接口 开始交易返回的数据
//cardInfo字典：
/*
 Field55        TLV格式的55域内容
 Pan            主账号[19]
 PanSeqNo       主账号序列号, 0-99, -1表示不存在
 Track2         二磁道等效数据[37], 3x格式, 长度为0表示不存在
 ExtInfo        其它数据, 返回的项目包括: 姓名、证件类型、证件号、应用失效日期、一磁道数据、现金余额、余额上限, 各项目按照上述顺序，数据之间用逗号分割。
 */
- (void)DelegateInitBankIcCardTrans:(NSInteger)returnCode
                      cardInfo:(NSDictionary *)cardInfo
                         error:(NSString *)error;

//PBOC High接口 完成交易返回的数据
- (void)DelegateFinishBankIcCardTrans:(NSInteger)returnCode
                           outData:(NSString *)outTlvData
                              error:(NSString *)error;

@end

@interface GenAppFace : NSObject

@property (assign, nonatomic) id<CRBankAppFaceDelegate> delegate;

// 获取GenAppFace单例
+ (GenAppFace *)sharedController;

// 该方法对身份证信息进行拆分
+ (NSArray *)processIdCardInfo:(NSData *)information;

// 该方法对身份证照片数据进行解码
+ (UIImage *)processIdCardPhoto:(NSData *)photoData;

// 对蓝牙4.0的设备(例如，iMate401)提供设备绑定操作，蓝牙对码的设备（例如，iMate101）无效
// 绑定查找到的蓝牙4.0 设备, 只有绑定设备后，设备才可以正常连接; deviceName = nil则解除绑定
// 支持前缀部分匹配和完整的匹配方式, 例如@“iMate-”，即绑定所有以"iMate-"开头的设备
// 如果使用蓝牙4.0的iMate设备，该方法须在openSession之前调用
- (void)bindingDevice:(NSString *)deviceName;

// 开始搜索蓝牙4.0设备, 例如iMate401(含键盘)、联迪M35等使用蓝牙4.0通讯的设备(不需要对码)
// 该方法调用后，已经连接的4.0设备会暂时中断连接
// 搜索到的设备将通过 DelegateFoundAvailableDevice 来通知结果
-(void)startSearchBLE;

// 停止搜索蓝牙4.0设备
-(void)stopSearchBLE;

// 打开与蓝牙4.0设备的连接会话，返回YES会话建立成功
// 如果使用已经对码的非蓝牙2.0设备，将优先连接
- (BOOL)openSession;

// 关闭与蓝牙4.0设备的连接会话
- (void)closeSession;

// 检测蓝牙连接是否正常，返回YES表示连接正常
- (BOOL)connectingTest;

// 检测蓝牙4.0设备是否在工作状态，返回YES表示正在工作中。
- (BOOL)isWorking;

// 蓝牙4.0设备产品序列号
- (NSString *)deviceSerialNumber;

// 刷卡请求，timeout是刷卡的最长等待时间(秒)
- (void)swipeCard:(NSInteger)timeout;


//设置卡类型（选择射频卡 or IC卡）. 受此方法影响的其他方法有：
// 1. readBankIcInfo:
// 2. PBOC High 接口
-(void)setBankIcCardType:(CardType)cardType;

// 结果由DelegatePbocReadInfo获得
// 获取卡号，持卡人姓名，持卡人证件号码，应用失效日期、卡序列号
// timeout为IC卡放到读卡位置的最长等待时间(秒)
- (void)readBankIcInfo:(NSInteger)timeout;

// 读二代身份证操作请求，timeout为身份证放到读卡位置的最长等待时间(秒)
- (void)idReadMessage:(NSInteger)timeout;

// 中断操作
- (void)cancel;

// iMate蜂鸣响一声
- (void)buzzer;


// 等待事件，包括磁卡刷卡、Pboc IC插入、放置射频卡。timeout是最长等待时间(秒)
// eventMask的bit来标识等待事件：
//      0x01    等待刷卡事件
//      0x02    等待插卡事件
//      0x04    等待射频事件
//      0xFF    等待所有事件
// 等待的结果通过delegate响应
- (void)waitCardEvent:(Byte)eventMask timeout:(NSInteger)timeout;

/* *********************************************************************************/
/* 指纹模块有关操作                                                                   */
/* *********************************************************************************/

// 设置支持的指纹仪类型
-(void)fingerprintSetModel:(int)fingerprintModel;

// 读取指纹特征值, 指纹模块超时时间为5秒
-(void)fingerprintFeature;


/* *********************************************************************************/
/* 密码键盘有关操作                                                                   */
/* *********************************************************************************/

// 设置支持的Pinpad类型
-(void)pinpadSetModel:(int)pinpadModel;

// Pinpad下装主密钥
// algorithm	算法，0：DES，1：3DES，2：SM4
// index		主密钥索引
// mastKey		主密钥
// keyLength	主密钥长度
-(void)pinPadDownloadMasterKey:(int)algorithm index:(int)index masterKey:(Byte *)masterKey keyLength:(int)length;

// Pinpad下装工作密钥(主密钥加密）
// algorithm		算法，0：DES，1：3DES，2：SM4
// masterIndex		主密钥索引
// workingIndex	    工作密钥索引
// workingKey		工作密钥
// keyLength		工作密钥长度
-(void)pinPadDownloadWorkingKey:(int)algorithm masterIndex:(int)masterIndex workingIndex:(int)workingIndex workingKey:(Byte *)workingKey keyLength:(int)keyLength;

// Pinpad输入密码（PinBlock）
// algorithm		算法，0：DES，1：3DES，2：SM4
// masterIndex		主密钥索引
// workingIndex	    工作密钥索引
// cardNo			卡号/帐号(最少12位数字)
// pinLength		需要输入PIN的长度
// timeout			输入密码等待超时时间 <= 255 秒
-(void)pinPadInputPinblock:(int)algorithm masterIndex:(int)masterIndex workingIndex:(int)workingIndex cardNo:(NSString *)cardNo pinLength:(int)pinLength timeout:(int)timeout;

/**
 * Pinpad输入明文密码
 * @param   message         提示信息(有的Pinpad不支持)
 * @param   pinLength		需要输入PIN的长度
 * @param   timeout			输入密码等待超时时间 <= 255 秒
 */
-(void)pinPadInputPlainPin:(NSString *)message pinLength:(int)pinLength timeout:(int)timeout;

//取消上面两个输入密码的方法的等待。
-(void)pinPadCancel;

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


/* *********************************************************************************/
/* PBOC Card 有关操作 （PBOC High 接口）  */
/* 注意 ： 1. 必须先初始化交易核心一次
          2.【开始交易】 与 【完成交易】 生成的数据当次有效。
*/
/* *********************************************************************************/

//初始化核心(至少执行一次)
//       pszMerchantId   : 商户号[15]
//		 pszTermId       : 终端号[8]
//		 pszMerchantName : 商户名字[40]
//		 uiCountryCode   : 终端国家代码, 1-999
//		 uiCurrencyCode  : 交易货币代码, 1-999
-(int)InitBankIcCardCore:(NSString *)pszMerchantId
                  TermId:(NSString *)pszTermId
            MerchantName:(NSString *)pszMerchantName
             CountryCode:(unsigned int)uiCountryCode
            CurrencyCode:(unsigned int)uiCurrencyCode;

//开始交易，获得IC卡数据,结果通过（DelegateInitBankIcCardTrans:cardInfo:error:）返回
//参数：
/*
   dateTime             交易时间  YYYYMMDDhhmmss
   ulAtc                终端交易流水号, 1-999999
   ucTransType          交易类型, 0x00 - 0xFF (PBOC规定的交易类型)
   Amount               交易金额，单位：分
   timeout              等卡+操作的总超时时间
 */
-(void)InitBankIcCardTrans:(NSString*)dateTime
                       Atc:(long)ulAtc
                 TransType:(Byte)ucTransType
                    Amount:(NSString*)pszAmount
                   Timeout:(NSInteger)timeout;


//完成交易，结果通过（DelegateFinishBankIcCardTrans:outData:error:）返回
//参数： TLV格式的指令
-(void)FinishBankIcCardTrans:(NSString *)inTlvData;


//读取IC卡的55域信息等
//此方法只是封装了 【初始化核心】和 【开始交易】，并默认设置入口参数，比如交易类型设置为 0x00。
//此方法返回的数据通过 （DelegateInitBankIcCardTrans:cardInfo:error:）返回
-(void)readBankIcField55:(NSInteger)timeout;



+ (NSData *)twoOneData:(NSString *)sourceString;

+ (NSString *)oneTwoData:(NSData *)sourceData;

+(NSData *)twoOneWith3xData:(NSData *)_3xData;

+(NSData *)oneTwo3xData:(NSData *)sourceData;

+(NSString *)oneTwo3xString:(NSData *)sourceData;

+(NSData *)BytesData:(NSData *)bytesData1 XOR:(NSData *)bytesData2;

+(Byte) XOR:(NSData *)sourceData;

+ (NSData *)Raw2Bmp:(NSData *)pRawData X:(int)x Y:(int)y;

+(NSString *)threeDES:(NSString *)key EncodeData:(NSData*)data;


@end
