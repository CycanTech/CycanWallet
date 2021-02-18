//
//  LoadWebVC.h
//  CoinID
//
//  Created by 新明华区块链技术（深圳）有限公司 on 2018/10/29.
//  Copyright © 2018年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enum.h"
@interface LoadWebVC : UIViewController

@property (strong ,nonatomic) NSString *url;
@property (strong ,nonatomic) NSString *navTitle;
@property (assign ,nonatomic) URLLoadType urlType;

@end
