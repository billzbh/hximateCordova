/**
 * 前提：配对好 imate设备的蓝牙。
 * 一般流程: 1. 获取单例，等待设备的的link灯亮起来
 *         2. 执行各种操作
 *         3. 在等待某个操作执行时，可调用 cancel 接口取消操作
 * 
 * 
 * pboc卡验证ARPC子流程:
 * 		   1.  调用readIC_Card_55Field(int slot,PbocCardData pbocCardData,int timeout) 获取卡片信息和55域。
 * 		   2.  在执行下一个接口前，卡片不能插拔或者重新上电
 * 		   3.  调用verifyARPC_RunScript(String Script,String newField55),参数为行方核心返回的脚本。
 * 
 * 
 * 密码键盘子流程: 
 *         1.  设置密码键盘的类型 Pinpad_setPinpadModel(int thePinpadModel) 
 *         2.  powerOn 上电
 *         3.  执行密码键盘某个功能
 *         4.  powerOff（可选）
 *         5.  在等待获取密码时，可以使用 Pinpad_Cancel() 取消此操作。
 *         
 * 指纹仪子流程:
 *         1.  设置指纹仪类型 FingerPrint_setFingerprintModel(int theFingerprintModel)
 *         2.  设置指纹特征数据的输出格式 FingerPrint_setFeatureDataType(int DataType)
 *         3.  调用获取指纹特征的接口 FingerPrint_GetFeature(int theFingerprintModel)
 *         4.  在等待获取指纹时，可以使用 FingerPrint_Cancel() 取消此操作。
 * 
 *      
 * @author zbh
 *
 */


        var exec = require("cordova/exec");

        /**
         * Constructor.
         *
         * @returns {NEWHXiMateSDK}
         */
        function NEWHXiMateSDK() {};

        /**
        打开蓝牙的socket连接
        param：无
        总是成功。
        */
        NEWHXiMateSDK.prototype.OpenBluetoothSocket = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.OpenBluetoothSocket failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.OpenBluetoothSocket failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'OpenBluetoothSocket',[param]);
        };    
         
        /**
        关闭蓝牙的socket连接
        param：无
        总是成功。
        */
        NEWHXiMateSDK.prototype.CloseBluetoothSocket = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.CloseBluetoothSocket failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.CloseBluetoothSocket failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'CloseBluetoothSocket',[param]);
        }; 
        
          
        
        /**
        查找蓝牙(only ios,android上不起作用)
        param：无
        
        每成功搜索到一个蓝牙设备就回调一次。
        {deviceName:xxxxxx}
        */
        NEWHXiMateSDK.prototype.startSearchBLE = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.startSearchBLE failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.startSearchBLE failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'startSearchBLE',[param]);
        };
        

        /**
        停止搜索蓝牙(only ios,android上不起作用)
        param：无
        总是返回成功
        */
        NEWHXiMateSDK.prototype.stopSearchBLE = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.stopSearchBLE failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.stopSearchBLE failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'stopSearchBLE',[param]);
        };
        
        
        /**
        指定连接的蓝牙设备名称(only ios,android上不起作用)
        param：{deviceName:xxxxxx}
        总是返回成功
        */
        NEWHXiMateSDK.prototype.bindDevice = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.bindDevice failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.bindDevice failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'bindDevice',[param]);
        };
        
        
        
        /******       getDeviceInfo      ******/ //
        /**
        获取设备信息
        param：无
        成功返回数据：{DeviceSN:xxxxxx,termID:xxxxxxxx}
        DeviceSN           设备唯一序列号
        termID             终端号
        */
				NEWHXiMateSDK.prototype.getDeviceInfo = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.getDeviceInfo failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.getDeviceInfo failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'getDeviceInfo',[param]);
        };
        

        /******       subDeviceTest      ******/ 
       /**
        设备子部件测试
        param：无
        成功返回全部正常
        失败返回异常的模块描述
        */
       NEWHXiMateSDK.prototype.subDeviceTest = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
       
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.subDeviceTest failure: failure parameter not a function");
                return;
            }
       
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.subDeviceTest failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'subDeviceTest',[param]);
       };
       
       
        
        /******       cancel      ******/
        /**
        取消imate背夹的操作(读IC卡，身份证，磁条卡等操作)
        直接返回成功
        */
				NEWHXiMateSDK.prototype.cancel = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.cancel failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.cancel failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'cancel',[param]);
        };
        
        
        /******       buzzer      ******/
        /**
        iMate蜂鸣器响一声，起到提示的作用
        直接返回成功
        */
				NEWHXiMateSDK.prototype.buzzer = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.buzzer failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.buzzer failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'buzzer',[param]);
        };
        
        /******       isConnectTest      ******/
        /**
        查询iMate是否连接
        成功回调返回已连接
        失败回调返回未连接
        */
				NEWHXiMateSDK.prototype.isConnectTest = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.isConnectTest failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.isConnectTest failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'isConnectTest',[param]);
        };
        
        
        /******       waitAllCard      ******/
        /**
        同时等待卡片
        入参:  {timeout:15} 等待卡片插入的超时时间
        
        成功返回
        IC卡   :  {Event:IC卡,ATR:xxxxxxxxxx}
        磁条卡  :  {Event:磁条卡,track2:xxxxxx,track3:xxxxxxx,cardNo:xxxxxxxx}
        射频卡  :  {Event:射频卡,ATR:xxxxxxxxxx}
        失败返回错误信息
        */
				NEWHXiMateSDK.prototype.waitAllCard = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.waitAllCard failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.waitAllCard failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'waitAllCard',[param]);
        };
        
        
        /******    readIdCard    ******/
        /**
        读取身份证信息
        入参:  {timeout:15} 等待超时时间
        
        成功返回：
        {name:姓名,sex:性别,nation:民族,birthday:出生日期,address:住址,idNumber:身份证号,issuser:发证机关,validdate:有效期,photoBase64Data:照片base4数据}
        
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.readIdCard = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.readIdCard failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.readIdCard failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'readID', [param]);
        };
        
        
        /******    readMsgCard    ******/
        /**
        读取磁条卡信息
        入参:  {timeout:15} 等待超时时间
        
        成功返回：
        {cardNo:卡号,track2:磁道2信息,track3:磁道3信息}
        
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.readMsgCard = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.readMsgCard failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.readMsgCard failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'readMsgCard', [param]);
        };

				
				/******    readICCard    ******/
        /**
        读取IC卡信息
        入参:  {timeout:15} 等待超时时间
        
        成功返回：
        {cardNo:卡号,track2:磁道2信息,PanSN:卡序列号,expireDate:失效日期,holderName:持卡人姓名,holderID:持卡人ID}
        
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.readICCard = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.readICCard failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.readICCard failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'readICCard', [param]);
        };
        

				/******    readRFCard    ******/
        /**
        读取射频卡信息
        入参:  {timeout:15} 等待超时时间
        
        成功返回：
        {cardNo:卡号,track2:磁道2信息,PanSN:卡序列号,expireDate:失效日期,holderName:持卡人姓名,holderID:持卡人ID}
        
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.readRFCard = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.readRFCard failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.readRFCard failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'readRFCard', [param]);
        };


				/******    readICCardField55    ******/
        /**
        读取PBOC卡片的信息和55域等，用于验证ARQC
        入参:  {timeout:15,slot:0} 
               timeout    等待超时时间
               slot       0  IC卡
                          1  射频卡
        成功返回：
        {cardNo:卡号,track2:磁道2信息,PanSN:卡序列号,field55:55域数据,holderName:持卡人姓名,extInfo:卡片其他额外信息}
        
        失败返回错误信息 或者pbochigh错误码：
        HXPBOC_HIGH_OK			  =	0;  // OK
				HXPBOC_HIGH_PARA		  =	1;  // 参数错误
	 			HXPBOC_HIGH_NO_CARD		=	2;  // 无卡
	      HXPBOC_HIGH_CARD_IO		=	4;  // 卡操作错
	      HXPBOC_HIGH_CARD_SW		=	5;  // 非法卡指令状态字
	      HXPBOC_HIGH_DENIAL		=	6;  // 交易被拒绝
	      HXPBOC_HIGH_TERMINATE	=	7;  // 交易被终止
	     	HXPBOC_HIGH_OTHER		=	8;  // 其它错误
        */
        NEWHXiMateSDK.prototype.readICCardField55 = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.readICCardField55 failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.readICCardField55 failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'readICCardField55', [param]);
        };
       

				/******    verifyARPC_RunScript    ******/
        /**
        在上一步 readICCardField55 的基础上，验证ARPC，执行脚本功能。
        入参:  {script:xxxxx} 
               script    TLV格式的hexString字符串
           
        成功返回：
        {newField55:新产生的55域数据}
        
        失败返回 高层PBOC错误码：
        HXPBOC_HIGH_OK			  =	0;  // OK
				HXPBOC_HIGH_PARA		  =	1;  // 参数错误
	 			HXPBOC_HIGH_NO_CARD		=	2;  // 无卡
	      HXPBOC_HIGH_CARD_IO		=	4;  // 卡操作错
	      HXPBOC_HIGH_CARD_SW		=	5;  // 非法卡指令状态字
	      HXPBOC_HIGH_DENIAL		=	6;  // 交易被拒绝
	      HXPBOC_HIGH_TERMINATE	=	7;  // 交易被终止
	     	HXPBOC_HIGH_OTHER		=	8;  // 其它错误
        */
        NEWHXiMateSDK.prototype.verifyARPC_RunScript = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.verifyARPC_RunScript failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.verifyARPC_RunScript failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'verifyARPC_RunScript', [param]);
        };
        
        
        /******    getFingerprintFeature    ******/
        /**
        从指纹仪获取人的指纹特征值
        入参:  {FingerprintModel:指纹仪厂商类型,FeatureDataType:输出数据格式} 
               FingerprintModel ：   
               		维尔指纹仪          (int值:0)
	 						 		天诚盛业            (int值:1)
	 						 		中正指纹仪          (int值:2)
	 								威海银行专用         (int值:3)不支持
	 								上海银行            (int值:4)不支持               
               FeatureDataType: （中正指纹仪建议选3x格式，天诚盛业选择base64格式，维尔指纹仪不支持输出格式定制，默认是base64）
               		0      hexString 的格式 
									1      3x格式
	 								2		   base64格式                     
        成功返回：
        {FingerprintData:指纹特征值}
        
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.getFingerprintFeature = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.getFingerprintFeature failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.getFingerprintFeature failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'getFingerprintFeature', [param]); /*0  1  2 { "FingerModel": "0" }*/
        };
        
        
        /******       FingerPrint_Cancel      ******/
        /**
        取消 获取指纹特征的操作，避免长时间等待
        直接返回成功
        */
				NEWHXiMateSDK.prototype.FingerPrint_Cancel = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.FingerPrint_Cancel failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.FingerPrint_Cancel failure: success callback parameter must be a function");
                return;
            }
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'FingerPrint_Cancel',[param]);
        };
        
        
        
        
        
        /******  Pinpad_setPinpadModel  ******/
        /**
        设置密码键盘的类型。开始操作密码键盘前，同一种类型的密码键盘只需调用一次。如果切换新的密码键盘类型，需再次调用。
        
        入参:{PinpadModel:键盘类型值}
        PinPad.KMY_MODEL   （int取值 ：0）凯明杨
        PinPad.XYD_MODEL   （int取值 ：1）信雅达
        PinPad.M35_MODEL   （int取值 ：2）联迪M35
        PinPad.START_MODEL （int取值 ：3）实达
        PinPad.TY_MODEL    （int取值 ：4）天喻
        PinPad.HX_MODEL    （int取值 ：5）华信iMate401自带     
        
        直接返回成功
        */
        NEWHXiMateSDK.prototype.Pinpad_setPinpadModel = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_setPinpadModel failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_setPinpadModel failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_setPinpadModel', [param]);
        };
        
        
        /******  Pinpad_PowerOn  ******/
        /**
        密码键盘上电。M35执行此功能才会连接蓝牙
        注意，必须执行此方法成功后，才能使用密码键盘 其他相关功能。
        
        入参:无    
        返回成功 或者错误信息
        
        */
        NEWHXiMateSDK.prototype.Pinpad_PowerOn = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_PowerOn failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_PowerOn failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_PowerOn', [param]);
        };
        
        
                /******  Pinpad_PowerOff  ******/
        /**
        密码键盘下电。可以忽略，非必须。M35执行此功能会断开蓝牙
        
        入参:无    
        返回成功 或者错误信息
        
        */
        NEWHXiMateSDK.prototype.Pinpad_PowerOff = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_PowerOff failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_PowerOff failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_PowerOff', [param]);
        };
        
        /******  Pinpad_Cancel  ******/
        /**
        密码键盘取消输入密码等待
        
        入参:无    
        返回成功 或者错误信息
        
        */
        NEWHXiMateSDK.prototype.Pinpad_Cancel = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_Cancel failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_Cancel failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_Cancel', [param]);
        };
        
        
        
        /******  Pinpad_getSerialNo  ******/
        /**
        获取密码键盘的序列号
        
        入参:无    
        成功返回 ：{PinpadSN:xxxxxxx}
        
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.Pinpad_getSerialNo = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_getSerialNo failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_getSerialNo failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_getSerialNo', [param]);
        };
        

        /******  Pinpad_DownloadMasterKey  ******/
        /**
        密码键盘下装初始主密钥
        
        入参: {algorithm:算法标识,masterIndex:主密钥索引值,masterKey:主密钥hexString数据}
        algorithm:
        				0   DES
        				1   3des
        				2   SM4
        masterIndex: 0-7
        masterKey:   
                   联迪带校验码 ，数据为 主密钥数据(32个字符) + N 位校验码
                   algorithm = 1，N = 8
									 algorithm = 2，N = 16
									 注意:如果不需要校验，N 使用0填充
									 其他密码键盘 32个字符		           
     
     		成功直接返回   
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.Pinpad_DownloadMasterKey = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_DownloadMasterKey failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_DownloadMasterKey failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_DownloadMasterKey', [param]);
        };
        
        
        /******  Pinpad_UpdateMasterKey  ******/
        /**
        密码键盘更新主密钥(只支持华信，M35，KMY)
        
        入参: {algorithm:算法标识,masterIndex:主密钥索引值,masterKey:主密钥hexString数据}
        algorithm:
        				0   DES
        				1   3des
        				2   SM4
        masterIndex: 0-8
        masterKey:   
                   联迪带校验码 ，数据为 主密钥数据(32个字符) + N 位校验码
                   algorithm = 1，N = 8
									 algorithm = 2，N = 16
									 注意:如果不需要校验，N 使用0填充
									 其他密码键盘 32个字符			           
     
     		成功直接返回   
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.Pinpad_UpdateMasterKey = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_UpdateMasterKey failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_UpdateMasterKey failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_UpdateMasterKey', [param]);
        };
           


        /******  Pinpad_DownloadWorkingKey  ******/
        /**
        密码键盘下装工作密钥
        
        入参: {algorithm:算法标识,masterIndex:主密钥索引值,workingIndex:工作密钥索引值,workingKey:工作密钥hexString数据}
        algorithm:
        				0   DES
        				1   3des
        				2   SM4
        masterIndex:  0-7
        workingIndex: 0-15
        workingKey:   
                   联迪带校验码 ，数据为 主密钥数据(32个字符) + N 位校验码
                   algorithm = 1，N = 8
									 algorithm = 2，N = 16
									 注意:如果不需要校验，N 使用0填充
									 其他密码键盘 32个字符			           
     
     		成功直接返回   
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.Pinpad_DownloadWorkingKey = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_DownloadWorkingKey failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_DownloadWorkingKey failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_DownloadWorkingKey', [param]);
        };
        
        
        /******  Pinpad_DownloadMACKey  ******/
        /**
        密码键盘下装MAC密钥 （只支持联迪M35，其他密码键盘可以使用下装工作密钥的别的索引号间接实现这个功能）
        
        入参: {algorithm:算法标识,masterIndex:主密钥索引值,MackeyIndex:工作密钥索引值,MacKey:工作密钥hexString数据}
        algorithm:
        				0   DES
        				1   3des
        				2   SM4
        masterIndex:  0-7
        MackeyIndex: 0-15
        MacKey:   
                   联迪带校验码 ，数据为 主密钥数据(32个字符) + N 位校验码
                   algorithm = 1，N = 8
									 algorithm = 2，N = 16
									 注意:如果不需要校验，N 使用0填充
									 其他密码键盘 32个字符			           
     
     		成功直接返回   
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.Pinpad_DownloadMACKey = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_DownloadMACKey failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_DownloadMACKey failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_DownloadMACKey', [param]);
        }; 
     


        /******  Pinpad_getPin  ******/
        /**
        获取输入密码的密文
        
        入参: {algorithm:算法标识,masterIndex:主密钥索引值,workingIndex:工作密钥索引值,cardNo:参与运算的卡号,pinLength:设置密码长度,timeout:超时时间}
        algorithm:
        				0   DES
        				1   3des
        				2   SM4
        masterIndex:  0-7
        workingIndex: 0-15
        cardNo:  参与运算的卡号，如不需要，给16个0
        pinLength:设定想要的密码长度。建议为 6
        timeout: 超时时间             
     
     		成功直接返回 {Pin:密文}   
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.Pinpad_getPin = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_getPin failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_getPin failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_getPin', [param]);
        };
        
        
        /******  Pinpad_getPlainPin  ******/
        /**
        获取输入密码的明文
        
        入参: {pinLength:设置密码长度,timeout:超时时间}
        pinLength:设定想要的密码长度。建议为 6
        timeout: 超时时间             
     
     		成功直接返回 {PlainPin:密码明文}   
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.Pinpad_getPlainPin = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_getPlainPin failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_getPlainPin failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_getPlainPin', [param]);
        };
        
        

        /******  Pinpad_Encrypt  ******/
        /**
        使用主密钥加密 或者 解密数据。
        
        入参: {algorithm:算法标识,masterIndex:主密钥索引值,workingIndex:工作密钥索引值,cryptoMode:加密or解密,data:待加密的hexString数据}
        algorithm:
        				0   DES
        				1   3des
        				2   SM4
        masterIndex:  0-7
        workingIndex: 0-15
        cryptoMode:  加解密方式，以ECB方式进行加解密运算。  1:加密, 2: 解密
        data:待加密的hexString数据            
     
     		成功直接返回 {outData:加解密结果数据}   
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.Pinpad_Encrypt = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_Encrypt failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_Encrypt failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_Encrypt', [param]);
        };




        /******  Pinpad_Mac  ******/
        /**
        使用指定索引的MAC密码计算mac。
        
        入参: {algorithm:算法标识,masterIndex:主密钥索引值,macIndex:mac密钥索引值,data:待加密的hexString数据}
        algorithm:
        				0   DES
        				1   3des
        				2   SM4
        masterIndex:  0-7
        macIndex: 0-15
        data:待加密的hexString数据            
     
     		成功直接返回 {outData:加解密结果数据}   
        失败返回错误信息
        */
        NEWHXiMateSDK.prototype.Pinpad_Mac = function (successCallback, errorCallback,param) {
            if (errorCallback == null) {
                errorCallback = function () {
                };
            }
    
            if (typeof errorCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_Mac failure: failure parameter not a function");
                return;
            }
    
            if (typeof successCallback != "function") {
                console.log("NEWHXiMateSDK.Pinpad_Mac failure: success callback parameter must be a function");
                return;
            }
            
            exec(successCallback, errorCallback, 'NEWHXiMateSDK', 'Pinpad_Mac', [param]);
        };
        
        
        //-------------------------------------------------------------------
        var hxiMate = new NEWHXiMateSDK();
        module.exports = hxiMate;


