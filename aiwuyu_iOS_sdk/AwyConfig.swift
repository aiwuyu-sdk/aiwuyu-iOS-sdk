//
//  WYConfig.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/4/9.
//  Copyright © 2019 awy. All rights reserved.
//

import UIKit

let Awy_ServiceId = "sdkApi.channelLogin"
let Awy_APP_Handler = "AWY_APP_Handler"

var Awy_SDK_URL:String{
    if AwySDK.shared.config?.isEnvironmentDebug?() == true{
        return "http://test-gateway.aiwuyu.cn:8080/sdkapi/invoke"
    }else{
        return "https://prd-gateway.aiwuyu.com/sdkapi/invoke"
    }
}

var Awy_SDK_AES_KEY:String{
    if AwySDK.shared.config?.isEnvironmentDebug?() == true {
        return "xkuCygu8HHsdkdev"
    }else{
        return "gYVYcGZ03oc0jJMA"
    }
}
let Awy_Color01 = UIColor(0xFF3433)
//适配iPhone X高度
let Awy_NavTopHeight:CGFloat = UIApplication.shared.statusBarFrame.height+44
//iPhone X底部安全区域
let Awy_TabBarHeight:CGFloat = UIApplication.shared.statusBarFrame.height > 20 ? 34:0

let Awy_Screen_Width = UIScreen.main.bounds.width
let Awy_Screen_Height = UIScreen.main.bounds.height

let AwySDK_Version:String = {
    let dic = Bundle(for: AwySDK.self).infoDictionary
    if let short = dic?["CFBundleShortVersionString"] as? String {
        return short.replacingOccurrences(of: ".", with: "")
    }else{
        return "Unknown"
    }
}()

var AwySDK_iPhoneType:String{
    var systemInfo = utsname()
    uname(&systemInfo)
    let platform = withUnsafePointer(to: &systemInfo.machine.0) { (ptr)  in
        return String(cString: ptr)
    }
    return platform
}

var awy_getBundle:Bundle?{
    let bundle = Bundle(for: AwySDK.self)
    if let path = bundle.path(forResource: "awySDK", ofType: "bundle"){
        return Bundle(path: path)
    }
    return nil
}

func awy_image(_ imageName:String) -> UIImage? {
    guard let bundle = awy_getBundle else {
        return nil
    }
    if let path = bundle.path(forResource: imageName, ofType: "png"){
        return UIImage(contentsOfFile: path)
    }
    return nil
}

func awy_topVC(_ vc:UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    guard let controller = vc else {
        return nil
    }
    if let baseVC = controller.presentedViewController{
        return  awy_topVC(baseVC)
    }
    if let baseVC = vc as? UISplitViewController{
        if baseVC.viewControllers.count > 0{
            return awy_topVC(baseVC.viewControllers.last)
        }else{
            return baseVC
        }
    }
    if let baseVC = vc as? UINavigationController {
        if baseVC.viewControllers.count > 0{
            return awy_topVC(baseVC.topViewController)
        }else{
            return baseVC
        }
    }
    if let baseVC = vc as? UITabBarController,let vcs = baseVC.viewControllers{
        if vcs.count > 0{
            return awy_topVC(baseVC.selectedViewController)
        }else{
            return baseVC
        }
    }
    return vc
    
}

extension UIColor{
    convenience init(_ rgb: UInt,alp:CGFloat = 1.0) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alp
        )
    }
}

extension Dictionary{
    var toJsonStr:String?{
        do{
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            
            let str = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "")
            return str
        }catch{
            return nil
        }
    }
}

extension String{
    func sizeOfFont(_ fontSize:CGFloat,_ width:CGFloat)->CGSize{
        let text:NSString = NSString(string: self)
        let rect:CGRect = text.boundingRect(with: CGSize(width: width, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: fontSize)], context: nil)
        return rect.size
    }
    var toDic:Dictionary<String, Any>?{
        guard let dicStr = self.removingPercentEncoding,let data = dicStr.data(using: String.Encoding.utf8) else {
            if let d = self.data(using: .utf8){
                do{
                    let object = try JSONSerialization.jsonObject(with: d, options: .mutableContainers)
                    return object as? Dictionary
                }catch{
                    return nil
                }
            }
            
            return nil
        }
        do{
            let object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return object as? Dictionary
        }catch{
            return nil
        }
    }
    
    public static func getUUID()->String{
        let service = "aiwuyu_iOS_sdkServiceUUID"
        if let str = AwyKeyChain.quaryItem(service: service) {
            return str
        }
        let uuid = UUID().uuidString
        AwyKeyChain.addItem(uuid, service: service)
        return uuid
    }
}

extension UIImage{
    func resizeImage(_ width:CGFloat)->UIImage?{
        let scaleHeight = width/self.size.width*self.size.height
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: scaleHeight), false, 3.0)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: scaleHeight))
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaleImage
    }
}

extension Date{
    func stringWith(format: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        dateformatter.timeZone = TimeZone.current
        let result = dateformatter.string(from: self)
        return result
    }
}

extension UIImage{
    convenience init?(_ pathName:String) {
        guard let closePath = Bundle(for: AwySDK.self).path(forResource: pathName, ofType: "png") else {
            return nil
        }
        self.init(contentsOfFile: closePath)
    }
}
