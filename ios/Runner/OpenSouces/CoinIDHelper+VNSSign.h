//
//  CoinIDHelper+VNSSign.h
//  CoinID
//
//  Created by MWTECH on 2019/4/16.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "CoinIDHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoinIDHelper (VNSSign)

+(id)importVNSWallet:(ImportObject * )object ;

+ (NSString*)vnsHotSignTransWithNonce:(NSString*)nonce
                             gasPrice:(NSString*)gasPrice
                             gasLimit:(NSString*)gasLimit
                                   to:(NSString*)to
                                value:(NSString*)value
                                 data:(NSString*)data
                              chainID:(NSString*)chainID
                          VNSSignType:(VNSSignType)VNSSignType
                             contract:(NSString*)contract
                              decimal:(NSInteger)decimal
                               prvStr:(NSString*)prvStr
                               params:(id)params
                     helperComplation:(HelperComplation)helperComplation ;

@end

NS_ASSUME_NONNULL_END
