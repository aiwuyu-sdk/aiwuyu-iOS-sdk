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
    
    ```
    ///Swift:
    import aiwuyu_iOS_sdk
    ```
    
   ```
   ///OC:
   #import <aiwuyu_iOS_sdk-Swift.h>
   ```
   
   OC:例子
   AwySDKDelegate:
   ```
   ///实现AwySDKDelegate 协议方法例子
@implementation AYSDKClass
K_Shared(AYSDKClass)

- (void)requestShareWithShareData:(AwyShareData *)shareData{
    
    
    NSString *title = shareData.title;
    NSString *content = shareData.content;
    NSString *url = shareData.shareUrl;
    NSString *iconUrl = shareData.imageUrl;

    
    [AYShareController newsShareToShowWithUrlStr:url title:title content:content thumbUrl:iconUrl shareType:@"" miniProgram:@""];
    
    return ;
}

- (BOOL)isAppAuth{
    return UserManager.isLogin;
}
- (void)requestAuthWithNav:(UINavigationController * _Nonnull)nav{
    [nav pushViewController:[[JLoginOTPController alloc] init] animated:YES];
}
- (void)requestUnionAuthInfoWithAuthInfo:(void (^ _Nullable)(NSString * _Nonnull))authInfo{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"channelCode":@"aiwuyu-app",@"loginDate":DeviceTool.currentDate}];
    
    if (UserManager.userId) {
        dict[@"uid"] = UserManager.userId;
    }
    
    
    [NetworkManager requestWithPath:@"sdkMockApi" name:@"unionLogin" params:dict success:^(NSDictionary * _Nullable responseObject) {
        NSLog(@"responseObject===%@",responseObject);
        
        authInfo(responseObject[@"channelReq"]);
    } failure:^(NSDictionary * _Nullable responseObject, NSError * _Nonnull error) {
        authInfo(@"");
    }];
}


@end
   ```
   
   AwySDKConfig:
   ```
   ///实现AwySDKConfig 协议例子
   @implementation AYSDKConfig

- (BOOL)logEnable{
    return YES;
}

- (BOOL)isEnvironmentDebug{
    return YES;
}

- (BOOL)enableContentShare{
    return YES;
}

- (BOOL)enableUnionAuth{
    return YES;
}

- (BOOL)enableCallAuthInterface{
    return YES;
}

@end
   ```
   
   ```
   ///初始化配置 加进入web
   [AwySDK initializeWithChannelCode:@"aiwuyu-app" delegate:[AYSDKClass shared]];
    AYSDKConfig *config = [[AYSDKConfig alloc] init];
    [AwySDK setConfigWithConfig:config];
    [AwySDK openUrlWithUrlStr:@"https://test-miniprogram-h5.aiwuyu.com/awy/#/index"];
   ```
   
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

###### 2. SDK添加配置信息 AwySDKConfig
通过AwySDK的类方法配置，类方法需要一个遵守AwySDKConfig的类。
func setConfig(config:AwySDKConfig )


###### 3. 使用sdk打开h5链接

Swift:
```AwySDK.openUrl(urlStr: "")```

OC:
```[AwySDK openUrlWithUrlStr:@"url"]```

#### 2. 配置类AwySDKConfig
AwySDKConfig协议介绍：

```
///渠道App是否需要打印log
func logEnable() -> Bool
///环境，true：prd， false：test
func isEnvironmentDebug() -> Bool
///是否支持调用分享
func enableContentShare() -> Bool
///是否支持联合登录
func enableUnionAuth() -> Bool
///联合登录是否支持调起登录页面
func enableCallAuthInterface() -> Bool
```

#### 3. SDK回掉渠道app接口 AwySDKDelegate

###### 1. 签名回调 需要渠道APP 请求 嵌入“爱物语服务器-SDK”的服务器
Swift:
```
func requestUnionAuthInfo(authInfo:((_ str:String)->Void)?)
```
OC:
```
- (void)requestUnionAuthInfoWithAuthInfo:(void (^)(NSString * _Nonnull))authInfo
```

sdk向渠道app请求联合登录参数

渠道方需要使用爱物语server sdk生成联合登录参数，

并通过block异步传递给爱物语sdk

authInfo：在server中获取的登录参数,通过block回调传给sdk。

###### 2. 请求分享
Swift:
```
func requestShare(shareData:AwyShareData)
```
OC:
```
- (Void)requestShareWithShareData:(AwyShareData *)shareData
```

sdk向渠道app请求分享 

AwyShareData：返回sdk要分享的信息（分享标题、内容、链接、图片链接）
返回值：true表示支持通过渠道app分享内容，false表示不支持分享内容 

其中AwyShareData：有获取图片Data格式方法
Swift:
```
func downloadImage(imageBack:@escaping ((_ imageData:Data?)->Void))
```
OC:
```
- (void)downloadImage:(void (^ _Nullable)(NSData * _Nullable))imageBack
```
如果imageData为空，下载图片出错

###### 3.返回是否登录
```
func isAppAuth()->Bool
```
需要实时返回渠道APP，是否已经登录

###### 4. 跳转渠道APP 登录页
```
func requestAuth(nav:UINavigationController)
```
返回 SDK 的UINavigationController 跳转登录页需要用到

## 四. 联合登录整体流程

* 爱物语sdk向渠道app请求联合登录参数

* 如果渠道app是已经登录状态，渠道app向渠道后台请求联合登录参数，如果未登录直接回调sdk null即可

* 渠道后台收到联合登录请求后，调用爱物语server sdk生成联合登录参数，并下发给渠道app

* 渠道app再将参数通过接口回调，传递给sdk

* sdk使用联合登录参数请求爱物语平台登录

* 登录完成
