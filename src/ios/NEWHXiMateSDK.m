/********* NEWHXiMateSDK.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <HXiMateSDK/iMateAppFace.h>
#import <HXiMateSDK/iMateAppFace+Pinpad.h>
#import <HXiMateSDK/iMateAppFace+Fingerprint.h>
#import <HXiMateSDK/iMateAppFace+Pboc.h>
#import <HXiMateSDK/PbocHigh.h>

@interface NEWHXiMateSDK: CDVPlugin {
  // Member variables go here.
    int PluginReadmode;
    int g_FeatureDataType;
    int g_FingerprintModel;
    int currentType;
}

- (void)OpenBluetoothSocket:(CDVInvokedUrlCommand*)command;
- (void)CloseBluetoothSocket:(CDVInvokedUrlCommand*)command;

@end


@interface NEWHXiMateSDK() <iMateAppFaceDelegate>

@property (strong, nonatomic) NSString* callbackId;
@property (strong, nonatomic) NSString* BLEcallbackId;
@property (strong, nonatomic) iMateAppFace *imateFace;

@end

@implementation NEWHXiMateSDK

-(void)pluginInitialize{
    _imateFace = [iMateAppFace sharedController];
    _imateFace.delegate = self;
    PluginReadmode = 0;
    currentType = -99;
}


- (void)OpenBluetoothSocket:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if ([_imateFace openSession]) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }else
    {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
    }
    return;
}

- (void)CloseBluetoothSocket:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    [_imateFace closeSession];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
    return;
}

- (void)startSearchBLE:(CDVInvokedUrlCommand*)command
{
    _BLEcallbackId = command.callbackId;
    [_imateFace startSearchBLE];
    return;
}

-(void)stopSearchBLE:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    [_imateFace stopSearchBLE];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
}

-(void)bindDevice:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        NSString *name = [dict objectForKey:@"deviceName"];
        if ((id)name == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置deviceName参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        [_imateFace bindingDevice:name];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"{\"result\":\"ok\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)getDeviceInfo:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }

    NSString *SerialNumber = [_imateFace deviceSerialNumber];
    NSString *termID = [_imateFace deviceTerminalId];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"{\"DeviceSN\":\"%@\",\"termID\":\"%@\"}",SerialNumber,termID]];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
}

-(void)subDeviceTest:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }

    [_imateFace deviceTest:0xFF];
    return;
}


-(void)cancel:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    [_imateFace cancel];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
    return;
}


-(void)buzzer:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    [_imateFace buzzer];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
    return;
}


-(void)isConnectTest:(CDVInvokedUrlCommand*)command
{
    if(![_imateFace connectingTest]){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"未连接"];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"已连接"];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)waitAllCard:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }

    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id timeout = [dict objectForKey:@"timeout"];
        if (timeout == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置timeout参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        [_imateFace waitEvent:0xFF timeout:[timeout intValue]];

    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)readID:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id timeout = [dict objectForKey:@"timeout"];
        if (timeout == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置timeout参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        [_imateFace idReadMessage:[timeout intValue]];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)readMsgCard:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id timeout = [dict objectForKey:@"timeout"];
        if (timeout == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置timeout参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        [_imateFace swipeCard:[timeout intValue]];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}



-(void)readICCard:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id timeout = [dict objectForKey:@"timeout"];
        if (timeout == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置timeout参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        PluginReadmode = 0;
        [_imateFace icResetCard:0 tag:0 timeout:[timeout intValue]];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}


-(void)readRFCard:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id timeout = [dict objectForKey:@"timeout"];
        if (timeout == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置timeout参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        PluginReadmode = 0;
        [_imateFace icResetCard:1 tag:1 timeout:[timeout intValue]];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}



-(void)readICCardField55:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id timeout = [dict objectForKey:@"timeout"];
        if (timeout == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置timeout参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id slot = [dict objectForKey:@"slot"];
        if (slot == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置slot参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        PluginReadmode = 1;
        [_imateFace icResetCard:[slot intValue] tag:[slot intValue] timeout:[timeout intValue]];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)verifyARPC_RunScript:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        NSString *script = [dict objectForKey:@"script"];
        if (script == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置script参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            char szOutFiled55[513];
            char* pszIssuerData = (char*)[script cStringUsingEncoding:NSASCIIStringEncoding];
            int ret = iHxPbocHighDoTrans(pszIssuerData, szOutFiled55);
            if (ret!=0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@[%d]",[self getErrorMessage:ret],ret]]];
                    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
                });
                return;
            
            }else if(ret==0){
                
                NSString *str = [NSString stringWithFormat:@"%s",szOutFiled55];
                dispatch_async(dispatch_get_main_queue(), ^{
                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"{\"newField55\":\"%@\"}",str]];
                    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
                });
                return;
            }
        });
        
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}


-(void)getFingerprintFeature:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id FingerprintModel = [dict objectForKey:@"FingerprintModel"];
        if (FingerprintModel == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置FingerprintModel参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id FeatureDataType = [dict objectForKey:@"FeatureDataType"];
        if (FeatureDataType == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置FeatureDataType参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        g_FeatureDataType = [FeatureDataType intValue];
        g_FingerprintModel = [FingerprintModel intValue];
        //设置指纹仪厂商
        [_imateFace fingerprintSetModel:[FingerprintModel intValue]];
        //指纹仪上电
        [_imateFace fingerprintPowerOn];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}


-(void)FingerPrint_Cancel:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    [_imateFace fingerprintCancel];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return;
}

#pragma mark - 密码键盘相关
-(void)Pinpad_setPinpadModel:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id PinpadModel = [dict objectForKey:@"PinpadModel"];
        if (PinpadModel == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置PinpadModel参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        
        //设置密码键盘厂商
        int type = [PinpadModel intValue];
        if (type!=currentType) {
            currentType = type;
            [_imateFace pinpadSetModel:type];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
        
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)Pinpad_PowerOn:(CDVInvokedUrlCommand*)command{
    
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    [_imateFace pinPadPowerOn];
}

-(void)Pinpad_PowerOff:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    [_imateFace pinPadPowerOff];
}


-(void)Pinpad_Cancel:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    [_imateFace pinPadCancel];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return;
    
}

-(void)Pinpad_getSerialNo:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    [_imateFace pinPadGetProductSN];
}


-(void)Pinpad_DownloadMasterKey:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id algorithm = [dict objectForKey:@"algorithm"];
        if (algorithm == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置algorithm参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id masterIndex = [dict objectForKey:@"masterIndex"];
        if (masterIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置masterIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        NSString* masterKey = [dict objectForKey:@"masterKey"];
        if (masterKey == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置masterKey参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        
        [_imateFace pinPadDownloadMasterKey:[algorithm intValue] index:[masterIndex intValue] masterKey:(Byte *)[[iMateAppFace twoOneData:masterKey] bytes] keyLength:masterKey.length / 2];
        
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}


-(void)Pinpad_UpdateMasterKey:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id algorithm = [dict objectForKey:@"algorithm"];
        if (algorithm == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置algorithm参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id masterIndex = [dict objectForKey:@"masterIndex"];
        if (masterIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置masterIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        NSString* masterKey = [dict objectForKey:@"masterKey"];
        if (masterKey == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置masterKey参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        
        [_imateFace pinPadUpdateMasterKey:[algorithm intValue] index:[masterIndex intValue] masterKey:(Byte *)[[iMateAppFace twoOneData:masterKey] bytes] keyLength:masterKey.length / 2];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)Pinpad_DownloadWorkingKey:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id algorithm = [dict objectForKey:@"algorithm"];
        if (algorithm == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置algorithm参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id masterIndex = [dict objectForKey:@"masterIndex"];
        if (masterIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置masterIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id workingIndex = [dict objectForKey:@"workingIndex"];
        if (workingIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置workingIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        NSString* workingKey = [dict objectForKey:@"workingKey"];
        if (workingKey == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置workingKey参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        
        [_imateFace pinPadDownloadWorkingKey:[algorithm intValue] masterIndex:[masterIndex intValue] workingIndex:[workingIndex intValue] workingKey:(Byte *)[[iMateAppFace twoOneData:workingKey] bytes] keyLength:workingKey.length / 2];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}


-(void)Pinpad_DownloadMACKey:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id algorithm = [dict objectForKey:@"algorithm"];
        if (algorithm == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置algorithm参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id masterIndex = [dict objectForKey:@"masterIndex"];
        if (masterIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置masterIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id MackeyIndex = [dict objectForKey:@"MackeyIndex"];
        if (MackeyIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置MackeyIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        NSString* MacKey = [dict objectForKey:@"MacKey"];
        if (MacKey == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置MacKey参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        
        [_imateFace pinPadDownloadWorkingKey:[algorithm intValue] masterIndex:[masterIndex intValue] workingIndex:0-[MackeyIndex intValue] workingKey:(Byte *)[[iMateAppFace twoOneData:MacKey] bytes] keyLength:MacKey.length / 2];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)Pinpad_getPin:(CDVInvokedUrlCommand*)command{
    
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id algorithm = [dict objectForKey:@"algorithm"];
        if (algorithm == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置algorithm参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id masterIndex = [dict objectForKey:@"masterIndex"];
        if (masterIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置masterIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id workingIndex = [dict objectForKey:@"workingIndex"];
        if (workingIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置workingIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id timeout = [dict objectForKey:@"timeout"];
        if (timeout == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置timeout参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id pinLength = [dict objectForKey:@"pinLength"];
        if (pinLength == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置pinLength参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        
        NSString* cardNo = [dict objectForKey:@"cardNo"];
        if (cardNo == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置cardNo参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        
        [_imateFace pinPadInputPinblock:[algorithm intValue] isAutoReturn:NO masterIndex:[masterIndex intValue] workingIndex:[workingIndex intValue] cardNo:cardNo pinLength:[pinLength intValue] timeout:[timeout intValue]];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
    
}


-(void)Pinpad_getPlainPin:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id timeout = [dict objectForKey:@"timeout"];
        if (timeout == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置timeout参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id pinLength = [dict objectForKey:@"pinLength"];
        if (pinLength == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置pinLength参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        [_imateFace pinPadInputPlainPin:@"请输入密码:" pinLength:[pinLength intValue] timeout:[timeout intValue]];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)Pinpad_Encrypt:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id algorithm = [dict objectForKey:@"algorithm"];
        if (algorithm == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置algorithm参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id masterIndex = [dict objectForKey:@"masterIndex"];
        if (masterIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置masterIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id workingIndex = [dict objectForKey:@"workingIndex"];
        if (workingIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置workingIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id cryptoMode = [dict objectForKey:@"cryptoMode"];
        if (cryptoMode == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置cryptoMode参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        NSString* data = [dict objectForKey:@"data"];//hexstring格式的字符串
        if (data == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置data参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }

        [_imateFace pinPadEncrypt:[algorithm intValue] cryptoMode:[cryptoMode intValue] masterIndex:[masterIndex intValue] workingIndex:[workingIndex intValue] data:(Byte *)[[iMateAppFace twoOneData:data] bytes] dataLength:data.length/2];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}

-(void)Pinpad_Mac:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    if(![self isReachable:_callbackId]){
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionary];
    if([[command.arguments objectAtIndex:0] isKindOfClass:[NSDictionary class]]){
        dict = [command.arguments objectAtIndex:0];
        id algorithm = [dict objectForKey:@"algorithm"];
        if (algorithm == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置algorithm参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id masterIndex = [dict objectForKey:@"masterIndex"];
        if (masterIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置masterIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        id macIndex = [dict objectForKey:@"macIndex"];
        if (macIndex == [NSNull null]) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置macIndex参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
        
        NSString* data = [dict objectForKey:@"data"];//hexstring格式的字符串
        if (data == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未设置data参数\"}"]];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }

        [_imateFace pinPadMac:[algorithm intValue] masterIndex:[masterIndex intValue] workingIndex:[macIndex intValue] data:(Byte *)[[iMateAppFace twoOneData:data] bytes] dataLength:data.length/2];
        
    }else{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"参数错误\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }
}




#pragma mark - 检查是否设备可用
-(BOOL)isReachable:(NSString*)callbackID
{
    //检查连接状态
    if(![_imateFace connectingTest]){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"未连接iMate设备!\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:callbackID];
        return NO;
    }
    
    //检查工作状态
    if([_imateFace isWorking])
    {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"设备正在忙,稍后重试或者取消之前的操作\"}"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:callbackID];
        return NO;
    }
    return YES;
}

- (void)getDateTime:(char *)dateTime
{
    time_t t;
    struct tm tm;
    
    t = time( NULL );
    memcpy(&tm, localtime(&t), sizeof(struct tm));
    sprintf(dateTime, "%04d%02d%02d%02d%02d%02d",
            tm.tm_year+1900, tm.tm_mon+1, tm.tm_mday,
            tm.tm_hour, tm.tm_min, tm.tm_sec);
}

-(NSString *)getErrorMessage:(int)ErrorCode
{
    NSString *message;
    switch (ErrorCode) {
        case 1:
            message = @"参数错误";
            break;
        case 2:
            message = @"无卡";
            break;
        case 3:
            message = @"无支持的应用";
            break;
        case 4:
            message = @"卡操作错";
            break;
        case 5:
            message = @"非法卡指令状态字";
            break;
        case 6:
            message = @"交易被拒绝";
            break;
        case 7:
            message = @"交易被终止";
            break;
        default:
            message = @"其它错误";
            break;
    }
    return message;
}


#pragma mark -
#pragma mark iMateAppFaceDelegate

//新版SDK使用,startSearchBLE的回调结果
- (void)iMateDelegateFoundAvailableDevice:(NSString *)deviceName
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"{\"deviceName\":\"%@\"}",deviceName]];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_BLEcallbackId];
}

- (void)iMateDelegateConnectStatus:(BOOL)isConnecting
{
    NSLog(@"%@", [NSString stringWithFormat:@"设备连接状态:%@",isConnecting==YES?@"已连接":@"已断开"]);
}

// iMate请求超时或无法执行时，该方法被调用，通知出错信息
- (void)iMateDelegateNoResponse:(NSString *)error
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"%@\"}",error]];
    
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
    return;
}


- (void)iMateDelegateResponsePackError
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{\"ErrorMsg\":\"iMate响应报文格式错误\"}"]];
    [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
    return;
}

- (void)iMateDelegateDeviceTest:(NSInteger)returnCode
                     resultMask:(Byte)resultMask
                          error:(NSString *)error
{
    if (returnCode!=0) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",error]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        
    }else{
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"子部件全部正常"]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
    }
    return;
}

- (void)iMateDelegateWaitEvent:(NSInteger)returnCode
                       eventId:(NSInteger)eventId
                          data:(NSData *)data
                         error:(NSString *)error
{
    if (returnCode!=0) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",error]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        
    }else{
        
        if (eventId== 1) {
            Byte track2[37+1],track3[104+1];
            memset(track2, 0 ,sizeof(track2));
            memset(track3, 0 ,sizeof(track3));
            
            [data getBytes:track2 range:(NSRange){1,37}];
            [data getBytes:track3 range:(NSRange){38,104}];
            
            NSString *track2str = [NSString stringWithUTF8String:(char*)track2];
            NSString *track3str = [NSString stringWithUTF8String:(char*)track3];
            NSArray *aArray = [track2str componentsSeparatedByString:@"="];
            NSString * reslut = [NSString stringWithFormat:@"{\"Event\":\"磁条卡\",\"track2\":\"%@\",\"track3\":\"%@\",\"cardNo\":\"%@\"}",track2str,track3str,aArray[0]];
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:reslut];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
            
        }else if (eventId == 2){
            
            int length = data.length -1;
            Byte ATR[length];
            [data getBytes:ATR range:(NSRange){1,length}];
            
            NSString * reslut = [NSString stringWithFormat:@"{\"Event\":\"IC卡\",\"ATR\":\"%@\"}",[iMateAppFace oneTwoData:[NSData dataWithBytes:ATR length:length]]];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:reslut];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
            
        }else if (eventId == 4){
            
            int length = data.length -1;
            Byte ATR[length];
            [data getBytes:ATR range:(NSRange){1,length}];
            
            NSString * reslut = [NSString stringWithFormat:@"{\"Event\":\"射频卡\",\"ATR\":\"%@\"}",[iMateAppFace oneTwoData:[NSData dataWithBytes:ATR length:length]]];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:reslut];
            [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
    }
}

- (void)iMateDelegateIDReadMessage:(NSInteger)returnCode
                       information:(NSData *)information
                             photo:(NSData*)photo
                             error:(NSString *)error
{
    if (returnCode!=0) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",error]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        
    }else{
    
        NSArray *idInfos = [iMateAppFace processIdCardInfo:information];
        UIImage *image = [iMateAppFace processIdCardPhoto:photo];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        NSString *birthday = [NSString stringWithFormat:@"%@.%@.%@",[idInfos objectAtIndex:3],[idInfos objectAtIndex:4],[idInfos objectAtIndex:5]];
        
        
        CDVPluginResult* pluginResult = nil;
        if (idInfos) {
            NSString *echo;
            if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
                echo = [NSString stringWithFormat:@"{\"name\":\"%@\",\"sex\":\"%@\",\"nation\":\"%@\",\"birthday\":\"%@\",\"address\":\"%@\",\"idNumber\":\"%@\",\"issuser\":\"%@\",\"validdate\":\"%@\", \"photoBase64Data\":\"%@\"}",[idInfos objectAtIndex:0],[idInfos objectAtIndex:1],[idInfos objectAtIndex:2],birthday,[idInfos objectAtIndex:6],[idInfos objectAtIndex:7],[idInfos objectAtIndex:8],[idInfos objectAtIndex:9],[imageData base64EncodedStringWithOptions:0]];
            }
            else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
                echo = [NSString stringWithFormat:@"{\"name\":\"%@\",\"sex\":\"%@\",\"nation\":\"%@\",\"birthday\":\"%@\",\"address\":\"%@\",\"idNumber\":\"%@\",\"issuser\":\"%@\",\"validdate\":\"%@\", \"photoBase64Data\":\"%@\"}",[idInfos objectAtIndex:0],[idInfos objectAtIndex:1],[idInfos objectAtIndex:2],birthday,[idInfos objectAtIndex:6],[idInfos objectAtIndex:7],[idInfos objectAtIndex:8],[idInfos objectAtIndex:9],[imageData base64Encoding]];
#pragma clang diagnostic pop
            }
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
        }else{
            NSString *echo = [NSString stringWithFormat:@"%@", error];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:echo];
        }
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        
    }
}


// 刷卡操作执行结束后，该方法被调用，返回结果
- (void)iMateDelegateSwipeCard:(NSInteger)returnCode
                        track2:(NSString*)track2
                        track3:(NSString *)track3
                         error:(NSString *)error
{
    if (returnCode!=0) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",error]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        
    }else{
    
        NSString *subStr = @"";
        if(track2 != nil && [track2 length] != 0){
            NSRange range = [track2 rangeOfString:@"="];
            if(range.location != NSNotFound){
                subStr = [track2 substringToIndex:range.location];
                if(subStr.length == 21 || subStr.length == 18){
                    subStr = [subStr substringFromIndex:2];
                }
            }else{
                subStr = track2;
            }
        }else{
            NSRange range = [track3 rangeOfString:@"="];
            if(range.location != NSNotFound){
                subStr = [track3 substringToIndex:range.location];
                if(subStr.length == 21 || subStr.length == 18){
                    subStr = [subStr  substringFromIndex:2];
                }
            }else{
                subStr = track3;
            }
        }
        
        NSString* echo = [NSString stringWithFormat:@"{\"cardNo\":\"%@\",\"track2\":\"%@\",\"track3\":\"%@\"}",subStr,track2,track3];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
    }
}

// IC卡复位操作执行结束后，该方法被调用，返回结果
- (void)iMateDelegateICResetCard:(NSInteger)returnCode
                       resetData:(NSData *)resetData
                             tag:(NSInteger)tag
                           error:(NSString *)error{
    if (returnCode!=0) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",error]];
        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
        
    }else{
        
        if(tag==0)
            [_imateFace pbocIcCardReaderType:0];
        else
            [_imateFace pbocIcCardReaderType:1];
        
        iHxPbocHighInitCore("123456789000001", "12345601", "building 212", 156, 156);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                char szDateTime[15]; //交易日期时间，格式YYYYMMDDHHMMSS
                char szField55[513]; //55域缓冲
                char szPan[20], szTrack2[40];
                int  iPanSeqNo;
                unsigned long ulAtc;
                char szExtInfo[513];
                
                // 显示开始读卡时间，包括毫秒
                // 产生当前交易的日期时间
                [self getDateTime:szDateTime];
                ulAtc = 1; //ulAtc终端交易流水号, 1-999999, 每次交易都要加一
                
                int ret = iHxPbocHighInitTrans(szDateTime, ulAtc, 0x30, (unsigned char *)"0",szField55, szPan, &iPanSeqNo, szTrack2, szExtInfo);
                
                if (ret == 0) {
                    // 姓名可能使用GBK编码，试用以下编码转换
                    NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    NSString *GBK_extInfo = [NSString stringWithCString:(const char*)szExtInfo encoding:enc];
                    
                    NSArray *strArray = [[NSString stringWithFormat:@"%@",GBK_extInfo] componentsSeparatedByString:@","];
                    NSString *holderName = strArray[0];
                    NSString *holderID = strArray[2];
                    NSString *validDate = strArray[3];
                    NSString *Pan = [NSString stringWithFormat:@"%s",szPan];
                    NSString *PanSeqNo = [NSString stringWithFormat:@"%03d",iPanSeqNo];
                    NSString *Track2 = [NSString stringWithFormat:@"%s",szTrack2];
                    
                    
                    NSString *echo;
                    if (PluginReadmode==0) {
                        echo = [NSString stringWithFormat:@"{\"holderName\":\"%@\",\"PanSN\":\"%@\",\"expireDate\":\"%@\",\"cardNo\":\"%@\",\"holderID\":\"%@\",\"track2\":\"%@\"}",holderName,PanSeqNo,validDate,Pan,holderID,Track2];
                    }else if(PluginReadmode==1){
                        echo = [NSString stringWithFormat:@"{\"field55\":\"%s\",\"holderName\":\"%@\",\"PanSN\":\"%@\",\"extInfo\":\"%@\",\"cardNo\":\"%@\",\"track2\":\"%@\"}",szField55,holderName,PanSeqNo,GBK_extInfo,Pan,Track2];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
                        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
                    });
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@[%d]",[self getErrorMessage:ret],ret]]];
                        [self.commandDelegate  sendPluginResult:pluginResult callbackId:_callbackId];
                    });
                }
            }
        });
    }
}


#pragma mark FingerPrint delegate
- (void)fingerprintDelegateResponse:(NSInteger)returnCode  requestType:(FingerprintRequestType)type responseData:(NSData *)responseData error:(NSString *)error
{
    NSString *str;
    NSString *requestStr;
    
    if(type==FingerprintRequestTypePowerOn)
        requestStr = @"指纹仪上电";
    else if(type==FingerprintRequestTypePowerOff)
        requestStr = @"指纹仪下电";
    else if(type==FingerprintRequestTypeVersion)
        requestStr = @"读取指纹仪版本";
    else if(type==FingerprintRequestTypeFeature)
        requestStr = @"获取指纹特征";
    
    if ( returnCode ) {
        str = [NSString stringWithFormat:@"%@,返回码:%d,错误信息:%@",requestStr, (int)returnCode, error];
        //失败回调
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:str];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
        return;
        
    }else{
        if (type == FingerprintRequestTypePowerOn) {
            //上电之后去指纹特征
            
            [_imateFace fingerprintVersion];
        }else if(type == FingerprintRequestTypeVersion){
            [_imateFace fingerprintFeature];
        }else if (type == FingerprintRequestTypeFeature)
        {
            if (responseData)
            {
                //  成功回调
                NSString *responStr;
                if(g_FingerprintModel==0){//维尔指纹仪不支持输出格式
                     responStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                }else{//其他指纹仪
                
                    if(g_FeatureDataType==0){ //hexString
                        responStr = [iMateAppFace oneTwoData:responseData];
                    }else if(g_FeatureDataType==1){//3x格式
                        responStr = [iMateAppFace oneTwo3xString:responseData];
                    }else if(g_FeatureDataType==2){//base64格式
                        
                        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
                            responStr = [responseData base64EncodedStringWithOptions:0];
                        }
                        else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
                            responStr = [responseData base64Encoding];
#pragma clang diagnostic pop
                        }
                    }
                }
                
                NSString *FeatureStr = [NSString stringWithFormat:@"{\"FingerprintData\":\"%@\"}", responStr];
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:FeatureStr];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
                return;
                
            }else{
                //  失败回调
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取指纹特征值为空"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
                return;
            }
        }
    }
}

#pragma mark PinPad delegate
- (void)pinPadDelegateResponse:(NSInteger)returnCode  requestType:(PinPadRequestType)type responseData:(NSData *)responseData error:(NSString *)error
{
    NSString *requestStr;
    switch (type) {
        case PinPadRequestTypePowerOn:
            requestStr = @"密码键盘打开失败";
            break;
        case PinPadRequestTypeReset:
            requestStr = @"密码键盘复位自检失败";
            break;
        case PinPadRequestTypeDownloadMasterKey:
            requestStr = @"密码键盘下载主密钥失败";
            break;
        case PinPadRequestTypeDownloadWorkingKey:
            requestStr = @"密码键盘下载工作密钥失败";
            break;
        case PinPadRequestTypeInputPinBlock:
            requestStr = @"输入密码失败";
            break;
        case PinPadRequestTypeEncrypt:
            requestStr = @"密码键盘加解密失败";
            break;
        case PinPadRequestTypeMac:
            requestStr = @"密码键盘算MAC失败";
            break;
        case PinPadRequestTypeVersion:
            requestStr = @"密码键盘版本号错误";
            break;
        case PinPadRequestTypeUpdateMasterKey:
            requestStr = @"更新主密钥失败";
            break;
        case PinPadRequestTypeInputPlainPin:
            requestStr = @"获取明文密码失败";
            break;
        case PinPadRequestTypeSN:
            requestStr = @"获取序列号失败";
            break;
        default:
            requestStr = @"";
            break;
    }
    
    
    if(returnCode!=0){
        NSString *str = [NSString stringWithFormat:@"%@，返回码:%d，错误信息:%@",requestStr, returnCode, error];
        //失败回调
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:str];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
        });
//        [_imateFace pinPadPowerOff];
        return;
    }
    
    if (type==PinPadRequestTypeSN ||
        type==PinPadRequestTypeInputPinBlock ||
        type==PinPadRequestTypeMac ||
        type==PinPadRequestTypeHash ||
        type==PinPadRequestTypeInputPlainPin ||
        type==PinPadRequestTypeEncrypt ||
        type==PinPadRequestTypeVersion) {
        
        if (responseData==nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"返回数据为空"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
            return;
        }
    }
    
    //成功回调
    CDVPluginResult* pluginResult;
    NSString *message;
    if(type == PinPadRequestTypePowerOn){
        sleep(1);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }else if(type == PinPadRequestTypePowerOff ||
             type == PinPadRequestTypeDownloadMasterKey ||
             type==PinPadRequestTypeUpdateMasterKey ||
             type==PinPadRequestTypeDownloadWorkingKey){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
        return;
    }else if(type == PinPadRequestTypeSN){
        message = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    }else if(type == PinPadRequestTypeInputPinBlock){
        NSString *pinblock =[iMateAppFace oneTwoData:responseData];
        message = [NSString stringWithFormat:@"{\"Pin\":\"%@\"}", pinblock];
    }else if(type == PinPadRequestTypeInputPlainPin){
        NSString *pinPlain =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        message = [NSString stringWithFormat:@"{\"PlainPin\":\"%@\"}", pinPlain];
    }else if(type == PinPadRequestTypeEncrypt){
        NSString *Endata =[iMateAppFace oneTwoData:responseData];
        message = [NSString stringWithFormat:@"{\"outData\":\"%@\"}", Endata];
    }else if(type == PinPadRequestTypeMac){
        NSString *Macdata =[iMateAppFace oneTwoData:responseData];
        message = [NSString stringWithFormat:@"{\"outData\":\"%@\"}", Macdata];
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_callbackId];
    return;
}

@end
