//
//  AwyJSBaseConfig.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/4/9.
//  Copyright © 2019 awy. All rights reserved.
//

import UIKit
import Photos


class AwyJSBaseConfig: NSObject {
    
    weak var webVC:AwyWebViewController?
    var saveDict:[String:Any]?
    
    enum PluginCallback {
        case success
        case failure
    }
    
    
    func runWithFunction(_ functionString:String,paramsDict:[String:Any])  {
        
        let function = "\(functionString):"
        let sel = NSSelectorFromString(function)
        if self.responds(to: sel) {
            self.perform(sel, with: paramsDict)
        }
    }
    ///
    @objc func getUserInfo(_ paramsDict:[String:Any]){
        let userId = AwyUnionAuth.shared.userId
        let token = AwyUnionAuth.shared.token
        
        if userId != "",
            token != ""{
            AwySDK.log("以获取过登录, 直接返回结果\n")
            getUserInfoBack(paramsDict)
        }else{
            if AwySDK.shared.config?.enableUnionAuth?() == true && AwySDK.shared.delegate?.isAppAuth?() == true{
                ///联合登录
                AwySDK.log("支持联合登录, 并且已经登录, 尝试获取登录结果……\n")
                AwyUnionAuth.shared.getUserInfo {
                    AwySDK.log("支持联合登录 正在返回结果……\n")
                    self.getUserInfoBack(paramsDict)
                }
                
            }else{
                AwySDK.log("不支持联合登录, 返回结果……\n")
                getUserInfoBack(paramsDict)
            }
        }
        
    }
    
    
    func goLoginBack(_ paramsDict:[String:Any])  {
        if let nav = webVC?.navigationController{
            webVC?.authInfo = {
                self.getUserInfoBack(paramsDict)
            }
            webVC?.isToLogin = true
            AwySDK.shared.delegate?.requestAuth?(nav: nav)
        }
    }
    
    
    func getUserInfoBack(_ paramsDict:[String:Any])  {
        var callbackId:NSNumber?
        var response:[String:String]
        let userId = AwyUnionAuth.shared.userId
        let token = AwyUnionAuth.shared.token
        let supportAppAuth:String
        if AwySDK.shared.config?.enableUnionAuth?() == true && AwySDK.shared.config?.enableCallAuthInterface?() == true{
            supportAppAuth = "1"
        }else{
            supportAppAuth = "0"
        }
        if userId != "" && token != ""{
            callbackId = paramsDict["success"] as? NSNumber
            response = ["userId":userId,"token":token]
        }else{
            callbackId = paramsDict["fail"] as? NSNumber
            response = ["supportAppAuth":supportAppAuth,"userId":"","token":""]
        }
        let jsString = self.assembledJS(paramsDict, response, callbackId)
        self.webVC?.invokeJS(jsString)
    }
    
    func signOut()  {
        let action = UIAlertAction(title: "确定", style: .default) { (_) in
            self.webVC?.dismiss(animated: true, completion: nil)
            
        }
        let alert = UIAlertController(title: "提示", message: "您的登录已失效，请退出后重试", preferredStyle: .alert)
        alert.addAction(action)
        webVC?.present(alert, animated: true, completion: nil)
        
        
    }
    
    @objc func goLogin(_ paramsDict:[String:Any]){
        if let force = paramsDict["isForce"] as? Int,force == 1 {
            AwyUnionAuth.shared.userId = ""
            AwyUnionAuth.shared.token = ""
            signOut()
            return
        }
        let userId = AwyUnionAuth.shared.userId
        let token = AwyUnionAuth.shared.token
        if userId != "",
            token != ""{
            goLoginResult(paramsDict)
        }else{
            if AwySDK.shared.config?.enableUnionAuth?() == true  {
                if AwySDK.shared.delegate?.isAppAuth?() == true {
                    ///联合登录
                    AwySDK.log("支持联合登录并且已经登录……\n")
                    AwyUnionAuth.shared.getUserInfo {
                        self.goLoginResult(paramsDict)
                    }
                    
                }else{
                    AwySDK.log("支持联合登录,但是没有登录……\n")
                    if AwySDK.shared.config?.enableCallAuthInterface?() == true{
                        AwySDK.log("支持联合登录, 没有登录, 支持APP登录, 去登录……\n")
                        goLoginBack(paramsDict)
                        
                    }else{
                        AwySDK.log("支持联合登录, 没有登录, 不支持APP登录 正在返回结果……\n")
                        goLoginResult(paramsDict)
                    }
                    
                }
                
            }else{
                AwySDK.log("不支持联合登录, 没有登录, 正在返回结果……\n")
                goLoginResult(paramsDict)
            }
        }
    }
    
    func goLoginResult(_ paramsDict:[String:Any])  {
        var callbackId:NSNumber?
        var response:[String:String]
        let userId = AwyUnionAuth.shared.userId
        let token = AwyUnionAuth.shared.token
        let supportAppAuth:String
        if AwySDK.shared.config?.enableUnionAuth?() == true && AwySDK.shared.config?.enableCallAuthInterface?() == true{
            supportAppAuth = "1"
        }else{
            supportAppAuth = "0"
        }
        if userId != "" && token != ""{
            callbackId = paramsDict["success"] as? NSNumber
            response = ["message":"登录成功","userId":userId,"token":token]
        }else{
            callbackId = paramsDict["fail"] as? NSNumber
            response = ["supportAppAuth":supportAppAuth,"message":"未登录","userId":"","token":""]
        }
        
        let jsString = self.assembledJS(paramsDict, response, callbackId)
        self.webVC?.invokeJS(jsString)
    }
    
    
    
