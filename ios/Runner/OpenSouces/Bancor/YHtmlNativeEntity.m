//
//  YHtmlNativeEntity.m
//  CoinID
//
//  Created by MWTECH on 2019/1/24.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "YHtmlNativeEntity.h"

@implementation YHtmlDetailed

-(NSString *)bancorConverterAddress{
    
    return [_bancorConverterAddress stringByReplacingOccurrencesOfString:@"0x" withString:@""];
}
-(NSString *)smartTokenAddress{
    
    return [_smartTokenAddress stringByReplacingOccurrencesOfString:@"0x" withString:@""];
}
-(NSString *)etherTokenAddress{
    
    return [_etherTokenAddress stringByReplacingOccurrencesOfString:@"0x" withString:@""];
}

@end

@implementation YHtmlJsonDataEntity

@end

@implementation YHtmlNativeEntity

@end
