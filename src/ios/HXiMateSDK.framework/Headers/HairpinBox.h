//
//  HairpinBox.h
//  HXiMateSDK
//
//  Created by zbh on 16/7/12.
//  Copyright © 2016年 hxsmart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iMateAppFace.h"

// Fingerprint操作类型枚举
typedef enum {
    HXCardBoxRequestTypePowerOn = 0,
    HXCardBoxRequestTypePowerOff,
    HXCardBoxRequestTypeVersion,
    HXCardBoxRequestTypeFeature,
    HXCardBoxRequestType256Feature,
    HXCardBoxRequestTypeUploadImage,
}HXCardBoxRequestType;


@protocol HXCardBoxDelegate <iMateAppFaceDelegate>
// HXCardBox 操作类型，以及返回数据处理
-(void)HXCardBoxDelegateResponse:(NSInteger)returnCode
                       requestType:(HXCardBoxRequestType)type
                      responseData:(NSData *)data
                             error:(NSString *)error;
@end

@interface HairpinBox : NSObject

//获取单例
+ (HairpinBox *)getInstance;

-(void)replaceDelegate:(id)delegate;

-(void)PowerOn;

-(void)PowerOff;

-(NSString*)getFirmwareVersion;

@end
