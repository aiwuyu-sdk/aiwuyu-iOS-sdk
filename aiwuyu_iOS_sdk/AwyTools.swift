//
//  AwyTools.swift
//  aiwuyu_iOS_sdk
//
//  Created by QC on 2019/4/15.
//  Copyright © 2019 awy. All rights reserved.
//

import UIKit
import CommonCrypto


let kInitVector = "1234567812345678"


public class AwyAES128 {
    public static func AES128Encrypt(_ content:String) -> String? {
        
        guard var contentData = content.data(using: .utf8),
            let spaceData = " ".data(using: .utf8),
            let dataVector = kInitVector.data(using: .utf8),
            let keyData = Awy_SDK_AES_KEY.data(using: .utf8) else{return nil}
        while contentData.count % 16 != 0{
            contentData.append(spaceData)
        }
        let contentNSData = NSData(data: contentData)
        let keyNSData = NSData(data: keyData)
        
        let encryptSize = contentNSData.length + kCCBlockSizeAES128
        let encryptedBytes = UnsafeMutableRawPointer.allocate(byteCount: encryptSize, alignment: 1)
        defer{
            free(encryptedBytes)
        }
        var returnSize = 0
        
        let status = CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES128), 0, keyNSData.bytes, kCCBlockSizeAES128, NSData(data: dataVector).bytes, contentNSData.bytes, contentNSData.length, encryptedBytes, encryptSize, &returnSize)
        
        if status == kCCSuccess {
            let returnData = Data(bytes: encryptedBytes, count: returnSize)
            let returnStr = returnData.base64EncodedString(options: .endLineWithCarriageReturn)
            return returnStr
        }
        return nil
    }
    
    
    public static func AES128Decrypt(_ content:String) -> String? {
        
        guard var contentData = NSData(base64Encoded: content, options: .ignoreUnknownCharacters),
            let dataVector = kInitVector.data(using: .utf8),
            let keyData = Awy_SDK_AES_KEY.data(using: .utf8) else{return nil}
        
        let keyPtr = NSData(data: keyData)
        let bufferSize = contentData.length + kCCBlockSizeAES128
        var dataOut = UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: 1)
        var numBytes = 0
        defer{
            free(dataOut)
        }
        
        let status = CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES128), 0, keyPtr.bytes, kCCBlockSizeAES128, NSData(data: dataVector).bytes, contentData.bytes, contentData.length, dataOut, bufferSize, &numBytes)
        
        if status == kCCSuccess {
            let resultData = Data(bytes: dataOut, count: numBytes)
            return String(data: resultData, encoding: .utf8)
        }
        return nil
    }
}



class AwyKeyChain {
    
    
    static func addItem(_ str:String,service:String)  {
        guard let data = str.data(using: .utf8) else {
            return
        }
        //        let service = "aiwuyu_iOS_sdkServiceUUID"
        var dict = [kSecClass:kSecClassGenericPassword,kSecAttrService:service,kSecAttrAccount:service,kSecAttrAccessible:kSecAttrAccessibleAfterFirstUnlock] as [CFString : Any]
        SecItemDelete(dict as CFDictionary)
        dict.updateValue(data, forKey: kSecValueData)
        SecItemAdd(dict as CFDictionary, nil)
        
    }
    
    static func quaryItem(service:String) -> String? {
        //        let service = "aiwuyu_iOS_sdkService"
        var dict = [kSecClass:kSecClassGenericPassword,kSecAttrService:service,kSecAttrAccount:service,kSecAttrAccessible:kSecAttrAccessibleAfterFirstUnlock] as [CFString : Any]
        dict.updateValue(kCFBooleanTrue!, forKey: kSecReturnData)
        dict.updateValue(kSecMatchLimitOne, forKey: kSecMatchLimit)
        let ptr = UnsafeMutablePointer<CFTypeRef?>.allocate(capacity: 1)
        defer {
            free(ptr)
        }
        if SecItemCopyMatching(dict as CFDictionary, ptr) == noErr {
            if let data = ptr.pointee as? Data{
                let result = String(data: data, encoding: .utf8)
                return result
            }
        }
        
        return nil
    }
    
    static func delete(service:String)  {
        //        let service = "aiwuyu_iOS_sdkService"
        let dict = [kSecClass:kSecClassGenericPassword,kSecAttrService:service,kSecAttrAccount:service,kSecAttrAccessible:kSecAttrAccessibleAfterFirstUnlock] as [CFString : Any]
        SecItemDelete(dict as CFDictionary)
    }
    
    
    
}


