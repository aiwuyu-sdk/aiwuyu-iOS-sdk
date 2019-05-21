//
//  WYWebSDK.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/4/9.
//  Copyright © 2019 awy. All rights reserved.
//

import UIKit
import WebKit

public class AwySDK: NSObject {

    static let shared = AwySDK()
    var channelCode = ""
    var delegate:AwySDKDelegate?
    weak var webVC:AwyWebViewController?
    var config:AwySDKConfig?
    var appUserAgent = ""

    
    @objc public static func  initialize(channelCode:String,delegate:AwySDKDelegate?){
        shared.channelCode = channelCode
        shared.delegate = delegate
        
    }
    @objc public static func openUrl(urlStr:String){
        let webviews = UIWebView()
        let userAgent = webviews.stringByEvaluatingJavaScript(from: "navigator.userAgent")
        shared.appUserAgent = userAgent ?? ""
        let newUserAgent = "\(String(describing: userAgent))\(AwyWebViewController.userAgent)"
        let dic = ["UserAgent":newUserAgent]
        UserDefaults.standard.register(defaults: dic)
        
        let web = AwyWebViewController(urlStr)
        shared.webVC = web
        let vc = UINavigationController(rootViewController: web)
        awy_topVC()?.present(vc, animated: true, completion: nil)
        
    }
    
    @objc public static func setConfig(config:AwySDKConfig ) {
        AwySDK.shared.config = config
    }
    
    static func log(_ items:Any...){
        if shared.config?.logEnable?() == true {
            print(items)
        }
    }
    
}

