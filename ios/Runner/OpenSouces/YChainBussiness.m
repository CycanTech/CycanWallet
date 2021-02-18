//
//  YChainBussiness.m
//  CoinID
//
//  Created by MWTECH on 2019/8/14.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "YChainBussiness.h"
#import "ETHTransferParticularsModel.h"
#import "RequestMethod.h"
#import "MJExtension.h"
#import "YCommonMethods.h"

@implementation YChainBussiness

/// vns
+(void)requestVNSAddresssInfo:(NSString*)from
                           to:(NSString*)to
                     contract:(NSString*)contract
                         data:(NSString*)data
               complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    
    //verison nonce gasPrice estimateGas balance
    
    NSMutableDictionary * infos = [[NSMutableDictionary alloc] initWithDictionary:@{@"1":@"version",@"2":@"gasPrice",@"3":@"transaction",@"4":@"estimateGas",@"5":@"Balance"}];
    NSMutableDictionary * balInfo = [NSMutableDictionary dictionary];
    if (contract) {
        infos[@"4"] = @"tokenEstimateGas";
        NSString * data = [NSString stringWithFormat:@"0x70a08231000000000000000000000000%@",[from stringByReplacingOccurrencesOfString:@"0x" withString:@""]];
        balInfo[@"jsonrpc"] = @"2.0";
        balInfo[@"method"] = @"vns_call";
        balInfo[@"params"] = @[@{
                                  @"to":contract,
                                  @"data":data},
                              @"latest"];
        balInfo[@"id"] = @5;
    }else{
        balInfo[@"jsonrpc"] = @"2.0";
        balInfo[@"method"] = @"vns_getBalance";
        balInfo[@"params"] = @[from, @"latest"];
        balInfo[@"id"] = @5;
    }
    
    
    NSDictionary * version = @{@"jsonrpc":@"2.0",
                               @"method":@"net_version",@"params":@[],@"id":@1};
    
    NSDictionary * gasPriceInfo = @{@"jsonrpc":@"2.0",
                                    @"method":@"vns_gasPrice",@"params":@[],@"id":@2};
    NSDictionary * nonce = @{
                             @"jsonrpc": @"2.0",
                             @"id": @3,
                             @"method": @"vns_getTransactionCount",
                             @"params": @[from, @"latest"]
                             };
    
    NSArray * arrs = @[version,gasPriceInfo,nonce,balInfo];
    
    NSMutableArray * datas = [NSMutableArray array];
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_ETH didParam:arrs didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSArray class]]) {
            
            NSArray * arrs = response ;
            for (int i = 0 ; i < arrs.count; i ++ ) {
                NSDictionary * info = arrs[i];
                NSString * name = infos[[info[@"id"] stringValue]];
                [datas addObject:@{@"data":info,@"name":name}];
            }
            
            NSMutableArray * models = [ETHTransferParticularsModel mj_objectArrayWithKeyValuesArray:datas];
            
            ETHTransferParticularsModel * model = [[ETHTransferParticularsModel alloc] init];
            model.name = infos[@"4"];
            ETHTransferParticularDataModel * subModel = [[ETHTransferParticularDataModel alloc] init];
            subModel.result = @"0x5cec";
//            if (contract) {
                subModel.result = @"0xea60";
//            }
            model.data = subModel ;
            [models addObject:model];
            if (complationBack) {
                complationBack(models,200);
            }
            NSLog(@"arrs %@" ,[datas mj_JSONString]);
        }
    } didFailed:^(id error) {
        
        if (complationBack) {
            complationBack(nil,500 );
        }
    }];
    
}

+(void)requerstVNSData:(NSString*)result_bytestring complationBack:(void(^)(id data,NSInteger code ))complationBack {
    
    NSDictionary * dic =  @{@"id":@"1",@"jsonrpc":@"2.0",@"method":@"vns_sendRawTransaction",@"params":@[result_bytestring]};
    
    [RequestMethod requestNewAction:YRequest_POST didParam:dic didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if (response) {
            
            if ([[response allKeys] containsObject:@"error"]) {
                
                NSString  * errDic = [[response objectForKey:@"error"] objectForKey:@"message"];
                if (complationBack) {
                    complationBack(errDic,500);
                }
            }
            else if ([[response allKeys] containsObject:@"result"]){
                
                NSString * result = response[@"result"];
                // 转账时对txid入库
                if (complationBack) {
                    complationBack(result,200);
                }
            }
        }
        
    } didFailed:^(id error) {

        if (complationBack) {
            complationBack(nil,500);
        }
    }];
    
}

/**  尝还VUSD中检查提交的数据 */
+(void)parserRepaymentVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = name;
    data = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    data = [@"0xdd62ed3e000000000000000000000000" stringByAppendingString:data];
    data = [data stringByAppendingString:@"00000000000000000000000098a4A125EEa0efeEc7aB7559e4ad63F38009a9aD"];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0x4183bbd377fca70c5cfe8529ba3ddaf4ea1d009f",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
            NSString *value = [YCommonMethods getNumberFromHex:result];
            complationBack(value,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}
