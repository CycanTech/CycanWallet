//
//  UIViewController+HUD.m
//  CoinID
//
//  Created by Wind on 2018/8/23.
//  Copyright © 2018年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "UIViewController+HUD.h"
#import "Enum.h"
#define dismissTimeInterval 1.5

@implementation UIViewController (HUD)

#pragma mark - 更新

+(void)initialize{
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimeInterval] ;
    
}


+ (void)show{
    [SVProgressHUD show];
}
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:maskType];

}
+ (void)showWithStatus:( NSString*)status{
  
    [SVProgressHUD showWithStatus:status];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];


}
+ (void)showWithStatus:( NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    
    [SVProgressHUD showWithStatus:status];
    [SVProgressHUD setDefaultMaskType:maskType];

}


+ (void)showInfoWithStatus:( NSString*)status{
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@""]];
    [SVProgressHUD showInfoWithStatus:status];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimeInterval] ;
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];


}

+ (void)showBottomInfoWithStatus:( NSString*)status {
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@""]];
    [SVProgressHUD showInfoWithStatus:status];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimeInterval] ;
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, KSCREEN_WIDTH/4)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [SVProgressHUD resetOffsetFromCenter];
        
    });
}

//遮罩
+ (void)showInfoWithStatus:( NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@""]];
    [SVProgressHUD showInfoWithStatus:status];
    [SVProgressHUD  setDefaultMaskType:maskType];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimeInterval] ;

}

+ (void)showSuccessWithStatus:( NSString*)status{
    [SVProgressHUD showSuccessWithStatus:status];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimeInterval] ;
    
}
+ (void)showSuccessWithStatus:( NSString*)status maskType:(SVProgressHUDMaskType)maskType  {
    [SVProgressHUD showSuccessWithStatus:status];
    [SVProgressHUD  setDefaultMaskType:maskType];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimeInterval] ;

}

+ (void)showErrorWithStatus:( NSString*)status{
    [SVProgressHUD showErrorWithStatus:status];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimeInterval] ;
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];


}
+ (void)showErrorWithStatus:( NSString*)status maskType:(SVProgressHUDMaskType)maskType  {
  
//    NSLocalizedString(status, <#comment#>)
    
    [SVProgressHUD showErrorWithStatus:status];
    [SVProgressHUD setDefaultMaskType:maskType];
    [SVProgressHUD setMinimumDismissTimeInterval:dismissTimeInterval] ;

}

// shows a image + status, use white PNGs with the imageViewSize (default is 28x28 pt)
+ (void)showImage:(nonnull UIImage*)image status:(nullable NSString*)status{
    
}
+ (void)showImage:(nonnull UIImage*)image status:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    
}

+ (void)dismiss{
    [SVProgressHUD dismiss];
}
+ (void)dismissWithCompletion:(nullable SVProgressHUDDismissCompletion)completion{
    
    [SVProgressHUD dismissWithCompletion:completion];
}
+ (void)dismissWithDelay:(NSTimeInterval)delay{
    [SVProgressHUD dismissWithDelay:delay];
}
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable SVProgressHUDDismissCompletion)completion{
    
    [SVProgressHUD dismissWithDelay:delay completion:completion];
    
}
@end
