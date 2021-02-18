//
//  UIViewController+HUD.h
//  CoinID
//
//  Created by Wind on 2018/8/23.
//  Copyright © 2018年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <MBProgressHUD.h>
#import <SVProgressHUD.h>


//HUD 的 扩展
@interface UIViewController (HUD)

+ (void)show;
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType ;
+ (void)showWithStatus:( NSString*)status;
+ (void)showWithStatus:( NSString*)status maskType:(SVProgressHUDMaskType)maskType ;

+ (void)showInfoWithStatus:( NSString*)status;
+ (void)showInfoWithStatus:( NSString*)status maskType:(SVProgressHUDMaskType)maskType ;
+ (void)showBottomInfoWithStatus:( NSString*)status ;

+ (void)showSuccessWithStatus:( NSString*)status;
+ (void)showSuccessWithStatus:( NSString*)status maskType:(SVProgressHUDMaskType)maskType  ;

+ (void)showErrorWithStatus:( NSString*)status;
+ (void)showErrorWithStatus:( NSString*)status maskType:(SVProgressHUDMaskType)maskType  ;

// shows a image + status, use white PNGs with the imageViewSize (default is 28x28 pt)
+ (void)showImage:( UIImage*)image status:( NSString*)status;
+ (void)showImage:( UIImage*)image status:( NSString*)status maskType:(SVProgressHUDMaskType)maskType ;

+ (void)dismiss;
+ (void)dismissWithCompletion:(nullable SVProgressHUDDismissCompletion)completion;
+ (void)dismissWithDelay:(NSTimeInterval)delay;
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable SVProgressHUDDismissCompletion)completion;


@end
