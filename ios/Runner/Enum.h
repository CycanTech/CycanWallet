//
//  Enum.h
//  Runner
//
//  Created by MWT on 27/7/2020.
//

#ifndef Enum_h
#define Enum_h

//交易币的类型
typedef NS_ENUM(NSInteger,MCoinType) {
  MCoinType_All,
  MCoinType_BTC,
  MCoinType_ETH,
  MCoinType_EOS,
  MCoinType_VNS,
  MCoinType_BTM,
  MCoinType_LTC,
  MCoinType_USDT,
  MCoinType_GPS,
  MCoinType_DOT,
};

typedef NS_ENUM(NSInteger,MLeadWalletType) {
    MLeadWalletType_PrvKey,
    MLeadWalletType_KeyStore,
    /**  COINID专用助记词 */
    MLeadWalletType_Memo,
    /**  标准助记词 */
    MLeadWalletType_StandardMemo,
};

typedef NS_ENUM(NSInteger,MOriginType) {
    MOriginType_Create, //创建
    MOriginType_Restore, //恢复
    MOriginType_LeadIn, //导入
    MOriginType_Colds, //冷
    MOriginType_NFC, //nfc
    MOriginType_MultiSign, //预留多签
};

//助记词类型
typedef NS_ENUM(NSInteger,MMemoType) {
    MMemoType_Chinese,
    MMemoType_English ,
};

//助记词个数
typedef NS_ENUM(NSInteger,MMemoCount) {
    MMemoCount_12  = 12,
    MMemoCount_18  = 18,
    MMemoCount_24  = 24,
};

typedef NS_ENUM(NSInteger,URLLoadType) {
  
    URLLoadType_Links,
    URLLoadType_Bancor,
    URLLoadType_DomainName,
    URLLoadType_VUSD
};

typedef NS_ENUM(NSInteger,YVerifyPasswordState) {
    //cancle
    //wrong
    //ok
    YVerifyPasswordState_Cancle,
    YVerifyPasswordState_Wrong,
    YVerifyPasswordState_Ok,
};

//主屏宽
#define KSCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
//主屏高
#define KSCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#if (defined(DEBUG))
#define NSLog(format, ...) printf("class(类名): <%p %s:(第%d行) > method(方法名): %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define NSLog(format, ...)
#endif

#define IS_IPHONE_4_OR_LESS (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)
//判断是否是iPhone5
#define IS_IPHONE_5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
//判断是否是iPhone6
#define IS_IPHONE_6 (([[UIScreen mainScreen] bounds].size.height-667)?NO:YES)
//判断是否是iPhone6plush
#define IS_IPHONE_6P (([[UIScreen mainScreen] bounds].size.height-736)?NO:YES)
//判断是否是iPhoneX
#define IS_IPHONEX (([[UIScreen mainScreen] bounds].size.height-812)?NO:YES)

#define ADAPTATIONIPHeight(Height) [YCommonMethods adaptationIphone6Height:Height]

/**根据6为标准适配 宽*/
#define ADAPTATIONIPHWidth(Width) [YCommonMethods adaptationIphone6Width:Width]

#define WEAK(obj) __weak typeof(obj) weakObject = obj;
#define STRONG(obj) __strong typeof(obj) strongObject = weakObject;

#define ClearBackColor [UIColor clearColor]
#define fontWhiteColor [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]
#define MainColor [UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0]
#define SecondColor [UIColor colorWithRed:172/255.0 green:187/255.0 blue:207/255.0 alpha:1.0]
#define LineBackgroundColor [YCommonMethods colorWithHexString:@"#2C2C2C"]
#define NewTextColor [YCommonMethods colorWithHexString:@"#586883"]
#define NewBackColor [UIColor colorWithRed:246/255.0 green:249/255.0 blue:252/255.0 alpha:1]
#define Font_Regular @"PingFangSC-Regular"
#define Font_Medium @"PingFangSC-Medium"
#define Font_Semibold @"PingFangSC-Semibold"
#define LBXScan_Define_UI 

