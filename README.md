# imate新插件说明
## cordova 事件监听
cordova可以监听到app在后台或者前台的事件。ios需要在这两个事件中，打开或者关闭蓝牙连接，android上并不需要这样做，但仍可以调用这个两个方法，只是实现并没有做任何事情

http://cordova.apache.org/docs/en/latest/cordova/events/events.html

## cordova-iOS平台自定义
添加ios平台，请使用
> cordova platform add https://github.com/billzbh/cordova-ios.git

涉及窗口固定，状态栏下移等

## 自定义的CDVdevice插件
获取MAC地址
> cordova plugin add https://github.com/billzbh/cordova-plugin-device.git


##流程：

1. 创建cordova工程
> cordova create 工程路径 项目ID（各平台打包的唯一标识） 工程名称

2. 添加修改过的ios平台，Android平台
> cordova platform add https://github.com/billzbh/cordova-ios.git --save
> cordova platform add android --save
3. 添加修改过的CDVdevice插件
> cordova plugin add https://github.com/billzbh/cordova-plugin-device.git

4. 添加imate新插件
> cordova plugin add https://github.com/billzbh/hximateCordova.git

5. js添加后台前台事件监听，调用蓝牙打开、关闭接口
6. 正常调用其他接口







