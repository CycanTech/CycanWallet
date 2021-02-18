//
//  YChainBussiness.h
//  CoinID
//
//  Created by MWTECH on 2019/8/14.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enum.h"


#define VNSChainRequestURL @"https://mainnet-gvns.coinid.pro"
NS_ASSUME_NONNULL_BEGIN

//链的请求
@interface YChainBussiness : NSObject


/// vns
+(void)requestVNSAddresssInfo:(NSString*)from
                           to:(NSString*)to
                     contract:(NSString*)contract
                         data:(NSString*)data
               complationBack:(void(^)(id data,NSInteger code ))complationBack;

+(void)requerstVNSData:(NSString*)result_bytestring complationBack:(void(^)(id data,NSInteger code ))complationBack ;

/**  尝还VUSD中检查提交的数据 */
+(void)parserRepaymentVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;

/**  看是否同意分割 */
+(void)splitRepaymentVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;

/**  关闭Vusd */
+(void)shutDownRepaymentVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;

+(void)queryDebtRelationshipVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;

/**  查询VUSD余额 */
+(void)InquireVusdBalance:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;

+(void)InquireVusdAllBalance:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;

/**  查询隐含VUSD所有余额 */
+(void)queryImpliedVusdAllBalance:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;

/**  奖金allowance */
+(void)InquireBonusAllBalance:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;

+(void)queryLinkSpatVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;

/**  查询gem */
+(void)InquireHGem:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack;


@end

NS_ASSUME_NONNULL_END
