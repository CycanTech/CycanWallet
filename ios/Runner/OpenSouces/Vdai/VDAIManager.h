//
//  VDAIManager.h
//  CoinID
//
//  Created by 新明华区块链技术（深圳）有限公司 on 2019/11/13.
//  Copyright © 2019年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,VDAIRequestCode) {

    /**  vusd 查询地址*/
    VDAIRequestCode_Vusd_create_address = 0,
    /**  vusd 创建 */
    VDAIRequestCode_Vusd_create = 1,
    /**  CDP资产管理 */
    VDAIRequestCode_Vusd_CdpAssetManagemente = 2,
    /**  存入VNS */
    VDAIRequestCode_Vusd_DepositVNS = 3,
    /**  取回VNS */
    VDAIRequestCode_Vusd_RetrieveVNS =  4,
    /**  偿还VUSD */
    VDAIRequestCode_Vusd_RepayVUSD= 5,
    /**  生成VUSD */
    VDAIRequestCode_Vusd_GenerateVUSD = 6,
    /**  转移VUSD */
    VDAIRequestCode_Vusd_transferVUSD = 7,
    /**  关闭VUSD */
    VDAIRequestCode_Vusd_shutDownVUSD = 8,
    /**  同意转移 */
    VDAIRequestCode_Vusd_AgreeTransfer = 9,
    /**  vns转账 */
    VDAIRequestCode_Vns_Transfer = 10,
    /**  vusd转账 */
    VDAIRequestCode_Vusd_Transfer = 11,
    /**  复制地址 */
    VDAIRequestCode_Vusd_Copy = 12,
};

@interface VDAIPopModel : NSObject

@property (nonatomic,assign) VDAIRequestCode num ;  //请求类型
@property (nonatomic,copy)   NSString * payNum ;    //支付金额
@property (nonatomic,copy)   NSString * vnsNum ;    
@property (nonatomic,copy)   NSString * vusdNum ;
@property (nonatomic,copy)   NSString * payType ;   //交易类型
@property (nonatomic,copy)   NSString * payAddress ; //选中的vns地址
@property (nonatomic,copy)   NSString * contract ;  //合约
@property (nonatomic,copy)   NSString * symbol ;//单位
@property (nonatomic,copy)   NSString * type ;
@property (nonatomic,copy)   NSString * toAddress ;
@property (nonatomic,copy)   NSString * vusdBalance;
@property (nonatomic,copy)   NSString * replicateAddress;
@property (nonatomic,copy)   NSString * transferVusdAddreess ;//转移vusd地址
@property (nonatomic,copy)   NSString * vusdAllBalance ;//转移vusd所有的余额
@property (nonatomic,assign) BOOL isToken;
@property (nonatomic,strong)  NSMutableDictionary * transferVusdDic ;

@end

@interface VDAIManager : NSObject<WKUIDelegate>

+(instancetype)shareManagerWithContainerVC:(UIViewController*)vc webView:(WKWebView*)webView defalutObject:(id)walletObject;
-(void)requestVNSAddresssInfo:(NSString*)address contract:(NSString*)contract complationBack:(void(^)(void))complationBac;
-(void)getVNSTransInfo:(VDAIPopModel*)model;

@end

NS_ASSUME_NONNULL_END
