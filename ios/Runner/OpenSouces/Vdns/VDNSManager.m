//
//  VDNSManager.m
//  CoinID
//
//  Created by MWTECH on 2019/10/23.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "VDNSManager.h"
#import "zhPopupController.h"
#import "YChainBussiness.h"
#import "ETHTransferParticularsModel.h"
#import "YRequireAddressView.h"
#import "ScanVC.h"
#import <MJExtension/MJExtension.h>
#import "WalletObject.h"
#import "Enum.h"
#import "CoinIDHelper.h"
#import "CoinIDHelper+VNSSign.h"
#import "ChannelDapp.h"
#import "YCommonMethods.h"
#import "UIViewController+HUD.h"


#define kLeftText @"kLeftText"
#define kContent @"kContent"

@implementation VDNSPopModel

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    
    return @{@"strCopy":@"copy"};
}

@end


@interface VDNSManager ()

@property (nonatomic,weak) UIViewController * containerVC; //弱引用
@property (nonatomic,strong) WKWebView * webView ;
@property (nonatomic,copy) NSString * nonce ;
@property (nonatomic,copy) NSString * version ;
@property (nonatomic,copy) NSString * gasprice ;
@property (nonatomic,copy) NSString * estimateGas ;
@property (nonatomic,assign) double  balNum ;
@property (nonatomic,strong)WalletObject  * et ;


@end

@implementation VDNSManager

+(instancetype)shareManagerWithContainerVC:(UIViewController*)vc webView:(WKWebView*)webView defalutObject:(WalletObject*)walletObject{

    VDNSManager * vDns = [[VDNSManager alloc] init ];
    vDns.containerVC = vc ;
    vDns.webView = webView ;
    
    vDns.et = walletObject ;
    NSString * address = @"";
    if (walletObject) {
        
        address = walletObject.address ;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [vDns requestUpdateAddressPermissions];
    });
        
    return vDns ;
}


