# aiwuyu-iOS-sdk
## 一. SDK介绍
爱物语Web SDK是针对爱物语h5页面交互开发的一套工具，提供webview功能、渠道用户联合登录到爱物语平台、通过渠道app分享等功能。

## 二. 接入指南
* 获取channelCode
爱物语平台会为每个接入渠道提供一个channelCode，用于标识渠道身份。请联系爱物语平台获取。
* 集成方式
     iOS
     通过pod集成：
     在 Podfile中添加source路径
    ``` 
    source 'http://gitlab.aiwuyu.cn:8080/APP/aiwuyu_ios_sdk.git'
    
    use_frameworks!
    pod 'aiwuyu_iOS_sdk'
    ```
    在info.plist文件中添加相机和相册白名单
    NSCameraUsageDescription
    NSPhotoLibraryUsageDescription
    
    Swift:
    ``` import aiwuyu_iOS_sdk ```
    OC:
   ``` #import <aiwuyu_iOS_sdk-Swift.h>```
   
## 三.  API
#### 1. 入口类 AwySDK

###### 1. 初始化方法
Swift:
 ``` AwySDK.initialize(channelCode: <#T##String#>, delegate: <#T##AwySDKDelegate?#>)```
OC:
 ```[AwySDK initializeWithChannelCode:<#(NSString * _Nonnull)#> delegate:<#(id<AwySDKDelegate> _Nullable)#>] ```
推荐在AppDelegate中初始化SDK
channelCode：渠道身份标识
delegate：是您必须要实现的AwySDKDelegate代理方法

###### 2. 使用sdk打开h5链接

Swift:
```AwySDK.pushWeb(nav: <#T##UINavigationController?#>, urlStr: <#T##String#>)```

OC:
```[AwySDK pushWebWithNav:<#(UINavigationController * _Nullable)#> urlStr:<#(NSString * _Nonnull)#>]```


#### 2. SDK回掉渠道app接口 AwySDKDelegate
Swift:
```func requestAuth(authInfo:((_ str:String)->Void)?)```
OC:
```- (void)requestAuthWithAuthInfo:(void (^)(NSString * _Nonnull))authInfo```

sdk向渠道app请求联合登录参数

渠道方需要使用爱物语server sdk生成联合登录参数，

并通过block异步传递给爱物语sdk

authInfo：在server中获取的登录参数,通过block回调传给sdk。

###### 2. 请求分享
Swift:
```func requestShare(shareData:AwyShareData)->Bool```
OC:
```- (BOOL)requestShareWithShareData:(AwyShareData *)shareData```

sdk向渠道app请求分享 

AwyShareData：返回sdk要分享的信息（分享标题、内容、链接、图片链接）
返回值：true表示支持通过渠道app分享内容，false表示不支持分享内容 

其中AwyShareData：有获取图片Data格式方法
Swift:
```func downloadImage(imageBack:@escaping ((_ imageData:Data?)->Void))```
OC:
```- (void)downloadImage:(void (^ _Nullable)(NSData * _Nullable))imageBack```
如果imageData为空，下载图片出错

## 四. 联合登录整体流程

* 爱物语sdk向渠道app请求联合登录参数

* 如果渠道app是已经登录状态，渠道app向渠道后台请求联合登录参数，如果未登录直接回调sdk null即可

* 渠道后台收到联合登录请求后，调用爱物语server sdk生成联合登录参数，并下发给渠道app

* 渠道app再将参数通过接口回调，传递给sdk

* sdk使用联合登录参数请求爱物语平台登录

* 登录完成
