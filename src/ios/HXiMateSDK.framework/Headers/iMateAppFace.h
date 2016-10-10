//
//  iMateAppFace.h
//
//  Created by Qingbo Jia on 12-10-17.
//  Copyright (c) 2012年 HxSmart Co, Shenzhen. All rights reserved.
//

/*
 HXiMateSDK使用说明：
 1、初始化(必须）
 在AppDelegate中添加以下代码，用于初始化iMateFaceApp实例，并建立连接Session，改段代码需要添加在didFinishLaunchingWithOptions的顶部。
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
    iMateAppFace *iMateFace = [iMateAppFace sharedController];
    [iMateFace openSession];
    ...
 
 2、进入后台时关闭Session(必须）
 在AppDelegate中添加以下代码，该段代码需要添加到applicationDidEnterBackground的底部位置。
 - (void)applicationDidEnterBackground:(UIApplication *)application
 {
    ...
 
 [[iMateAppFace sharedController] closeSession];
 
 3、App从后台进入前台之前，重新建立Session(必须）
 在AppDelegate中添加以下代码，该段代码需要添加到applicationDidEnterBackground的顶部位置。
 - (void)applicationWillEnterForeground:(UIApplication *)application
 {
    [[iMateAppFace sharedController] openSession];
    ...
 
 4、UI View中使用iMateFaceApp
 a) 在viewWillAppear中添加以下代码，来获取iMateAppFace的指针以及设置delegate。（必须）, 检查session是否正常。（可选）
 - (void)viewWillAppear:(BOOL)animated
 {
    [super viewWillAppear:animated];
 
 //获取iMateAppFace的实例, 该步骤也可以放在viewDidLoad中做
 _imateAppFace = [iMateAppFace sharedController];
 
 //如果使用delegate协议，需要将delegate设置为self，必须在进入view之前设置。 （重要!!）
 _imateAppFace.delegate = self;
 
 if ( ![_imateAppFace connectingTest] ) {
    NSLog(@"iMate未连接!");
    return;
 }
 NSLog(@"iMate已连接!");
 ...
 b) 在viewWillDisappear中添加以下代码，来取消尚未响应上次请求。（可选）
 - (void)viewWillDisappear:(BOOL)animated
 {
    [_imateAppFace cancel];
 
    [super viewWillDisappear:animated];
    ...
 
 c) 在UI View中实现iMateAppFae的delegate，并调用相关接口。（略）
 
 5、关于在App使用过程中重新关闭和打开iMate
 如果在App使用过程中，iMate关闭电源，iMateAppFace将通过iMateDelegateConnectStatus通知session的状态。
 重新打开iMate后，iMateAppFace又将通过iMateDelegateConnectStatus通知session的状态。
 以上两个过程中，App的用户代码不需要做任何操作，iMateAppFace将自动重新建立或关闭session。
 
 ********2016.4.1 新增蓝牙4.0设备的支持**********************
 6、如果使用iMate401等蓝牙4.0的设备，不需要与iPad对码就可以使用，需要通过bindingDevice方法绑定一个iMate设备，如果没有绑定，无法使用该iMate设备；
 7、对于SDK所支持的蓝牙4.0设备，提供搜索功能，具体请参考 startSearchBLE 和 stopSearchBLE 方法。
 8、使用M35或天喻的蓝牙4.0密码键盘，设备搜索、绑定与蓝牙4.0的iMate一样用法。如果未绑定，则自动连接一个可用的设备。
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 打印机状态
#define PRINTER_OK                      0
#define PRINTER_CONNECTED               1
#define PRINTER_NOT_CONNECTED           2
#define PRINTER_OUT_OF_PAPER            3
#define PRINTER_OFFLINE                 4
#define PRINTER_NOT_SUPPORT             5

@protocol iMateAppFaceDelegate <NSObject>

@optional

// 对蓝牙4.0的iMate设备(例如，iMate401)提供搜索结果通知，不支持通过蓝牙对码的iMate设备（例如，iMate101）
// 当openSession时, 如果未绑定设备(仅蓝牙4.0 iMate设备)，将自动查找支持的设备，查找到设备后，返回设备蓝牙名称
// 如果调用startSearchBLE，搜索到的设备将通过该delegate通知
- (void)iMateDelegateFoundAvailableDevice:(NSString *)deviceName;

// 当iMate蓝牙连接连通或者中断时，该方法被调用，通知目前的蓝牙连接状态
- (void)iMateDelegateConnectStatus:(BOOL)isConnecting;

// iMate请求超时或无法执行时，该方法被调用，通知出错信息
- (void)iMateDelegateNoResponse:(NSString *)error;

// iMate响应报文格式错误，该方法被调用
- (void)iMateDelegateResponsePackError;

// 部件检测执行结束后，该方法被调用，返回结果
// 如果returnCode不为0，error有错误信息
// resultMask：
//      0x00   所检测的部件全部正常
//      其它    依照resultMask的bit位标识对应的部件，参考deviceTest的componentsMask
- (void)iMateDelegateDeviceTest:(NSInteger)returnCode
                        resultMask:(Byte)resultMask
                         error:(NSString *)error;

// 等待事件结束后，该方法被调用，返回结果
// 如果returnCode不为0，error有错误信息
// eventId ：1检测到刷卡；2检测到IC卡；4检测到射频卡
// data    ：刷卡时返回二磁道、三磁道数据；IC返回复位数据；射频卡返回4字节的序列号
- (void)iMateDelegateWaitEvent:(NSInteger)returnCode
                       eventId:(NSInteger)eventId
                          data:(NSData *)data
                         error:(NSString *)error;

// 刷卡操作执行结束后，该方法被调用，返回结果
- (void)iMateDelegateSwipeCard:(NSInteger)returnCode
                        track2:(NSString*)track2
                        track3:(NSString *)track3
                         error:(NSString *)error;

// IC卡复位操作执行结束后，该方法被调用，返回结果
- (void)iMateDelegateICResetCard:(NSInteger)returnCode
                       resetData:(NSData *)resetData
                             tag:(NSInteger)tag
                           error:(NSString *)error;

// IC卡APDU操作执行结束后，该方法被调用，返回结果
- (void)iMateDelegateICApdu:(NSInteger)returnCode
               responseApdu:(NSData*)responseApdu
                      error:(NSString *)error;

// 读身份证操作执行结束后，该方法被调用，返回结果。可调用processIdCardInfo对information拆分成数组
- (void)iMateDelegateIDReadMessage:(NSInteger)returnCode
                       information:(NSData *)information
                             photo:(NSData*)photo
                             error:(NSString *)error;

// 获取电池电量操作执行结束后，该方法被调用，返回结果，level取值在0-100之间
- (void)iMateDelegateBatteryLevel:(NSInteger)returnCode
                            level:(NSInteger)level
                            error:(NSString *)error;

// 读取扩展内存操作执行结束后，该方法被调用，返回结果
- (void)iMateDelegateXmemRead:(NSInteger)returnCode
                         data:(NSData *)data
                        error:(NSString *)error;

// 写扩展内存操作执行结束后，该方法被调用，返回结果
- (void)iMateDelegateXmemWrite:(NSInteger)returnCode
                         error:(NSString *)error;

// 当openSession时, imate设备连接上后将自动查找支持的设备，查找到设备后，通过该delegate返回设备名称和CBUUID
- (void)MPOSDelegateFoundAvailableDevice:(NSString *)deviceName DeviceCBUUID:(NSString*)CBUUID;


// 写设备终端号操作执行结束后，该方法被调用，返回结果, returnCode == 0 成功
- (void)iMateDelegateWriteDeviceTerminalId:(NSInteger)returnCode
                         error:(NSString *)error;

/*
 打印机有关Delegate
 */