#pragma mark - 开始准备签名
-(void)getVNSTransInfo:(VDNSPopModel*)model{
    
    //判断余额
    VNSSignType signType = VNSSignType_VNS ;
    NSString * token = model.payType ;
    BOOL isToken = [token isEqualToString:@"VP"];
    //付定金
    signType = [self configVNSSignType:model];
    
    NSString * payNum = model.payNum ;
    if (payNum.length == 0 ) {
        payNum = @"0";
    }
    if (token.length == 0 ) {
        token = @"";
    }
    //交易类型
    NSString * type = @"交易类型";
    NSString * from = @"付款地址";
    NSString * to = @"合约地址";
    NSString * value = @"金额";
    NSString * gasfee = @"矿工费";
    NSString * typeC = @"";
    if (signType == VNSSignType_Vdns_Renew) {
        //续费域名
        typeC = @"续费域名";
    }
    else if (signType == VNSSignType_Vdns_DelSubLevel){
        //删除域名
        typeC = @"删除域名";
    }
    else if (signType == VNSSignType_Vdns_PayTopLevel){
        typeC = @"注册域名";
        //注册域名
    }else if (signType == VNSSignType_Vdns_PaySubLevel){
        
        typeC = @"注册域名";
        //注册域名
    }
    else if (signType == VNSSignType_Vdns_SetController){
        //转让域名
        typeC = @"转让域名";
    }
    NSString * rightTo = model.contract ;
    NSString * rightFrom = _et.address ;
    NSString * amount = [payNum stringByAppendingFormat:@" %@",token];
    
    NSDecimalNumberHandler *roundBanker = [NSDecimalNumberHandler       decimalNumberHandlerWithRoundingMode:NSRoundBankers
                  scale:0
       raiseOnExactness:NO
        raiseOnOverflow:NO
       raiseOnUnderflow:NO
    raiseOnDivideByZero:YES];
    NSDecimalNumber * gasNumber = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%@",self.gasprice]];
    NSDecimalNumber * gasValue = [gasNumber decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithString:@"1000000000"] withBehavior:roundBanker];
    gasValue = [gasValue decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:self.estimateGas]];
    gasValue = [gasValue decimalNumberByMultiplyingByPowerOf10:-18];
    
    if ( signType == VNSSignType_Vdns_PaySubLevel ) {
        
        NSString * type = model.type ;
        NSString * add = model.anAddress ;
//        YCoinType coin = [YCommonMethods automaticGenerateCurrency:type.uppercaseString];
//        if (![CoinIDHelper CoinID_checkAddressValid:coin address:add]) {
//            [UIViewController showInfoWithStatus:YLOCALIZED_UserVC(@"transferopratevc_addressvalid")];
//            return ;
//        }
    }
    
    if (isToken) {
        
        //查询vp 是否解锁
//        [YChainBussiness requestVPIsValid:_et.Ywallettname complationBack:^(NSDecimalNumber* data, NSInteger code) {
//
//            if (data && code == 200 ) {
//
//                if (data.doubleValue > 0 ) {
//                    //已解锁无需解锁
//                    NSLog(@"已解锁无需解锁");
//                    [self configVNSHotSign:model signType:signType complationBack:^{
//
////                        if (model.num == VDNSRequestCode_Pay_Deposit) {
////
////                            [self nativeCallJSViewUpdate:@"3"];
////                        }
////                        if (model.num == VDNSRequestCode_Sub_Name) {
////
////                            [self nativeCallJSViewSubUpdate:@"3"];
////                        }
//                    }];
//
//                }else{
//                    //未解锁去解锁
//                    NSLog(@"未解锁去解锁");
//                    [self configVNSHotSign:model signType:VNSSignType_Vdns_VPPayUnLock complationBack:^{
//
//                        self.nonce = [NSString stringWithFormat:@"%ld",self.nonce.integerValue + 1];
//                        //解锁成功
//                        [self startVnsSign:model signType:signType complationBack:^{
//
////                            if (model.num == VDNSRequestCode_Pay_Deposit) {
////
////                                [self nativeCallJSViewUpdate:@"3"];
////                            }
////                            if (model.num == VDNSRequestCode_Sub_Name) {
////
////                                [self nativeCallJSViewSubUpdate:@"3"];
////                            }
//                        }];
//                    }];
//                }
//            }
//        }];
    
    }
    else{
        
        NSMutableArray * arrs = [NSMutableArray array];
        [arrs addObject:@{kLeftText :type ,kContent:typeC}];
        [arrs addObject:@{kLeftText :from ,kContent:rightFrom}];
        [arrs addObject:@{kLeftText :to ,kContent:rightTo}];
        [arrs addObject:@{kLeftText :value ,kContent:amount}];
        [arrs addObject:@{kLeftText :gasfee ,kContent:gasValue.stringValue}];
        
        YRequireSignView * signView = [YRequireSignView showWithAcitonBlock:^(NSInteger actionType) {
            
            if (actionType == 1) {
                
                [self configVNSHotSign:model signType:signType complationBack:^(id data) {
                   
                    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary] ;
                    [dataDic    setObject:data forKey:@"txid"];
                    [dataDic    setObject:[NSString stringWithFormat:@"%@VNS",gasValue.stringValue] forKey:@"minersFee"];
                    [self nativeCallJSViewUpdate:dataDic];
                    
                }];
            }
            
        } type:VDATYPE_Vdns];
        signView.datas = arrs ;
    }
}

#pragma mark - 热钱包开始解锁并钱包
-(void)configVNSHotSign:(VDNSPopModel*)model signType:(VNSSignType)signType complationBack:(void(^)(id data))complationBack{
    
    if ( model.payNum.doubleValue > self.balNum) {

        [UIViewController showErrorWithStatus:@"转账金额需要小于余额"];
        return ;
    }

    NSString * alertstring = @"请输入密码";
    WEAK(self)
    [_et verifyWalletModelPinPasswordTitle:alertstring message:@"" placeHolder:alertstring showInVc:self.containerVC complationBlock:^(BOOL status) {
        
        if (status) {
            
            [weakObject startVnsSign:model signType:signType complationBack:complationBack];
        }else{
            
            NSLog(@"密码匹配不上");
            [UIViewController showErrorWithStatus:@"密码验证失败"];
        }
    }];
}

