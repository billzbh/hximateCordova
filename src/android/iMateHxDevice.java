package com.HXcordova;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.util.Base64;
import android.util.Log;

import com.hxsmart.iMateSDK.HXiMateSDK;
import com.hxsmart.imateinterface.BluetoothThread;
import com.hxsmart.imateinterface.IcCardData;
import com.hxsmart.imateinterface.IdInformationData;
import com.hxsmart.imateinterface.MagCardData;
import com.hxsmart.imateinterface.UtilTools;
import com.hxsmart.imateinterface.pbochighsdk.PbocCardData;
import com.ivsign.android.IDCReader.IDCReaderSDK;

public class iMateHxDevice extends CordovaPlugin {

	private HXiMateSDK iMate;
	private CallbackContext callbackContext;
	
	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		iMate = HXiMateSDK.getInstance(cordova.getActivity().getApplicationContext());
		iMate.DisableCheckTactics(true);//是否不检查策略
		super.initialize(cordova, webView);
	}

	@Override
	public boolean execute(String action, CordovaArgs args,
			CallbackContext mCallbackContext) throws JSONException {
		
		System.out.println("exec !!!!!!!"+action);
		
		//检查连接状态
		if(!iMate.deviceIsConnecting()){
			mCallbackContext.error("未连接iMate设备!");
			return true;
		}
		//检查工作状态
		if(iMate.deviceIsWorking())
		{
			mCallbackContext.error("设备正在忙,稍后重试或者取消之前的操作");
			return true;
		}
		
		JSONArray jsonarrayTmp = null;
		JSONObject jsonTmp=null;
		try {
			jsonarrayTmp = new JSONArray(args.getString(0));//上层传的是 [{},{},{},...]数组
			jsonTmp = jsonarrayTmp.getJSONObject(0);
		} catch (JSONException e) {
			Log.i("zbh", "传入的参数解析JSONArray错误,使用new JSONObject(args.getString(0))方式");
			jsonTmp = new JSONObject(args.getString(0));
		}
		
		final JSONArray jsonarray = jsonarrayTmp;
		final JSONObject json = jsonTmp;
		
		
		callbackContext =  mCallbackContext;
		//更新策略
		if("updateTactic".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"Id;startTime;endTime;longitude;latitude;range;canUse")){
				callbackContext.error("缺少Id;startTime;endTime;longitude;latitude;range;canUse其中某个参数");
				return true;
			}
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	    			
	            	
	            	
	            	JSONObject jsontmp = new JSONObject();
	            	final ArrayList<String> arraylist= new ArrayList<String>();
	            	try {
	            		
		    			for (int i = 0; i < jsonarray.length(); i++) {
							jsontmp = jsonarray.getJSONObject(i);
		    				StringBuilder sb = new StringBuilder("");
		    				sb.append(jsontmp.getString("Id"));
		    				sb.append(";");
		    				sb.append(jsontmp.getString("startTime"));
		    				sb.append(";");
		    				sb.append(jsontmp.getString("endTime"));
		    				sb.append(";");
		    				sb.append(jsontmp.getString("longitude"));
		    				sb.append(";");
		    				sb.append(jsontmp.getString("latitude"));
		    				sb.append(";");
		    				sb.append(jsontmp.getString("range"));
		    				sb.append(";");
		    				sb.append(jsontmp.getString("canUse"));
		    				arraylist.add(sb.toString());
		    			}
					} catch (JSONException e) {
						callbackContext.error(e.getMessage());
						return;
					}
	            	
	    			int ret = iMate.updateTactics(arraylist);
	    			if(ret==0)
	    			{
	    				callbackContext.success("更新策略成功");
	    			}else{
	    				callbackContext.error("更新策略失败");
	    			}
	            }
			});

		//获取策略
		}else if("getTactics".equalsIgnoreCase(action)){
		 
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	ArrayList<String> arraylist = iMate.getTactics();
	    			if(arraylist!=null)
	    			{
	    				JSONArray JsonArray = new JSONArray();
	    				for (String string : arraylist) {
	    					String[] allKEYs =  string.split(";");
	    					JSONObject jsonObject = new JSONObject();
	    					try {
								jsonObject.put("Id", allKEYs[0]);
								jsonObject.put("startTime", allKEYs[1]);
								jsonObject.put("endTime", allKEYs[2]);
								jsonObject.put("longitude", allKEYs[3]);
								jsonObject.put("latitude", allKEYs[4]);
								jsonObject.put("range", allKEYs[5]);
								jsonObject.put("canUse", allKEYs[6]);
								JsonArray.put(jsonObject);
							} catch (JSONException e) {
								callbackContext.error(e.getMessage());
								return;
							}
						}
	    				callbackContext.success(JsonArray);
	    			}else{
	    				callbackContext.error(iMate.getErrorString());
	    			}
	            }
			});
			
		//获取设备信息:序列号,终端号等
		}else if("getDeviceInfo".equalsIgnoreCase(action)){
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	    			String SN = iMate.deviceSerialNumber();
	    			String termId = iMate.TermID();
	    			if(SN==null || termId ==null)
	    				callbackContext.error("读取设备信息失败");
	    			else
	    				callbackContext.success("{"+"\"DeviceSN\":\""+SN+"\""+
								   "\"termID\":\""+termId+"\""+
								"}");	
	            }
			});
		
		//子部件检测
		}else if("subDeviceTest".equalsIgnoreCase(action)){
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	
	            	int ret = iMate.deviceTest(0xFF);
	            	if(ret==0)
	            		callbackContext.success("子部件全部正常");
	            	else if(ret == 0x01)
	            		callbackContext.error("二代证模块异常");
	            	else if(ret == 0x02)
	            		callbackContext.error("射频模块异常");
	            }
			});
			
		//取消操作
		}else if("cancel".equalsIgnoreCase(action)){
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	iMate.cancel();
	            	callbackContext.success();
	            }
			});
			
		//蜂鸣器响一声	
		}else if("buzzer".equalsIgnoreCase(action)){
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	iMate.buzzer();
	            	callbackContext.success();
	            }
			});
			
		//检测是否蓝牙socket已连接	
		}else if("isConnectTest".equalsIgnoreCase(action)){
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	if(iMate.deviceIsConnecting())
	            		callbackContext.success("已连接");
	            	else
	            		callbackContext.error("未连接");
	            }
			});
			
		//同时等卡测试
		}else if("waitAllCard".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"timeout")){
				callbackContext.error("缺少timeout参数");
				return true;
			}
			final int timeout = json.getInt("timeout");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            
	            	byte[] ret = iMate.waitEvent(0xff, timeout);
	            	if(ret==null)
	            	{
	            		callbackContext.error(iMate.getErrorString());
	            	}else{
	            		
	            		// 判断事件
	            		String Event;
	    				if (ret[0] == 0x01) {
	    					// 取卡号
	    					Event = "磁条卡";
	    					Log.i("zbh", new String(ret, 1, 141));
	    					String track2 = new String(ret, 1, 37);
	    					String track3 = new String(ret, 38, 104);
	    					String[] tmpStrings = track2.split("=");
	    					callbackContext.success("{"+"\"Event\":\""+Event+"\""+
	    											"\"track2\":\""+track2+"\""+
	    											"\"track3\":\""+track3+"\""+
	    											"\"cardNo\":\""+tmpStrings[0]+"\""+
	    											"}");
	    					return;
	    				} else if (ret[0] == 0x02) {
	    					Event = "IC卡";
	    					int length = ret.length -1;
	    					byte[] bytes = new byte[length];
	    					System.arraycopy(ret, 1, bytes, 0, length);
	    					String ATR =BluetoothThread.bytesToHexString(bytes, length);
	    					
	    					callbackContext.success("{"+"\"Event\":\""+Event+"\""+
									"\"ATR\":\""+ATR+"\""+
									"}");
	    					return;
	    				} else {
	    					Event = "射频卡";
	    					int length = ret.length -1;
	    					byte[] bytes = new byte[length];
	    					System.arraycopy(ret, 1, bytes, 0, length);
	    					String ATR =BluetoothThread.bytesToHexString(bytes, length);
	    					callbackContext.success("{"+"\"Event\":\""+Event+"\""+
									"\"ATR\":\""+ATR+"\""+
									"}");
	    					return;
	    				}
	            	}
	            }
			});
			
		//读二代身份证
		}else if("readID".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"timeout")){
				callbackContext.error("缺少timeout参数");
				return true;
			}
			final int timeout = json.getInt("timeout");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	
	            	IdInformationData idInfo = new IdInformationData();
	            	int ret = iMate.readIdInformation(idInfo, timeout);
	            	Log.i("zbh", "执行结果:"+ret);
	            	if(ret==0)
	            	{
	            		ret = IDCReaderSDK.decodingPictureData(BluetoothThread.WLTLIB_DIR,
	            				idInfo.getPictureData());
	            		String message = null;
	            		switch (ret) {
						case 0:
							String photodata = readIdBmpAndToBASE64(BluetoothThread.WLTLIB_DIR
									+ File.separator + "zp.bmp");
							if(photodata!=null){
								String birthday = idInfo.getBirthdayYearString()+"."+idInfo.getBirthdayMonthString()+"."+idInfo.getBirthdayDayString();
								message = "{"+"\"name\":\""+idInfo.getNameString()+"\""+
										   "\"sex\":\""+idInfo.getSexString()+"\""+
										   "\"nation\":\""+idInfo.getNationString()+"\""+
										   "\"birthday\":\""+birthday+"\""+
										   "\"address\":\""+idInfo.getAddressString()+"\""+
										   "\"idNumber\":\""+idInfo.getIdNumberString()+"\""+
										   "\"issuser\":\""+idInfo.getIssuerString()+"\""+
										   "\"validdate\":\""+idInfo.getValidDateString()+"\""+
										   "\"photoBase64Data\":\""+photodata+"\""+
										"}";
								callbackContext.success(message);
								return;
							}
							message = "身份证照片转base64失败";
							break;
						case 1:
							message = "照片解码初始化失败，需要检查传入的wltlibDirectory以及base.dat文件";
							break;
						case 2:
							message = "授权文件license.lic错误";
							break;
						case 3:
							message = "照片解码失败，其它错误";
							break;
						}
	            		callbackContext.error(message);
	            	}else if(ret==2){
	            		callbackContext.error(idInfo.getErrorString());
	            	}else if(ret==1){
	            		callbackContext.error("通讯超时");
	            	}else if(ret==-1){
	            		callbackContext.error("策略检查不通过");
	            	}else if(ret==-9){
	            		callbackContext.error("读取策略数据发生错误");
	            	}
	            }
			});
			
		//刷磁条卡(记得检查数据)
		}else if("readMsgCard".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"timeout")){
				callbackContext.error("缺少timeout参数");
				return true;
			}
			final int timeout = json.getInt("timeout");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	MagCardData cardData = new MagCardData();
	            	int ret = iMate.swipeCard(cardData, timeout);
	            	if(ret!=0){
	            		String errMsg = "";
	            		if(ret==1)
	            			errMsg = "通讯超时";
	            		else if(ret == 2)
	            			errMsg = cardData.getErrorString();
	            		else if(ret == -1)
	            			errMsg = "策略检查不通过";
	            		else if(ret == -9)
	            			errMsg = "读取策略数据发生错误";
	            		else
	            			errMsg = "其他错误:["+ret+"]";
	            		callbackContext.error(errMsg);
	            		return;
	            	}
	            	
	            	if(cardData.getCardNoString()==null || cardData.getCardNoString().length()==0){
	            		callbackContext.error("磁条的卡号读取失败");
	            		return;
	            	}
	            	if(cardData.getTrack2String()==null || cardData.getTrack2String().length()==0){
	            		callbackContext.error("二磁道数据读取失败");
	            		return;
	            	}
	            	
	            	callbackContext.success("{"+"\"cardNo\":\""+cardData.getCardNoString()+"\""+
							   "\"track2\":\""+cardData.getTrack2String()+"\""+
							   "\"track3\":\""+cardData.getTrack3String()+"\""+
							"}");
	            }
			});
			
		//读IC卡
		}else if("readICCard".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"timeout")){
				callbackContext.error("缺少timeout参数");
				return true;
			}
			final int timeout = json.getInt("timeout");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	IcCardData icCardInfo = new IcCardData();
	            	int ret = iMate.readIcCard(icCardInfo, timeout);
	            	if(ret!=0){
	            		String errMsg = "";
	            		if(ret==1)
	            			errMsg = "通讯超时";
	            		else if(ret == 2)
	            			errMsg = icCardInfo.getErrorString();
	            		else if(ret == -1)
	            			errMsg = "策略检查不通过";
	            		else if(ret == -9)
	            			errMsg = "读取策略数据发生错误";
	            		else
	            			errMsg = "其他错误:["+ret+"]";
	            		callbackContext.error(errMsg);
	            		return;
	            	}
	            	
	            	callbackContext.success("{"+"\"cardNo\":\""+icCardInfo.getCardNoString().replace("f", "")+"\""+
							   "\"track2\":\""+icCardInfo.getTrack2String()+"\""+
							   "\"PanSN\":\""+icCardInfo.getPanSequenceNoString()+"\""+
							   "\"expireDate\":\""+icCardInfo.getExpireDateString()+"\""+
							   "\"holderName\":\""+icCardInfo.getHolderNameString()+"\""+
							   "\"holderID\":\""+icCardInfo.getHolderIdString()+"\""+
							"}");
	            }
			});
		
		//读RF卡
		}else if("readRFCard".equalsIgnoreCase(action)){
			if(!JsonObjectHasKeys(json,"timeout")){
				callbackContext.error("缺少timeout参数");
				return true;
			}
			final int timeout = json.getInt("timeout");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	IcCardData icCardInfo = new IcCardData();
	            	int ret = iMate.readRfCard(icCardInfo, timeout);
	            	if(ret!=0){
	            		String errMsg = "";
	            		if(ret==1)
	            			errMsg = "通讯超时";
	            		else if(ret == 2)
	            			errMsg = icCardInfo.getErrorString();
	            		else if(ret == -1)
	            			errMsg = "策略检查不通过";
	            		else if(ret == -9)
	            			errMsg = "读取策略数据发生错误";
	            		else
	            			errMsg = "其他错误:["+ret+"]";
	            		callbackContext.error(errMsg);
	            		return;
	            	}
	            	
	            	callbackContext.success("{"+"\"cardNo\":\""+icCardInfo.getCardNoString().replace("f", "")+"\""+
							   "\"track2\":\""+icCardInfo.getTrack2String()+"\""+
							   "\"PanSN\":\""+icCardInfo.getPanSequenceNoString()+"\""+
							   "\"expireDate\":\""+icCardInfo.getExpireDateString()+"\""+
							   "\"holderName\":\""+icCardInfo.getHolderNameString()+"\""+
							   "\"holderID\":\""+icCardInfo.getHolderIdString()+"\""+
							"}");
	            		
	            }
			});
		
		//读卡片55域
		}else if("readICCardField55".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"timeout;slot")){
				callbackContext.error("缺少timeout;slot中某个参数");
				return true;
			}
			final int timeout = json.getInt("timeout");
			final int slot = json.getInt("slot");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() {
	            	PbocCardData pbocCardData = new PbocCardData();
	            	int ret = iMate.readIC_Card_55Field(slot, pbocCardData, timeout);
	            	if(ret!=0){
	            		String errMsg = "";
	            		if(ret==-2)
	            			errMsg = iMate.getErrorString();
	            		else if(ret == -1)
	            			errMsg = "策略检查不通过";
	            		else if(ret == -9)
	            			errMsg = "读取策略数据发生错误";
	            		else
	            			errMsg = getPbocHighError(ret)+"["+ret+"]";
	            		callbackContext.error(errMsg);
	            		return;
	            	}
	            	
	            	callbackContext.success("{"+"\"cardNo\":\""+pbocCardData.pan+"\""+
							   "\"track2\":\""+pbocCardData.track2+"\""+
							   "\"PanSN\":\""+pbocCardData.panSeqNo+"\""+
							   "\"field55\":\""+pbocCardData.field55+"\""+
							   "\"holderName\":\""+pbocCardData.holderName+"\""+
							   "\"extInfo\":\""+pbocCardData.extInfo+"\""+
							"}");
	            	
	            }
			});
		
		//验证ARPC和执行脚本
		}else if("verifyARPC_RunScript".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"script")){
				callbackContext.error("缺少script参数");
				return true;
			}
			final String Script = json.getString("script");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	String newField55=new String();
	            	int ret = iMate.verifyARPC_RunScript(Script, newField55);
	            	if(ret!=0){
	            		String errMsg = getPbocHighError(ret)+"["+ret+"]";
	            		callbackContext.error(errMsg);
	            		return;
	            	}
	            	
	            	callbackContext.success("{"+"\"newField55\":\""+newField55+"\""+"}");
	            }
			});
			
		//设置指纹仪类型，设置指纹特征输出格式，获取指纹
		}else if("getFingerprintFeature".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"FingerprintModel;FeatureDataType")){
				callbackContext.error("缺少FingerprintModel;FeatureDataType中某个参数");
				return true;
			}
			final int theFingerprintModel = json.getInt("FingerprintModel");
			final int DataType = json.getInt("FeatureDataType");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	
	            		iMate.FingerPrint_setFingerprintModel(theFingerprintModel);
	            		iMate.FingerPrint_setFeatureDataType(DataType);
	            		String Feature = iMate.FingerPrint_GetFeature();
	            		if(Feature==null)
	            			callbackContext.error(iMate.getErrorString());
	            		else
	            			callbackContext.success("{"+"\"FingerprintData\":\""+Feature+"\""+"}");
	            }
			});
		
		//取消 指纹特征获取等待
		}else if("FingerPrint_Cancel".equalsIgnoreCase(action)){
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	iMate.FingerPrint_Cancel();
	            	callbackContext.success();
	            }
			});
			
		//设置密码键盘类型
		}else if("Pinpad_setPinpadModel".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"PinpadModel")){
				callbackContext.error("缺少PinpadModel参数");
				return true;
			}
			final int thePinpadModel = json.getInt("PinpadModel");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	iMate.Pinpad_setPinpadModel(thePinpadModel);
	            	callbackContext.success();
	            }
			});
			
		//密码键盘上电
		}else if("Pinpad_PowerOn".equalsIgnoreCase(action)){
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	int ret = iMate.Pinpad_PowerOn();
	            	if(ret == 0)
	            		callbackContext.success();
	            	else
	            		callbackContext.error(iMate.getErrorString());
	            }
			});
			
		//取消密码键盘输入密码的等待
        }else if("Pinpad_Cancel".equalsIgnoreCase(action)){
            
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    iMate.Pinpad_Cancel();
                    callbackContext.success();
                }
            });
            
        //获取密码键盘序列号
        }else if("Pinpad_getSerialNo".equalsIgnoreCase(action)){
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	String PinpadSN = iMate.Pinpad_getSerialNo();
	            	if(PinpadSN==null)
            			callbackContext.error(iMate.getErrorString());
            		else
            			callbackContext.success("{"+"\"PinpadSN\":\""+PinpadSN+"\""+"}");
	            }
			});
			
	    //下装初始主密钥	
		}else if("Pinpad_DownloadMasterKey".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"algorithm;masterIndex;masterKey")){
				callbackContext.error("缺少algorithm;masterIndex;masterKey中某个参数");
				return true;
			}
			final int algorithm = json.getInt("algorithm");
			final int masterIndex = json.getInt("masterIndex");
			String masterKeyStr = json.getString("masterKey");
			final byte[] masterKey = UtilTools.HexString2Bytes(masterKeyStr);
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	int ret = iMate.Pinpad_DownloadMasterKey(algorithm, masterIndex, masterKey, masterKey.length);
	            	if(ret!=0)
            			callbackContext.error(iMate.getErrorString());
            		else
            			callbackContext.success();
	            }
			});
			
		//下装工作密钥	
		}else if("Pinpad_DownloadWorkingKey".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"algorithm;masterIndex;workingIndex;workingKey")){
				callbackContext.error("缺少algorithm;masterIndex;workingIndex;workingKey中某个参数");
				return true;
			}
			
			final int algorithm = json.getInt("algorithm");
			final int masterIndex = json.getInt("masterIndex");
			final int workingIndex = json.getInt("workingIndex");
			String workingKeyStr = json.getString("workingKey");
			final byte[] workingKey = UtilTools.HexString2Bytes(workingKeyStr);
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	int ret = iMate.Pinpad_DownloadWorkingKey(algorithm, masterIndex, workingIndex, workingKey, workingKey.length);
	            	if(ret!=0)
            			callbackContext.error(iMate.getErrorString());
            		else
            			callbackContext.success();
	            }
			});
			
		//更新主密钥	
		}else if("Pinpad_UpdateMasterKey".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"algorithm;masterIndex;masterKey")){
				callbackContext.error("缺少algorithm;masterIndex;masterKey中某个参数");
				return true;
			}
			
			final int algorithm = json.getInt("algorithm");
			final int masterIndex = json.getInt("masterIndex");
			String masterKeyStr = json.getString("masterKey");
			final byte[] masterKey = UtilTools.HexString2Bytes(masterKeyStr);
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	int ret = iMate.Pinpad_UpdateMasterKey(algorithm, masterIndex, masterKey, masterKey.length);
	            	if(ret!=0)
            			callbackContext.error(iMate.getErrorString());
            		else
            			callbackContext.success();
	            }
			});
			
		//下装MAC密钥	
		}else if("Pinpad_DownloadMACKey".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"algorithm;masterIndex;MackeyIndex;MacKey")){
				callbackContext.error("缺少algorithm;masterIndex;MackeyIndex;MacKey中某个参数");
				return true;
			}
			
			final int algorithm = json.getInt("algorithm");
			final int masterIndex = json.getInt("masterIndex");
			final int MackeyIndex = json.getInt("MackeyIndex");
			String MacKeyStr = json.getString("MacKey");
			final byte[] MacKey = UtilTools.HexString2Bytes(MacKeyStr);
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	int ret = iMate.Pinpad_DownloadMACKey(algorithm, masterIndex, MackeyIndex, MacKey, MacKey.length);
	            	if(ret!=0)
            			callbackContext.error(iMate.getErrorString());
            		else
            			callbackContext.success();
	            }
			});
			
		//获取密码密文	
		}else if("Pinpad_getPin".equalsIgnoreCase(action)){
			
			if(!JsonObjectHasKeys(json,"algorithm;masterIndex;workingIndex;cardNo;pinLength;timeout")){
				callbackContext.error("缺少algorithm;masterIndex;workingIndex;cardNo;pinLength;timeout中某个参数");
				return true;
			}
			
			final int algorithm = json.getInt("algorithm");
			final int masterIndex = json.getInt("masterIndex");
			final int workingIndex = json.getInt("workingIndex");
			final String cardNo = json.getString("cardNo");
			final int pinLength = json.getInt("pinLength");
			final int timeout = json.getInt("timeout");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	String pin = iMate.Pinpad_getPin(algorithm, true, masterIndex, workingIndex, cardNo, pinLength, timeout);
	            	if(pin==null)
            			callbackContext.error(iMate.getErrorString());
            		else
            			callbackContext.success("{"+"\"Pin\":\""+pin+"\""+"}");
	            }
			});
			
		//获取明文密码
		}else if("Pinpad_getPlainPin".equalsIgnoreCase(action)){
		
			if(!JsonObjectHasKeys(json,"pinLength;timeout")){
				callbackContext.error("缺少pinLength;timeout中某个参数");
				return true;
			}
			
			final int pinLength = json.getInt("pinLength");
			final int timeout = json.getInt("timeout");
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	String PlainPin = iMate.Pinpad_getPlainPin(pinLength, timeout);
	            	if(PlainPin==null)
            			callbackContext.error(iMate.getErrorString());
            		else
            			callbackContext.success("{"+"\"PlainPin\":\""+PlainPin+"\""+"}");
	            }
			});
			
		//主密钥加解密
		}else if("Pinpad_Encrypt".equalsIgnoreCase(action)){
		
			if(!JsonObjectHasKeys(json,"algorithm;masterIndex;workingIndex;cryptoMode;data")){
				callbackContext.error("缺少algorithm;masterIndex;workingIndex;cryptoMode;data中某个参数");
				return true;
			}
			
			final int algorithm = json.getInt("algorithm");
			final int masterIndex = json.getInt("masterIndex");
			final int workingIndex = json.getInt("workingIndex");
			final int cryptoMode = json.getInt("cryptoMode");
			String dataStr = json.getString("data");
			final byte[] data = UtilTools.HexString2Bytes(dataStr);
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	byte[] resultBytes = iMate.Pinpad_Encrypt(algorithm, cryptoMode, masterIndex, workingIndex, data, data.length);
	            	
	            	if(resultBytes==null)
            			callbackContext.error(iMate.getErrorString());
            		else
            			callbackContext.success("{"+"\"outData\":\""+UtilTools.Bytes2HexString(resultBytes)+"\""+"}");
	            }
			});
			
		//计算Mac
		}else if("Pinpad_Mac".equalsIgnoreCase(action)){
		
			if(!JsonObjectHasKeys(json,"algorithm;masterIndex;macIndex;data")){
				callbackContext.error("缺少algorithm;masterIndex;macIndex;data中某个参数");
				return true;
			}
			
			final int algorithm = json.getInt("algorithm");
			final int masterIndex = json.getInt("masterIndex");
			final int macIndex = json.getInt("macIndex");
			String dataStr = json.getString("data");
			final byte[] data = dataStr.getBytes();// UTF-8
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	byte[] resultBytes = iMate.Pinpad_Mac(algorithm, masterIndex, macIndex, data, data.length);
	            	
	            	if(resultBytes==null)
            			callbackContext.error(iMate.getErrorString());
            		else
            			callbackContext.success("{"+"\"outData\":\""+UtilTools.Bytes2HexString(resultBytes)+"\""+"}");
	            }
			});
			
		//密码键盘下电或断开蓝牙连接
		}else if("Pinpad_PowerOff".equalsIgnoreCase(action)){
			
			cordova.getThreadPool().execute(new Runnable() {
	            public void run() { 
	            	int ret = iMate.Pinpad_PowerOff();
	            	if(ret == 0)
	            		callbackContext.success();
	            	else
	            		callbackContext.error(iMate.getErrorString());
	            }
			});
			
		
		}else if("OpenBluetoothSocket".equalsIgnoreCase(action)){
			iMate.resumeThread();
			callbackContext.success();
		}else if("CloseBluetoothSocket".equalsIgnoreCase(action)){
			iMate.pauseThread();
			callbackContext.success();
		}else if("startSearchBLE".equalsIgnoreCase(action)){
			callbackContext.success();
		}else if("stopSearchBLE".equalsIgnoreCase(action)){
			callbackContext.success();
		}else if("bindDevice".equalsIgnoreCase(action)){
			callbackContext.success();
		}
		

		//pboc 底层接口，暂不实现
		return true;
	}

	public String readIdBmpAndToBASE64(String fileName) {
		String res = null;
		try {
			FileInputStream fin = new FileInputStream(fileName);
			int length = fin.available();
			byte[] buffer = new byte[length];
			fin.read(buffer);
			res = (Base64.encodeToString(buffer, Base64.NO_WRAP)).replace("\n","");
			fin.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return res;
	}
	
	public boolean JsonObjectHasKeys(JSONObject json,String keysString)
	{
		String[] keys = keysString.split(";");
		for (String string : keys) {
			if(!json.has(string))
				return false;
		}
		return true;
	}
	
	public String getPbocHighError(int ErrorCode)
	{
		String message;
	    switch (ErrorCode) {
	        case 1:
	            message = "参数错误";
	            break;
	        case 2:
	            message = "无卡";
	            break;
	        case 3:
	            message = "无支持的应用";
	            break;
	        case 4:
	            message = "卡操作错";
	            break;
	        case 5:
	            message = "非法卡指令状态字";
	            break;
	        case 6:
	            message = "交易被拒绝";
	            break;
	        case 7:
	            message = "交易被终止";
	            break;
	        default:
	            message = "其它错误";
	            break;
	    }
	    return message;
	}
}