// 当打印机蓝牙连接连通或者中断时，该方法被调用，通知目前的蓝牙连接状态
- (void)printerDelegateStatusResponse:(NSInteger)status;

@end

@interface iMateAppFace : NSObject

@property (assign, nonatomic) id<iMateAppFaceDelegate> delegate;

// 获取iMateFace实例
+ (iMateAppFace *)sharedController;

// 该方法对身份证信息进行拆分
+ (NSArray *)processIdCardInfo:(NSData *)information;

// 该方法对身份证照片数据进行解码
+ (UIImage *)processIdCardPhoto:(NSData *)photoData;

// 对蓝牙4.0的iMate设备(例如，iMate401)提供设备绑定操作，蓝牙对码的iMate设备（例如，iMate101）无效
// 绑定查找到的蓝牙4.0 iMate设备, 只有绑定设备后，设备才可以正常连接; deviceName = nil则解除绑定
// 支持前缀部分匹配和完整的匹配方式, 例如@“iMate-”，即绑定所有以"iMate-"开头的设备
// 如果使用蓝牙4.0的iMate设备，该方法须在openSession之前调用
- (void)bindingDevice:(NSString *)deviceName;

// 开始搜索蓝牙4.0设备, 例如iMate401(含键盘)、联迪M35等使用蓝牙4.0通讯的设备(不需要对码)
// 该方法调用后，已经连接的4.0设备会暂时中断连接
// 搜索到的设备将通过 iMateDelegateFoundAvailableDevice 来通知结果
-(void)startSearchBLE;

// 停止搜索蓝牙4.0设备
-(void)stopSearchBLE;
//查询M35、36是否连接

// 重庆农商用到的接口
- (BOOL)M35ConnectingTest;
- (void)bindingDevice:(NSString *)deviceName DeviceCBUUID:(NSString*)CBUUID;

// 打开与iMate的连接会话，返回YES会话建立成功
// 在未与iMate建立蓝牙连接之前，如果搜索到蓝牙4.0的设备，例如iMate401,
// 将通过 iMateDelegateFoundAvailableDevice 通知搜索到设备的蓝牙名称
// 如果使用已经对码的非蓝牙2.0设备，将优先连接
- (BOOL)openSession;

// 关闭与iMate的连接会话
- (void)closeSession;

// 检测蓝牙连接是否正常，返回YES表示连接正常
- (BOOL)connectingTest;