#pragma mark - 开始签名
-(void)startVnsSign:(VDNSPopModel*)model signType:(VNSSignType)signType complationBack:(void(^)(id data))complationBack{
   
    NSString * to = [model.contract stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSDecimalNumber * gaspriceNumber = [[NSDecimalNumber alloc] initWithString:self.gasprice];
    NSDecimalNumber * gasNumbel = [gaspriceNumber decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithString:@"1000000000"]];
    NSString * prvKey = [self.et deckAESCBC:self.et.prvKey];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString * vnsNum = @"0";
    if (signType == VNSSignType_Vdns_PayTopLevel) {
        
        vnsNum = model.payNum ;
        params[@"year"] = model.year;
        params[@"vdns"] = model.vnsyuming ;
        
    }else if (signType == VNSSignType_Vdns_PaySubLevel){
        
        params[@"vadType"] = model.type;
        params[@"vdns"] = model.son ;
        params[@"addr"] = model.anAddress ;
    }else if (signType == VNSSignType_Vdns_SetController){
        
        params[@"address"] = model.to;
        params[@"vdns"] = model.vnsyuming ;
    }else if (signType == VNSSignType_Vdns_Renew){
        
        params[@"year"] = model.year;
        params[@"vdns"] = model.vnsyuming ;
        vnsNum = model.payNum ;
    }else if (signType == VNSSignType_Vdns_DelSubLevel){
        
         params[@"vdns"] = model.yuming ;
    }
    
    
    NSString * signStr = [CoinIDHelper vnsHotSignTransWithNonce:self.nonce gasPrice:gasNumbel.stringValue gasLimit:self.estimateGas to:to value:vnsNum data:@"" chainID:self.version VNSSignType:signType contract:to decimal:18 prvStr:prvKey params:params helperComplation:nil];
    
    if (signStr) {
        
        [YChainBussiness requerstVNSData:signStr complationBack:^(id  _Nonnull data, NSInteger code) {
            
            if (data && code == 200) {
               
                if (complationBack) {
                    complationBack(data);
                }
            }
            else {
                
                NSLog(@"startVnsSign ");
                [UIViewController showErrorWithStatus:data];
            }
        }];
    }
}


#pragma mark - 获取gas price
-(void)requestVNSAddresssInfo:(NSString*)address contract:(NSString*)contract complationBack:(void(^)(void))complationBack {
    
    //查询gas price nonce
    WEAK(self)
    [YChainBussiness requestVNSAddresssInfo:address to:nil contract:nil data:nil complationBack:^(id  _Nonnull data, NSInteger code) {
        
        if (code == 200) {
                  
            for (ETHTransferParticularsModel * mdoel in data) {
                //
                if ([mdoel.name isEqualToString:@"gasPrice"]) {
                    
                    weakObject.gasprice = @"50";
                }
                else if ([mdoel.name isEqualToString:@"estimateGas"] || [mdoel.name isEqualToString:@"tokenEstimateGas"] ){
                    
                    weakObject.estimateGas = @"3000000";
                }
                else if ([mdoel.name isEqualToString:@"transaction"]){
                    
                    weakObject.nonce = [YCommonMethods getNumberFromHex:mdoel.data.result] ;
                }
                else if ([mdoel.name isEqualToString:@"version"]){
                    
                    weakObject.version = @"2018" ;
                }
                else if ([mdoel.name isEqualToString:@"Balance"]){
                    
                    NSString * bal = [YCommonMethods getNumberFromHex:mdoel.data.result] ;
                    weakObject.balNum = bal.doubleValue / pow(10, 18) ;
                    NSLog(@"balNum %.8f",weakObject.balNum);
                }
            }
            
            if (complationBack) {
                complationBack();
            }
        }
    }];
    
}

