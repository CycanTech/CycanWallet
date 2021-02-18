//
//  BancorManager.h
//  CoinID
//
//  Created by MWTECH on 2019/10/9.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface BancorManager : NSObject<WKUIDelegate>

+(instancetype)shareManagerWithContainerVC:(UIViewController*)vc defalutObject:(id)walletObject;;


@end

NS_ASSUME_NONNULL_END
