//
//  AwyShareData.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/4/9.
//  Copyright © 2019 awy. All rights reserved.
//

import Foundation

@objc public protocol AwySDKDelegate:NSObjectProtocol {
//    @objc optional func requestAuth(authInfo:((_ str:String)->Void)?)
    @objc optional func requestShare(shareData:AwyShareData)
    @objc optional func isAppAuth()->Bool
    @objc optional func requestAuth(nav:UINavigationController)
    @objc optional func requestUnionAuthInfo(authInfo:((_ str:String)->Void)?)
}

@objc public class AwyShareData: NSObject {
    ///分享标题
    @objc open var title:String = ""
    ///分享描述
    @objc open var content:String = ""
    ///分享链接url
    @objc open var shareUrl:String = ""
    ///分享图标url
    @objc open var imageUrl:String = ""
    
    public init(title:String?,content:String?,shareUrl:String?,imageUrl:String?) {
        super.init()
        self.title = title ?? ""
        self.content = content ?? ""
        self.shareUrl = shareUrl ?? ""
        self.imageUrl = imageUrl ?? ""
    }
    
    ///下载icon图片方法 异步返回 图片Data格式 如果 有错返回nil
    @objc public func downloadImage(_ imageBack:((_ imageData:Data?)->Void)?)  {
        guard let url = URL(string: imageUrl) else {
            imageBack?(nil)
            return
        }
        
        let session = URLSession(configuration: .default)
        session.downloadTask(with: url) { (imageUrl, response, error) in
            let data:Data?
            if let path = imageUrl{
                data = try? Data(contentsOf: path)
            }else{
                data = nil
            }
            imageBack?(data)
            }.resume()
        
    }
    
}