#pragma mark - 根据num 判断签名类型
-(VNSSignType)configVNSSignType:(VDNSPopModel*)model{
    
    VNSSignType signType = VNSSignType_VNS ;
    NSString * token = model.payType ;
    BOOL isToken = [token isEqualToString:@"VP"];
    if (model.num == VDNSRequestCode_PayTopLevel) {
        
        signType = VNSSignType_Vdns_PayTopLevel ;
        
    }
    if (model.num == VDNSRequestCode_Renew) {
        
        signType = VNSSignType_Vdns_Renew ;
       
    }
    if (model.num == VDNSRequestCode_PaySubLevel) {
        
        signType = VNSSignType_Vdns_PaySubLevel ;
        
    }
    if (model.num == VDNSRequestCode_SetController) {
        
        signType = VNSSignType_Vdns_SetController ;
    }
    if (model.num == VDNSRequestCode_DelSubLevel) {
        
        signType = VNSSignType_Vdns_DelSubLevel;
    }
    return signType ;
}

#pragma mark - 请求更新地址权限
-(void)requestUpdateAddressPermissions{
    
    WEAK(self)
    [[ChannelDapp sharedInstance] datas:MCoinType_VNS result:^(id  _Nullable result) {
        
        STRONG(weakObject)
        [YRequireAddressView showWithAcitonBlock:^(NSInteger btnState) {
            
            if (btnState == 1) {
                
                [[ChannelDapp sharedInstance] getDid:^(id  _Nullable result) {
                    
                    WalletObject * object = result;
                    strongObject.et = object;
                    [strongObject nativeCallJSGetAddressPermissions:self.et.address];
                }];
            }
            else if (btnState == -1){
                
                NSLog(@"requestUpdateAddressPermissions");
            }
        } type:VDATYPE_Vdns datas:result];
    }];
}

-(void)nativeCallJSGetAddressPermissions:(id)params{
    
    NSString * address = params ;
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"获取成功！" forKey:@"msg" ];
    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary] ;
    [dataDic    setObject:@[address] forKey:@"addressList"];
    [infoDic setObject:dataDic forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"returnGetVnsAddressResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}

-(void)nativeCallJSUpdateAddressPermissions:(id)params{
    
    NSString * address = params ;
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"获取成功！" forKey:@"msg" ];
    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary] ;
    [dataDic    setObject:@[address] forKey:@"addressList"];
    [infoDic setObject:dataDic forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    
    NSString * jsonStr = [NSString stringWithFormat:@"returnReplaceAddressResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}



-(void)nativeCallJSViewUpdate:(id)params{
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"获取成功！" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"payResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}

-(void)nativeCallJSViewSubUpdate:(id)params{
    
    NSString * jsonStr = [NSString stringWithFormat:@"sonResult('%@')",@"3"];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}

-(void)evaluateJavaScriptWithFunctionNameString:(NSString*)function{
    
    NSLog(@"function %@",function);
    [self.webView evaluateJavaScript:function completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
        NSLog(@"error  %@",error);
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    NSLog(@"prompt %@",prompt);
    completionHandler(nil);
    VDNSPopModel * model = [VDNSPopModel mj_objectWithKeyValues:[prompt mj_JSONObject]];
    if (!model) {
        return ;
    }
    NSString * address = _et.address ;
    NSString * contract = model.contract ;
    //设置地址权限
    if (model.num == VDNSRequestCode_SetAddress_Permissions) {

        [self requestUpdateAddressPermissions];
    }
    else if (model.num == VDNSRequestCode_ClickCopy){
        
        NSString * copy = model.strCopy ;
        [UIViewController showSuccessWithStatus:@"复制成功！"];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = copy.length > 0 ? copy : @"";
        
    }
    else if (model.num == VDNSRequestCode_ScanAddress){
        
//        [self nativeCallJSViewScanCode];
    }else if (model.num == VDNSRequestCode_UpdateAddress){
        
        [self requestUpdateAddressPermissions];
    }
    else if (
              model.num == VDNSRequestCode_PayTopLevel ||
              model.num == VDNSRequestCode_PaySubLevel||
              model.num == VDNSRequestCode_Renew||
              model.num == VDNSRequestCode_SetController ||
              model.num == VDNSRequestCode_DelSubLevel){
                
        [UIViewController showWithStatus:@"请稍后..."];
        //请求gas price nonce
        WEAK(self)
        [self requestVNSAddresssInfo:address contract:contract complationBack:^{
            
            [UIViewController dismiss];
            [weakObject getVNSTransInfo:model];
        }];
    }
}


@end