// 检测iMate是否在工作状态，返回YES表示正在工作中。
- (BOOL)isWorking;

// iMate产品序列号
- (NSString *)deviceSerialNumber;

// 查询iMate固件版本号
// 返回：
// nil         : iMate不支持取版本或通讯错误
// "A.A,B.B.B" : 硬件和固件版本，其中A为硬件版本，B为固件版本
- (NSString *)deviceVersion;

// 读取iMate终端号
- (NSString *)deviceTerminalId;

// 写iMate终端号
- (void)writeDeviceTerminalId:(NSString *)terminalId;

// 部件检测。可检测的部件包括二代证模块，射频卡模块。（IMFC还包括指纹模块、SD模块）
// componentsMask的bit来标识检测的部件：
//      0x01 二代证模块
//      0x02 射频模块
//      0x40 IMFC 指纹模块（iMate不支持）
//      0x80 IMFC SD卡模块（iMate不支持）
//      0xFF 全部部件检测
// 检测的结果通过delegate响应
- (void)deviceTest:(Byte)componentsMask;

// 等待事件，包括磁卡刷卡、Pboc IC插入、放置射频卡。timeout是最长等待时间(秒)
// eventMask的bit来标识等待事件：
//      0x01    等待刷卡事件
//      0x02    等待插卡事件
//      0x04    等待射频事件
//      0xFF    等待所有事件
// 等待的结果通过delegate响应
- (void)waitEvent:(Byte)eventMask timeout:(NSInteger)timeout;

// 刷卡请求，timeout是刷卡的最长等待时间(秒)
- (void)swipeCard:(NSInteger)timeout;

// 等待IC插入，并对IC卡进行复位请求，结果通过delegate响应
// slot＝0为用户芯片插槽，slot=1为射频卡，slot>=4为SAM卡座,
// tag将被传递给iMateDelegateICResetCard，可做为后续执行操作的标示
// timeout为最长等待时间(秒)
- (void)icResetCard:(NSInteger)slot tag:(NSInteger)tag timeout:(NSInteger)timeout;

// 等待CPU IC插入，并对IC卡进行复位请求，如果检测到卡片，该方法有返回，否则一直等到超时
// slot＝0为用户芯片插槽，slot=1为射频卡，slot>=4为SAM卡座,
// timeout为最长等待时间(秒)
// 复位成功，返回复位数据，如果返回nil，则复位失败或超时, error有错误信息
- (NSData *)icResetCardSync:(NSInteger)slot timeout:(NSInteger)timeout error:(NSString *__autoreleasing *)error;

// CPU IC卡APDU操作请求，slot＝0为用户芯片插槽，slot=1为射频卡，slot>=4为SAM卡座
- (void)icApdu:(NSInteger)slot commandApdu:(NSData *)commandApdu;

// CPU IC卡APDU操作请求，slot＝0为用户芯片插槽，slot=1为射频卡，slot>=4为SAM卡座
// APDU操作成功，则返回响应数据，否则返回nil, error有错误信息
- (NSData *)icApduSync:(NSInteger)slot commandApdu:(NSData *)commandApdu error:(NSString *__autoreleasing *)error;

// 读二代身份证操作请求，timeout为身份证放到读卡位置的最长等待时间(秒)
- (void)idReadMessage:(NSInteger)timeout;

// 读取电池电量的操作请求
- (void)batteryLevel;

// 读取扩展内存的操作请求
- (void)xmemRead:(NSInteger)offset length:(NSInteger)length;

// 写扩展内存的操作请求
- (void)xmemWrite:(NSInteger)offset data:(NSData*)data;

// 中断操作，仅对swipeCard，icResetCard，idReadMessage操作有效
- (void)cancel;

// iMate蜂鸣响一声
- (void)buzzer;

/*
 打印机有关操作
 */
//查询打印机是否连接
- (BOOL)printerConnectingTest;

// 查询打印机状态, 打印机的状态通过Delegate获取
- (void)printerStatus;

// 打印数据，\n结束 自动选择连接的手柄尝试打印。
- (void)print:(NSString *)printString;

+ (NSData *)twoOneData:(NSString *)sourceString;

+ (NSString *)oneTwoData:(NSData *)sourceData;

+(NSData *)twoOneWith3xString:(NSString *)_3xString;

+(NSData *)twoOneWith3xData:(NSData *)_3xData;

+(NSData *)oneTwo3xData:(NSData *)sourceData;

+(NSString *)oneTwo3xString:(NSData *)sourceData;

+(NSData *)BytesData:(NSData *)bytesData1 XOR:(NSData *)bytesData2;

+(Byte) XOR:(NSData *)sourceData;

+ (NSData *)Raw2Bmp:(NSData *)pRawData X:(int)x Y:(int)y;

+(NSString *)threeDES:(NSString *)key EncodeData:(NSData*)data;

+(NSData*)getSHA1:(Byte*)bytes length:(int)iLength;

+ (NSData*)packMacData:(int)alg data:(Byte *)data dataLength:(int)dataLength;

@end
