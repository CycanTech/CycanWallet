//
//  UIFont+Size.h
//  CoinID
//
//  Created by MWTECH on 2019/9/3.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Size)

+(UIFont*)systemFontOfSizeV2:(CGFloat)fontSize ;

+(UIFont*)fontWithNameV2:(NSString*)fontName size:(CGFloat)size;

+(UIFont*)fontWithRoboto:(CGFloat)size;

+(UIFont*)fontWithRobotoRegular:(CGFloat)size;

+(UIFont*)fontWithRobotoMedium:(CGFloat)size;
@end

NS_ASSUME_NONNULL_END
