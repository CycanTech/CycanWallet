//
//  YHtmlNativeEntity.h
//  CoinID
//
//  Created by MWTECH on 2019/1/24.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YHtmlChainType) {
    YHtmlChainType_BTC = 1,
    YHtmlChainType_ETH ,
    YHtmlChainType_EOS,
    YHtmlChainType_VNS,
    YHtmlChainType_EHE,
};

@interface YHtmlDetailed :NSObject

@property (nonatomic,copy) NSString * amount ;
@property (nonatomic,copy) NSString * from ;
@property (nonatomic,copy) NSString * contract ;
@property (nonatomic,copy) NSString * decimals ;
@property (nonatomic,copy) NSString * merchantName ;
@property (nonatomic,copy) NSString * symbols ;
@property (nonatomic,copy) NSString * to ;
@property (nonatomic,copy) NSString * memo ;
@property (nonatomic,assign) BOOL istoken ;//是否是代币
@property (nonatomic,assign) double slideValue ; //新增,用于接收滑块的ETH
@property (nonatomic,strong) NSString *  walletID  ;
@property (nonatomic,assign) YHtmlChainType chainType ;
@property (nonatomic,assign) BOOL manualTrigger ;//是否是手动触发选择地址
@property (nonatomic,copy) NSString * bancorConverterAddress ;
@property (nonatomic,copy) NSString * smartTokenAddress ;
@property (nonatomic,copy) NSString * etherTokenAddress ;
@property (nonatomic,assign) NSInteger signtype ;//班科转账
@property (nonatomic,strong) NSString * payAddress ;
@property (nonatomic,copy) NSString * connectorName ;
@property (nonatomic,copy) NSString * tokenName ;


@end


@interface YHtmlJsonDataEntity : NSObject

@property (nonatomic,strong) YHtmlDetailed * info  ;
@property (nonatomic,assign) YHtmlChainType chainType ;

@end

@interface YHtmlNativeEntity : NSObject

@property (nonatomic,strong) YHtmlJsonDataEntity * data ;
@property (nonatomic,copy) NSString * requester ;
@property (nonatomic,assign) int requestType ;

@end

NS_ASSUME_NONNULL_END
