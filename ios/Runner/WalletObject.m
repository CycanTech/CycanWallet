//
//  WalletObject.m
//  Runner
//
//  Created by MWT on 2/11/2020.
//

#import "WalletObject.h"
#import <CommonCrypto/CommonDigest.h>
#import "YCommonMethods.h"
#import "CoinIDTool.h"
#import "ChannelDapp.h"
#import "Enum.h"
@implementation WalletObject


-(NSString*)deckAESCBC:(NSString*)desk {
    
    if (!self.keys || self.keys.length == 0) {
        NSAssert(NO, @"未记录解锁后的密码");
        return nil ;
    }
    
    return [CoinIDTool CoinID_DecByAES128CBC:desk pin:self.keys];
}


-(void)verifyWalletModelPinPasswordTitle:(NSString*)title message:(NSString*)message placeHolder:(NSString*)placeHolder showInVc:(UIViewController*)vc complationBlock:(void (^)(BOOL status))complation{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeHolder;
        textField.secureTextEntry = YES;//密码模式
    }];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

        //验证pin 码
        UITextField *password = alert.textFields.firstObject;
        [self unlock:password complationBlock:complation];
    }];

    [alert addAction:action];
    [alert addAction:action1];
    [vc presentViewController:alert animated:YES completion:nil];
    
}

-(void)verifyWalletModelPinPasswordTitleStatus:(NSString*)title message:(NSString*)message placeHolder:(NSString*)placeHolder showInVc:(UIViewController*)vc complationBlock:(void (^)(NSInteger status))complation {
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * action = [UIAlertAction actionWithTitle:YLOCALIZED_UserVC(@"updateview_cancle") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        if (complation) {
            complation(YVerifyPasswordState_Cancle);
        }
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeHolder;
        textField.secureTextEntry = YES;//密码模式
    }];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:YLOCALIZED_UserVC(@"backupwordvc_complation") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        //验证pin 码
        UITextField *password = alert.textFields.firstObject;
        [self unlock:password complationBlock:^(BOOL status) {
            if (status) {
                if (complation) {
                    complation(YVerifyPasswordState_Ok);
                }
            }else{
                if (complation) {
                    complation(YVerifyPasswordState_Wrong);
                }
            }
        }];
    }];
    
    [alert addAction:action];
    [alert addAction:action1];
    [vc presentViewController:alert animated:YES completion:nil];
}

-(void)unlock:(UITextField *)password complationBlock:(void (^)(BOOL status))complation{
    
    if (password.text.length > 0) {
        //拼接
        NSString * value = password.text ;
        WEAK(self)
        [[ChannelDapp sharedInstance] lock:self.walletID pin:value result:^(id  _Nullable result) {
            bool status = [result boolValue];
            if (status) {
                weakObject.keys = value ;
                if (complation) {
                    complation(YES);
                }
            }else {
                if (complation) {
                    complation(NO);
                }
            }
        }];
    }
    else{
        
        if (complation) {
            complation(NO);
        }
    }
}




@end
