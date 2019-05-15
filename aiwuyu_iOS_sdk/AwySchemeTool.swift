//
//  AwySchemeTool.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/4/9.
//  Copyright © 2019 awy. All rights reserved.
//

import UIKit

class AwySchemeTool: NSObject {
    
    static func parse(_ url:String, toScheme:((_ host:String?,_ params:[String:String])->Void)?) {
        guard let component = URLComponents(string: url) else{
            return
        }
        let host = component.host
        var params = [String:String]()
        let _ = component.queryItems?.compactMap({ (item)  in
            params.updateValue(item.value ?? "", forKey: item.name)
        })
        toScheme?(host,params)
    }
    
    static func urlAnalysis(urlString:String,webVC:AwyWebViewController){
        
        AwySchemeTool.parse(urlString) { (host, params) in
            let function = params["method"]
            let parameters = params["params"] ?? nil
            let paramsDict = parameters?.toDic ?? [String:Any]()
            let config = AwyJSBaseConfig()
            config.webVC = webVC
            AwySDK.log("正在js交互方法:\(String(describing: function)) 参数:\(paramsDict)")
            config.runWithFunction(function ?? "", paramsDict: paramsDict )
            webVC.webView.evaluateJavaScript("bridge.nativeCallComplete()", completionHandler: nil)
        }
        
    }

}
