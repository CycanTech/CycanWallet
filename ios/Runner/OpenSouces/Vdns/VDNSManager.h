//
//  VDNSManager.h
//  CoinID
//
//  Created by MWTECH on 2019/10/23.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,VDNSRequestCode) {
  
    /**  设置地址权限 */
    VDNSRequestCode_SetAddress_Permissions = 0 ,
    /**  注册一级域名 */
    VDNSRequestCode_PayTopLevel = 1 ,
    /**  域名的续费 */
    VDNSRequestCode_Renew  = 2,
    /**  添加子域名 */
    VDNSRequestCode_PaySubLevel = 3,
    /**  转让 */
    VDNSRequestCode_SetController = 4,
    /**  点击复制 */
    VDNSRequestCode_ClickCopy = 5,
    /**  点击扫码 */
    VDNSRequestCode_ScanAddress = 6,
    /**  更新地址 */
    VDNSRequestCode_UpdateAddress = 7,
    /**  删除二级域名 */
    VDNSRequestCode_DelSubLevel = 8 ,
    
//    /**  注册一级域名 */
//    VDNSRequestCode_Pay_Deposit = 1 ,
//    /**  注册域名的支付尾款 */
//    VDNSRequestCode_Pay_Tail,
//    /**  域名的续费 */
//    VDNSRequestCode_Renew,
//    /**  支付购买子域名的费用 */
//    VDNSRequestCode_Sub_Name,
};

@interface VDNSPopModel : NSObject

@property (nonatomic,assign) VDNSRequestCode num ;  //请求类型
@property (nonatomic,copy)   NSString * year ;     //购买时间
@property (nonatomic,copy)   NSString * payNum ;    //支付金额
@property (nonatomic,copy)   NSString * payType ;   //支付代币名称 VNS VP
@property (nonatomic,copy)   NSString * vnsyuming;  //域名名字
@property (nonatomic,assign) NSInteger secrecy ;   //1 隐藏   0 公开
@property (nonatomic,copy)   NSString * payAddress ;
@property (nonatomic,copy)   NSString * contract ;  //合约
@property (nonatomic,copy)   NSString * strCopy;
@property (nonatomic,copy)   NSString * son ;
@property (nonatomic,copy)   NSString * type ;
@property (nonatomic,copy)   NSString * address ;
@property (nonatomic,copy)   NSString * father;

@property (nonatomic,copy)   NSString * from ;
@property (nonatomic,copy)   NSString * to ;
@property (nonatomic,copy)   NSString * anAddress ;
@property (nonatomic,copy)   NSString * yuming ;


@end


@interface VDNSManager : NSObject<WKUIDelegate>

+(instancetype)shareManagerWithContainerVC:(UIViewController*)vc webView:(WKWebView*)webView defalutObject:(id)walletObject;
@end

NS_ASSUME_NONNULL_END
