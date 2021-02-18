//
//  ETHTransferParticularsModel.h
//  CoinID
//
//  Created by 新明华区块链技术（深圳）有限公司 on 2018/9/18.
//  Copyright © 2018年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETHTransferParticularDataModel : NSObject

@property (nonatomic,copy) NSString *  jsonrpc ;
@property (nonatomic,copy)  NSString*  result ;
@property (nonatomic,copy) NSString *  idNum ;

@end

@interface ETHTransferParticularsModel : NSObject

@property (nonatomic,copy) NSString *  name ; //身份名
@property (nonatomic,strong) ETHTransferParticularDataModel *  data ; //身份名

@end