    @objc func close(_ paramsDict:[String:Any]){
        webVC?.navigationController?.popViewController(animated: true)
    }
    
    @objc func setRightNaviItem(_ paramsDict:[String:Any]){
        let funcName = paramsDict["funcName"] as? String
        if let icon = paramsDict["icon"] as? String,let data = Data(base64Encoded: icon, options: .ignoreUnknownCharacters){
            let image = UIImage(data: data)
            webVC?.setRightItem(image, funcName: funcName ?? "")
            return
        }
        
        if let title = paramsDict["title"] as? String{
            webVC?.setRightItem(title, funcName: funcName ?? "")
        }
        
    }
    
    @objc func hideRightNaviItem(_ paramsDict:[String:Any]){
        self.webVC?.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func share(_ paramsDict:[String:Any]){
        let title = paramsDict["title"] as? String
        let content = paramsDict["content"] as? String
        let url = paramsDict["url"] as? String
        let imageUrl = paramsDict["imageUrl"] as? String
        let model = AwyShareData(title: title, content: content, shareUrl: url, imageUrl: imageUrl)
        let isExistence = AwySDK.shared.config?.enableContentShare?() ?? false
        if isExistence == false{
            let alert = UIAlertController(title: "分享", message: "请复制链接，然后粘贴分享给好友吧！", preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            let action = UIAlertAction(title: "复制", style: .default) { (al) in
                
                let dict = ["text":(url ?? "")]
                self.copyText(dict)
            }
            alert.addAction(cancleAction)
            alert.addAction(action)
            webVC?.present(alert, animated: true, completion: nil)
        }else{
            AwySDK.shared.delegate?.requestShare?(shareData: model)
        }
        
    }
    
    @objc func save2Gallery(_ paramsDict:[String:Any]){
        guard let imageBase64 = paramsDict["image"] as? String ,
              let data = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters),
              let image = UIImage(data: data) else {
            return
        }
        let status = PHPhotoLibrary.authorizationStatus()
        saveDict = paramsDict
        saveDict?.removeValue(forKey: "image")
        
        if status == .notDetermined{
            PHPhotoLibrary.requestAuthorization { (status) in
                
                if status == .authorized{
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(AwyJSBaseConfig.image(image:didFinishSavingWithError:contextInfo:)), nil)
                }
                
            }
        }else if status == .authorized{
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(AwyJSBaseConfig.image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:UnsafeMutableRawPointer?){
        let dict = saveDict ?? [String:Any]()
        if error == nil {
            callBackJSInvoke(param: dict, response: ["message":"保存成功"], type: .success)
            webVC?.toToast("保存成功")
        }else{
            callBackJSInvoke(param: dict, response: ["message":"保存失败"], type: .failure)
            webVC?.toToast("保存失败")
        }
        
    }
    
    func callBackJSInvoke(param:[String:Any],response:[String:Any],type:PluginCallback)  {
        var callbackId:NSNumber?
        if type == .success {
            callbackId = param["success"] as? NSNumber
        }else{
            callbackId = param["fail"] as? NSNumber
        }
        let jsString = assembledJS(param, response, callbackId)
        webVC?.invokeJS(jsString)
    }
    
    func assembledJS(_ params:[String:Any],_ response:[String:Any],_ callbackId:NSNumber?) ->String  {
        let pre = "bridge.invokeJs('"
        let last = "')"
        if response.count > 0 {
            
            if let callBackId = callbackId{
                let result:[String : Any] = ["response":response,"callbackId":callBackId]
                if JSONSerialization.isValidJSONObject(result){
                    if let messageJSON = result.toJsonStr{
                        return pre+messageJSON+last
                    }
                    
                }else{
                    let failCallbackId = params["fail"] as? NSNumber
                    return assembledJS(params, ["message":"native convert json error"], failCallbackId)
                }
            }
        }
        return pre+last
    }
    
    
    @objc func copyText(_ paramsDict:[String:Any]){
        
        UIPasteboard.general.string = paramsDict["text"] as? String
        webVC?.toToast("复制成功")
    }
    
    @objc func getChannelCode(_ paramsDict:[String:Any]){
        let callbackId = paramsDict["success"] as? NSNumber
        var jsString = assembledJS(paramsDict, ["channelCode":AwySDK.shared.channelCode], callbackId)
        
        jsString = jsString.replacingOccurrences(of: "\n", with: "")
        
        webVC?.invokeJS(jsString)
    }
    
    @objc func getDeviceId(_ paramsDict:[String:Any]){
        let callbackId = paramsDict["success"] as? NSNumber
        let jsString = assembledJS(paramsDict, ["deviceId":String.getUUID()], callbackId)
        webVC?.invokeJS(jsString)
    }

}