typedef NS_ENUM(NSInteger,VNSSignType) {

    VNSSignType_VNS,    //vns 主币交易

    VNSSignType_TOKEN,  //vns 代币交易

    VNSSignType_BANCORBUY,  //班科买

    VNSSignType_BANCORSELL, //班科卖
    
    VNSSignType_CrossChainGPSAuthorization,//跨链VNS转GPS授权
    
    VNSSignType_CrossChainGPS,//跨链VNS转GPS实际转账
    
    VNSSignType_CrossChainAllowance ,//获得已经授权的
    
    /**  vdns 注册一级域名 */
    VNSSignType_Vdns_PayTopLevel,
    /**  vdns 续费 */
    VNSSignType_Vdns_Renew,
    /**  vdns 注册子域名 */
    VNSSignType_Vdns_PaySubLevel,
    /**  vdns 转让 */
    VNSSignType_Vdns_SetController,
    /**  删除二级域名 */
    VNSSignType_Vdns_DelSubLevel,
    VNSSignType_NewMultisign , //发起多签钱包交易
    VNSSignType_JoinOwner , //参与者加入
    VNSSignType_MCoinSign , //提交主币交易
    VNSSignType_MTokenSign ,//提交代币交易
    VNSSignType_MConfirmTrans ,//确认交易
    /**  vusd 创建 */
    VNSSignType_Vusd_create,
    /**  CDP资产管理 */
    VNSSignType_Vusd_CdpAssetManagemente,
    /**  是否同意分割 0：代表没有分割 1：代表已经分割*/
    VNSSignType_Vusd_create_Segmentation_No,
    /**  存入VNS */
    VNSSignType_Vusd_DepositVNS,
    /**  存入VNS frobt*/
    VNSSignType_Vusd_DepositVNS_frobt,
    /**  取回VNS */
    VNSSignType_Vusd_RetrieveVNS,
    /**  取回VNS exit*/
    VNSSignType_Vusd_RetrieveVNS_exit,
    //不足的时候
    VNSSignType_Vusd_RepayVUSD_Approve,
    //足够的时候
    VNSSignType_Vusd_RepayVUSD_Join,
    /**  偿还VUSD */
    VNSSignType_Vusd_RepayVUSD_Frobt,
    /**  奖金 */
    VNSSignType_Vusd_Bonus_Approve,
    VNSSignType_Vusd_Bonus_Approve_FuYi,
     VNSSignType_Vusd_Bonus_Grep,
    /**  生成VUSD */
    VNSSignType_Vusd_GenerateVUSD,
    /**  是否同意分割 0：代表没有分割 1：代表已经分割*/
    VNSSignType_Vusd_GenerateVUSD_Segmentation_Yes,
    VNSSignType_Vusd_GenerateVUSD_Segmentation_No,
    /**  转移VUSD */
    VNSSignType_Vusd_transferVUSD_Hope,
    VNSSignType_Vusd_transferVUSD,
    /**  关闭VUSD */
    VNSSignType_Vusd_shutDownVUSD_Approve, //approve
    VNSSignType_Vusd_shutDownVUSD_Join,//join
    VNSSignType_Vusd_shutDownVUSD_frobt,//frobt
    VNSSignType_Vusd_shutDownVUSD_Exit,//exit取出
    VNSSignType_Vusd_shutDownVUSD_Exit_Gem,//exit取出
    /**  vns 代币交易 */
    VNSSignType_TOKEN_Vusd,  //vns 代币交易
    
    //approve
    VNSSignType_Approve,//ffffffff
    VNSSignType_ApproveReset,//000000
    VNSSignType_Allowance,
};

#define YLOCALIZED_UserVC(key) NSLocalizedStringFromTableInBundle(key, @"UserVC",[YCommonMethods fetchCurrentLanguageBundle], nil)

#endif /* Enum_h */
