//
//  AwyUnionAuth.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/5/15.
//  Copyright © 2019 awy. All rights reserved.
//

import UIKit

class AwyUnionAuth: NSObject {
    
    static let shared = AwyUnionAuth()
    
    private var timer:Timer?
    private var second = 10
    var userId:String = ""
    var token:String = ""
    
    func beginTimer()  {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeIn), userInfo: nil, repeats: true)
    }
    
    @objc func timeIn()  {
        if second == 0 {
            stopTimer()
        }
        second -= 1
    }
    
    func stopTimer()  {
        timer?.invalidate()
        timer = nil
        second = 10
    }
    
    ///联合登录
    func getUserInfo(_ authInfoBack:(()->Void)?)  {
        beginTimer()
        AwySDK.log("正在进行联合登录……\n")
        AwySDK.shared.delegate?.requestUnionAuthInfo?(authInfo: {[weak self] (str) in
            guard let self = self else{return}
            AwySDK.log("以获取签名信息：\(str)\n")
            self.getSessionTask(str,authInfoBack)
        })
    }
    
    func getRequest(_ str:String)->URLRequest?{
        guard let url = URL(string: Awy_SDK_URL) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        var bodyDict = ["serviceId":"sdkApi.channelLogin"]
        let publicParams = ["reqNo":UUID().uuidString,"reqDate":Date().stringWith(format: "yyyy-MM-dd HH:mm:ss"),"versionCode":AwySDK_Version,"os":"sdk","deviceId":String.getUUID(),"model":AwySDK_iPhoneType,"osVersion":UIDevice.current.systemVersion,"channelReq":str]
        
        if let paramStr = publicParams.toJsonStr{
            bodyDict["param"] = paramStr
            bodyDict.updateValue(paramStr, forKey: "param")
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: bodyDict, options: .prettyPrinted)
            request.httpBody = data
        } catch {
            
        }
        return request
    }
    
    func getSessionTask(_ str:String,_ authInfoBack:(()->Void)?) {
        guard let request = getRequest(str) else {
            AwySDK.log("authInfo Request有误\n")
            authInfoBack?()
            return
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) {[weak self] (data, response, error) in
            guard let self = self else{return}
            if 0 >= self.second{
                AwySDK.log("authInfo Request请求超时\n")
                authInfoBack?()
                return
            }
            
            if let backData = data{
                if let dict = try? JSONSerialization.jsonObject(with: backData, options: []) as? Dictionary<String, Any>{
                    if let code = dict?["code"] as? String , code == "000000"{
                        let enStr = dict?["channelResp"] as? String ?? ""
                        let resultStr = AwyAES128.AES128Decrypt(enStr)
                        let resultDict = resultStr?.toDic
                        let token = resultDict?["token"] as? String ?? ""
                        self.token = token
                        let userId = resultDict?["userId"] as? NSNumber ?? NSNumber(value: -1)
                        self.userId = userId.stringValue
                        AwySDK.log("authInfo信息：\(String(describing: resultDict))\n")
                        authInfoBack?()
                    }else{
                        authInfoBack?()
                        AwySDK.log("authInfo获取失败：\(String(describing: dict))\n")
                    }
                }else{
                    authInfoBack?()
                    AwySDK.log("authInfo返回信息有误\n")
                }
            }
        }
        task.resume()
    }
    
}