/**  看是否同意分割 */
+(void)splitRepaymentVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = name;
    data = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    data = [@"0x4538c4eb000000000000000000000000" stringByAppendingString:data];
    data = [data stringByAppendingString:@"000000000000000000000000cc147bdbf6f86ad4a1c6f12aa7e4fefcb145bc68"];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0xec0b8d49fa29f9e675823d0ee464df16bcf044d1",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
            NSString *value = [YCommonMethods getNumberFromHex:result];
            complationBack(value,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}
/**  allowance VUSD */
+(void)shutDownRepaymentVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = name;
    data = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    data = [@"0xdd62ed3e000000000000000000000000" stringByAppendingString:data];
    data = [data stringByAppendingString:@"000000000000000000000000cc147bdbf6f86ad4a1c6f12aa7e4fefcb145bc68"];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0x4183bbd377fca70c5cfe8529ba3ddaf4ea1d009f",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
            NSString *value = [YCommonMethods getNumberFromHex:result];
            complationBack(value,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}
/**  查询债务关系 */
+(void)queryDebtRelationshipVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = name;
    data = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    data = [@"0x2424be5c564E530000000000000000000000000000000000000000000000000000000000000000000000000000000000" stringByAppendingString:data];

    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0xec0b8d49fa29f9e675823d0ee464df16bcf044d1",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
            NSMutableDictionary *para = [NSMutableDictionary dictionary];
            NSString *vns = [result substringWithRange:NSMakeRange(2, 64)];
            NSString *art = [result substringWithRange:NSMakeRange(66, 64)];
            NSString *vusd = [result substringWithRange:NSMakeRange(130, 64)];
            NSString *ret = [result substringWithRange:NSMakeRange(194, 64)];
            para[@"vns"] = vns;
            para[@"vusd"] = vusd;
            para[@"ret"] = ret;
            para[@"art"] = art;
//            NSString *value = [CoinIDHelper getNumberFromHex:result];
            complationBack(para,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}
+(void)queryLinkSpatVusd:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = @"0xd9638d36564E530000000000000000000000000000000000000000000000000000000000";
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0xec0b8d49fa29f9e675823d0ee464df16bcf044d1",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
            NSMutableDictionary *para = [NSMutableDictionary dictionary];
            NSString *rate = [result substringWithRange:NSMakeRange(130, 64)];
            para[@"rate"] = rate;
            complationBack(para,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}
/**  查询VUSD余额 */
+(void)InquireVusdBalance:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = name;
    data = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    data = [@"0x70a08231000000000000000000000000" stringByAppendingString:data];

    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0x4183bbd377fca70c5cfe8529ba3ddaf4ea1d009f",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
            NSString *value = [YCommonMethods getNumberFromHex:result];
            complationBack(value,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}
/**  查询VUSD所有余额 */
+(void)InquireVusdAllBalance:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = name;
    data = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    data = [@"0x214414d5564E530000000000000000000000000000000000000000000000000000000000000000000000000000000000" stringByAppendingString:data];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0xec0b8d49fa29f9e675823d0ee464df16bcf044d1",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
//            NSString *value = [CoinIDHelper getNumberFromHex:result];
            result = [result stringByReplacingOccurrencesOfString:@"0x" withString:@""];
            complationBack(result,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}

/**  查询隐含VUSD所有余额 */
+(void)queryImpliedVusdAllBalance:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = name;
    data = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    data = [@"0xbf95b4d7000000000000000000000000" stringByAppendingString:data];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0xec0b8d49fa29f9e675823d0ee464df16bcf044d1",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    

    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
            NSString *value = [YCommonMethods getNumberFromHex:result];
            complationBack(value,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}

/**  奖金allowance */
+(void)InquireBonusAllBalance:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = name;
    data = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    data = [@"0xdd62ed3e000000000000000000000000" stringByAppendingString:@"000000000000000000000000f98db8d89a9c947bcca54dedb7509d743868d743"];
    data = [data stringByAppendingString:data];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0xcdcad0eb1364ad13892996c899a6baa5179c4318",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
            //            NSString *value = [CoinIDHelper getNumberFromHex:result];
            result = [result stringByReplacingOccurrencesOfString:@"0x" withString:@""];
            complationBack(result,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}

/**  查询gem */
+(void)InquireHGem:(id)name complationBack:(void(^)(id data,NSInteger code ))complationBack{
    
    NSString * data = name;
    data = [data stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    data = [@"0x214414d5564E530000000000000000000000000000000000000000000000000000000000000000000000000000000000" stringByAppendingString:data];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"jsonrpc"] = @"2.0";
    params[@"method"] = @"vns_call";
    params[@"params"] = @[@{
                              @"to":@"0xec0b8d49fa29f9e675823d0ee464df16bcf044d1",
                              @"data":data},
                          @"latest"];
    params[@"id"] = @1;
    
    
    [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSString * result = response[@"result"];
//            NSString *value = [CoinIDHelper getNumberFromHex:result];
            result = [result stringByReplacingOccurrencesOfString:@"0x" withString:@""];
            complationBack(result,200);
        }
        
    } didFailed:^(id error) {
        
    }];
}

@end
