//
//  UIFont+Size.m
//  CoinID
//
//  Created by MWTECH on 2019/9/3.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "UIFont+Size.h"
#import "Enum.h"

@implementation UIFont (Size)

+(UIFont*)systemFontOfSizeV2:(CGFloat)fontSize {
    
    if (IS_IPHONE_6P || IS_IPHONEX) {
        return [UIFont systemFontOfSize:fontSize];
    }
    else if(IS_IPHONE_6) {
        return [UIFont systemFontOfSize:fontSize];
    }else {
        return [UIFont systemFontOfSize:fontSize];
    }
}

+(UIFont*)fontWithNameV2:(NSString*)fontName size:(CGFloat)size{

    if (IS_IPHONE_6P || IS_IPHONEX) {
        return [UIFont fontWithName:fontName size:size];
    }
    else if(IS_IPHONE_6) {
        return [UIFont fontWithName:fontName size:size];
    }else {
        return [UIFont fontWithName:fontName size:size];
    }
    
}

+(UIFont*)fontWithRoboto:(CGFloat)size{
    
    return [UIFont fontWithNameV2:@"Roboto" size:size];
}

+(UIFont*)fontWithRobotoRegular:(CGFloat)size{
    
    return [UIFont fontWithNameV2:@"Roboto-Regular" size:size];
}
+(UIFont*)fontWithRobotoMedium:(CGFloat)size{
    
    return [UIFont fontWithNameV2:@"Roboto-Medium" size:size];
}
@end
