//
//  hw_keychain.swift
//  Runner
//
//  Created by MWT on 21/10/2020.
//

import Foundation

class hw_keychain: NSObject {
    
    static func saveData(value:String)-> Void {
        
        let key = Bundle.main.bundleIdentifier!
        let valueData = value.data(using: String.Encoding.utf8,allowLossyConversion: false)
        let service = Bundle.main.bundleIdentifier!
        let secItem = [
            kSecClass as NSString:kSecClassGenericPassword as String,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecValueData as String : valueData!
            ] as NSDictionary
        var requestResult : AnyObject?
        let status = Int(SecItemAdd(secItem,&requestResult))
        switch status {
        case Int(errSecSuccess):
            print("成功")
        case Int(errSecDuplicateItem):
            print("重复插入")
        default:
            print("error")
        }
    }
    
    static func queryData()-> String {
        let key = Bundle.main.bundleIdentifier!
        let service = Bundle.main.bundleIdentifier!
        let query = [
            kSecClass as NSString:kSecClassGenericPassword as String,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecReturnData as String : kCFBooleanTrue as Any,
            ] as NSDictionary
        var valueAttributes : AnyObject?
        let results = SecItemCopyMatching(query, &valueAttributes)
        if results == Int(errSecSuccess) {
            if let resultsData = valueAttributes as? Data{
                let value = String(data: resultsData, encoding: String.Encoding.utf8)
                print("----------------------------    \(value)")
                return value!
            }
        }
        return ""
    }
}
