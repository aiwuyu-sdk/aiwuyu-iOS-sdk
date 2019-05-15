//
//  AwySDKConfig.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/5/14.
//  Copyright © 2019 awy. All rights reserved.
//

import UIKit

@objc public protocol AwySDKConfig:NSObjectProtocol {
    ///是否支持log打印
    @objc optional func logEnable() -> Bool
    ///环境，true：prd， false：test
    @objc optional func isEnvironmentDebug() -> Bool
    ///是否支持调用分享
    @objc optional func enableContentShare() -> Bool
    ///是否支持联合登录
    @objc optional func enableUnionAuth() -> Bool
    ///联合登录是否支持调起登录页面
    @objc optional func enableCallAuthInterface() -> Bool
}


