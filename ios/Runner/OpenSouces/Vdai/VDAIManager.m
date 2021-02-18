//
//  VDAIManager.m
//  CoinID
//
//  Created by 新明华区块链技术（深圳）有限公司 on 2019/11/13.
//  Copyright © 2019年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "VDAIManager.h"
#import "zhPopupController.h"
#import "YChainBussiness.h"
#import "ETHTransferParticularsModel.h"
#import "YRequireAddressView.h"

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

@implementation VDAIPopModel

@end


@interface VDAIManager ()
@property (nonatomic,weak) UIViewController * containerVC; //弱引用
@property (nonatomic,strong) WKWebView * webView ;
@property (nonatomic,copy) NSString * nonce ;
@property (nonatomic,copy) NSString * version ;
@property (nonatomic,copy) NSString * gasprice ;
@property (nonatomic,copy) NSString * estimateGas ;
@property (nonatomic,strong)WalletObject * et ;
@property (nonatomic,assign) BOOL  reslutComparison;
@property (nonatomic,assign) BOOL  segmentation; //创建时候，判断是否分割
@property (nonatomic,copy) NSString * vusdValueJoin ;
@property (nonatomic,copy) NSString * vusdValueFrobt ;
@property (nonatomic,assign) int repayStatus;// //偿还的状态
@property (nonatomic,copy) NSString * VNSSignType_Vusd_shutDownVUSD_Exit_Gem;//gem
@end

@implementation VDAIManager

+(instancetype)shareManagerWithContainerVC:(UIViewController*)vc webView:(WKWebView*)webView defalutObject:(WalletObject*)walletObject{
    
    VDAIManager * vDns = [[VDAIManager alloc] init ];
    vDns.containerVC = vc ;
    vDns.webView = webView ;
    vDns.et = walletObject ;
    return vDns ;
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    NSLog(@"prompt %@",prompt);
    completionHandler(nil);
    
    VDAIPopModel * model = [VDAIPopModel mj_objectWithKeyValues:[prompt mj_JSONObject]];
    if (!model) {
        
        return ;
    }

    NSString * address = self.et.address ;
    NSString * contract = nil ;
   
    //设置地址权限
    if (model.num == VDAIRequestCode_Vusd_create_address) {
        
        [self requestUpdateAddressPermissions];
    }
    else if (model.num == VDAIRequestCode_Vusd_Copy)
    {
        [UIViewController showSuccessWithStatus:YLOCALIZED_UserVC(@"uservc_tipcopysuccess")];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = model.replicateAddress;
    }
    else
    {
        [UIViewController showWithStatus:@"请稍后..."];
        //请求gas price nonce
        WEAK(self)
        [self requestVNSAddresssInfo:address contract:contract complationBack:^{
            
            [UIViewController dismiss];
            [weakObject getVNSTransInfo:model];
        }];
    }
    
}
#pragma mark - delegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
        //此处的completionHandler()就是调用JS方法时，`evaluateJavaScript`方法中的completionHandler
        
    }];
    [alert addAction:action];
    [self.containerVC presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 开始准备签名
-(void)getVNSTransInfo:(VDAIPopModel*)model{
    
    //判断余额
   __block VNSSignType signType = VNSSignType_Vusd_create;
    NSString * token = model.payType ;
    BOOL isToken = [token isEqualToString:@"VP"];

    NSString * payNum = @"" ;
    if (model.vnsNum) {
        payNum = model.vnsNum;
    }
    else if (model.vusdNum )
    {
        payNum = model.vusdNum;
    }
    else
    {
        payNum = @"";
    }
    
     signType = [self configVNSSignType:model];
    if (model.num == VDAIRequestCode_Vusd_RepayVUSD)//偿还vusd的时候，首先获取可偿还的数据
    {
        model.vusdBalance = model.vusdNum;
        [self changeModelVusdValue:model];
        
        [YChainBussiness queryDebtRelationshipVusd:self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
            
            if (data && code == 200) {
                model.transferVusdDic = data;
                NSDecimalNumber * decimalDeb = [NSDecimalNumber decimalNumberWithString:[YCommonMethods getNumberFromHex:model.transferVusdDic[@"ret"]]];
                NSDecimalNumber * compareDecima  = [decimalDeb decimalNumberByMultiplyingByPowerOf10:-18];
                if ([compareDecima isEqual:@0] != YES) { //att奖金
                    [YChainBussiness InquireBonusAllBalance: self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
                        //返回来的数据已经是18次方的
                        if (data && code == 200) {
                            BigNumber *big = [BigNumber bigNumberWithDecimalString:data];
                            BigNumber *retBig = [BigNumber bigNumberWithDecimalString:model.transferVusdDic[@"ret"]];
                            BigNumber *zero = [BigNumber bigNumberWithDecimalString:@"0"];
                            if ([retBig greaterThanEqualTo:big] == YES) {
                                if ([big isEqualTo:zero] != YES) {
//                                    self.repayStatus = 1;
                                }
                            }

                        }
                        
                    }];
                }
                [YChainBussiness shutDownRepaymentVusd:self.et.address complationBack:^(id  _Nonnull data, NSInteger code) {
                    
                    if (data && code == 200) {
                        signType = VNSSignType_Vusd_RepayVUSD_Approve;
                        BigNumber *big = [BigNumber bigNumberWithDecimalString:data];
                        if ([big isEqualTo:[BigNumber bigNumberWithDecimalString:@"0"]] == YES) {
                            signType = VNSSignType_Vusd_RepayVUSD_Approve;
                        }
                        else
                        {
                            BigNumber *ten = [BigNumber bigNumberWithInteger:10];
                            for (int i = 0; i < 45; i++) {
                                ten = [ten mul:[BigNumber bigNumberWithInteger:10]];
                            }
                            BigNumber *modelVusdNUm = [BigNumber bigNumberWithDecimalString:@""];
                            NSRange range = [model.vusdNum rangeOfString:@"."]; //如果有浮点
                            NSInteger lenght = model.vusdNum.length - (range.location + 1);
                            if (range.location != NSNotFound) {
                                NSDecimalNumber * decimalVusdStr = [NSDecimalNumber decimalNumberWithString:model.vusdNum];//先转换输入的vusd
                                BigNumber *newVusdNum = [BigNumber bigNumberWithInteger:10];
                                NSDecimalNumber * payMoney = [decimalVusdStr decimalNumberByMultiplyingByPowerOf10:lenght];
                                NSString *vusdStr = [payMoney stringValue]; //转换后的值
                                for (int i = 0; i < lenght; i++) {
                                    newVusdNum = [newVusdNum mul:[BigNumber bigNumberWithInteger:10]];
                                }
                                modelVusdNUm = [ten mul:[BigNumber bigNumberWithDecimalString:vusdStr]];
                            }
                            else
                            {
                                modelVusdNUm = [ten mul:[BigNumber bigNumberWithDecimalString:model.vusdNum]];
                            }
                            if ([big greaterThan:modelVusdNUm] == YES) {
                                signType = VNSSignType_Vusd_RepayVUSD_Join;
                            }
                        }
                    }
                    
                }];
            }
            
        }];
    
    }
    else if (model.num == VDAIRequestCode_Vusd_create)
    {
        model.vusdBalance = model.vusdNum;
        [YChainBussiness splitRepaymentVusd: self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
            
            if (data && code == 200) {
                
                if ([data intValue] == 0) { //首次分割
                    self.segmentation = NO;
                }
                else
                {
                    self.segmentation = YES;
                }
            }
            
        }];
        
       [self changeModelVusdValue:model];
    }
    else if (model.num == VDAIRequestCode_Vusd_GenerateVUSD)
    {
        model.vusdBalance = model.vusdNum;//exit的时候 使用输入的vusd的值
        [self changeModelVusdValue:model];
        [YChainBussiness splitRepaymentVusd: self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
            
            if (data && code == 200) {
                
                if ([data intValue] == 0) { //首次分割
                    signType = VNSSignType_Vusd_GenerateVUSD_Segmentation_No;
                }
                else
                {
                    signType = VNSSignType_Vusd_GenerateVUSD_Segmentation_Yes;
                }
            }
            
        }];
      
    }
    else if (model.num == VDAIRequestCode_Vusd_shutDownVUSD) //关闭
    {
        /**  查询债务关系 */
        [YChainBussiness queryDebtRelationshipVusd: self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
            
            if (data && code == 200) {
                model.transferVusdDic = data;
                NSString *value = [YCommonMethods getNumberFromHex:model.transferVusdDic[@"art"]];
                NSDecimalNumber * decimalValue = [NSDecimalNumber decimalNumberWithString:value];
                [YChainBussiness queryLinkSpatVusd:self.et.address complationBack:^(id  _Nonnull data, NSInteger code) {
            
                    NSString *rate = [YCommonMethods getNumberFromHex:data[@"rate"]];
                    NSDecimalNumber * decimalRate = [NSDecimalNumber decimalNumberWithString:rate];
                    NSDecimalNumber * decimalDeb = [decimalValue decimalNumberByMultiplyingBy:decimalRate];//相乘
                    model.transferVusdDic[@"vusd"] = [decimalDeb stringValue];
                    
                    /**  查询隐含vusd所有的余额 */
                   [YChainBussiness queryImpliedVusdAllBalance: self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
                       
                       if (data && code == 200) {
                       
                           NSDecimalNumber * decimalVusd = [NSDecimalNumber decimalNumberWithString:data];
                           NSDecimalNumber * compareDecima  = [decimalDeb decimalNumberBySubtracting:decimalVusd];
                           model.vusdBalance = [compareDecima stringValue];
                           if ( [decimalDeb compare:decimalVusd] == 0 || [decimalDeb compare:decimalVusd] == -1) {
                               
                               signType = VNSSignType_Vusd_shutDownVUSD_frobt;
                               
                           }
                           else
                           {
                               /**  查询VUSD余额 */
                               [YChainBussiness InquireVusdBalance: self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
                                   
                                   if (data && code == 200) {
                                   
                                       /**  vusd.allowance*/
                                       [YChainBussiness shutDownRepaymentVusd: self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
                                           
                                           if (data && code == 200) {
                                               BigNumber *big = [BigNumber bigNumberWithDecimalString:data];
                                               BigNumber *zero = [BigNumber bigNumberWithDecimalString:@"0"];
                                               BigNumber *small = [BigNumber bigNumberWithDecimalString:model.vusdBalance ];
                                               self.reslutComparison = [big greaterThan:small]; //大于余额
                                               
                                               if ([big isEqualTo:zero] != YES) {//
                                                   
                                                   if ([small isEqualTo:zero] == YES) { //余额等于0
                                                       signType = VNSSignType_Vusd_shutDownVUSD_frobt;
                                                       
                                                   }
                                                   else
                                                   {
                                                       if (self.reslutComparison == YES) {
                                                           
                                                           signType = VNSSignType_Vusd_shutDownVUSD_Join;
                                                       }
                                                       else
                                                       {
                                                           signType = VNSSignType_Vusd_shutDownVUSD_Approve ;
                                                       }
                                                   }
                                                   
                                               }
                                               else //0
                                               {
                                                   signType = VNSSignType_Vusd_shutDownVUSD_Approve ; //appro
                                               }
                                               
                                           }
                                           
                                       }];
                                   }
                                   
                               }];
                           }
                           
                       }
                       
                   }];
                    
                }];
    
            }
            
        }];
        
        /**  查询gem */
       [YChainBussiness InquireHGem:self.et.address complationBack:^(id  _Nonnull data, NSInteger code) {
          
           if (data && code == 200) {
               NSString *dataGem = (NSString *)data;
               if ([YCommonMethods getNumberFromHex:dataGem] != 0) {
                   self.VNSSignType_Vusd_shutDownVUSD_Exit_Gem = dataGem;
               }
               
           }
           
       }];
        
        /**  查询vusd所有的余额 */
        [YChainBussiness InquireVusdAllBalance: self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
            
            if (data && code == 200) {
                
                model.vusdAllBalance = data;
            }
            
        }];
        
    }
    else if (model.num == VDAIRequestCode_Vusd_transferVUSD)
    {
        /**  查询债务关系 */
        [YChainBussiness queryDebtRelationshipVusd: self->_et.address complationBack:^(id  _Nonnull data, NSInteger code) {
            
            if (data && code == 200) {
                
                model.transferVusdDic = data;
                
                [YChainBussiness queryLinkSpatVusd:self.et.address complationBack:^(id  _Nonnull data, NSInteger code) {
                    
                    if (data && code == 200 ) {
                        NSDecimalNumber *decimalValue = [NSDecimalNumber decimalNumberWithString:[YCommonMethods getNumberFromHex:model.transferVusdDic[@"art"]]];
                        NSString *rate = [YCommonMethods getNumberFromHex:data[@"rate"]];
                        NSDecimalNumber * decimalRate = [NSDecimalNumber decimalNumberWithString:rate];
                        NSDecimalNumber * decimalDeb = [decimalValue decimalNumberByMultiplyingBy:decimalRate];
                        BigNumber *tenStr = [BigNumber bigNumberWithDecimalString:[decimalDeb stringValue]];
                        model.transferVusdDic[@"vusd"] = [CoinIDHelper getHexByDecimal:tenStr];
                    }
                }];
                
            }
            
        }];
    }
    //交易类型
    NSString * type = YLOCALIZED_UserVC(@"ETHtransactionInfoView_type");
    NSString * from = YLOCALIZED_UserVC(@"ETHtransactionInfoView_Receiving");
    NSString * to = model.num == 10?YLOCALIZED_UserVC(@"ethtransferdetailvc_outputaddress"):YLOCALIZED_UserVC(@"bancormanager_contractaddress");  
    NSString * value = YLOCALIZED_UserVC(@"ETHtransactionInfoView_Amount");
    NSString * gasfee = YLOCALIZED_UserVC(@"ethtransferdetailvc_gasfree");
    NSString * typeC = [NSString stringWithFormat:@"%@",token];
    NSString * rightTo = model.num == 10?model.toAddress:[model.contract stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSString * rightFrom = _et.address ;
    NSString * amount = [payNum stringByAppendingFormat:@" %@",model.symbol];
    
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
                    if (model.num == 1) {
                        [self nativeCallJSViewUpdate:dataDic];
                    }
                    else if (model.num == 3)//存入vns
                    {
                        [self DepositVnsnativeCallJSViewUpdate:dataDic];
                    }
                    else if (model.num == 4)//取回vns
                    {
                        [self retrieveVnsnativeCallJSViewUpdate:dataDic];
                    }
                    else if (model.num == 5)//偿还vusd
                    {
                        [self repayVusdNativeCallJSViewUpdate:dataDic];
                    }
                    else if (model.num == 6)//生成vusd
                    {
                        [self generateVusdNativeCallJSViewUpdate:dataDic];
                    }
                    else if (model.num == 7)//转移vusd
                    {
                        [self transferVusdNativeCallJSViewUpdate:dataDic];
                    }
                    else if (model.num == 8)//关闭vusd
                    {
                        [self cancelVusdNativeCallJSViewUpdate:dataDic];
                    }
                    else if (model.num == 9)//接收vusd
                    {
                        [self receiveTransferVusdNativeCallJSViewUpdate:dataDic];
                    }
                    else if (model.num == 10)//点对点转账
                    {
                        [self transfersendResultCallJSViewUpdate:dataDic];
                    }

                }];
                
            }
            
        } type:VDATYPE_Vuds];
        signView.datas = arrs ;
    }
}
#pragma mark - 改变模型vusd的值
- (void)changeModelVusdValue:(VDAIPopModel*)model
{
    [YChainBussiness queryLinkSpatVusd:self.et.address complationBack:^(id  _Nonnull data, NSInteger code) {
        
        if (data && code == 200 ) {
            NSDecimalNumber *decimalValue = [NSDecimalNumber decimalNumberWithString:model.vusdNum];
            NSString *rate = [YCommonMethods getNumberFromHex:data[@"rate"]];
            NSDecimalNumber * decimalRate = [NSDecimalNumber decimalNumberWithString:rate];
            NSDecimalNumber * decimalDeb = [decimalValue decimalNumberByMultiplyingBy:decimalRate];
            model.vusdNum = [decimalDeb stringValue];
        }
    }];
}
#pragma mark - 热钱包开始解锁并钱包
-(void)configVNSHotSign:(VDAIPopModel *)model signType:(VNSSignType)signType complationBack:(void(^)(id data))complationBack{
    
    NSString * alertstring = YLOCALIZED_UserVC(@"uservc_pleaseinputpwd") ;
    WEAK(self)
    [_et verifyWalletModelPinPasswordTitle:alertstring message:nil placeHolder:alertstring showInVc:self.containerVC complationBlock:^(BOOL status) {
        
        STRONG(weakObject)
        if (status) {
            
            [strongObject startVnsSign:model signType:signType complationBack:complationBack];
        }
        else
        {
            [UIViewController showInfoWithStatus:YLOCALIZED_UserVC(@"uservc_pwdiswrong")];
        }
    }];
    
}

#pragma mark - 开始签名
-(void)startVnsSign:(VDAIPopModel *)model signType:(VNSSignType)signType complationBack:(void(^)(id data))complationBack{
    
    NSString * to = [model.contract stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    model.transferVusdAddreess = [model.transferVusdAddreess stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSDecimalNumber * gaspriceNumber = [[NSDecimalNumber alloc] initWithString:self.gasprice];
    NSDecimalNumber * gasNumbel = [gaspriceNumber decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithString:@"1000000000"]];
    NSString * prvKey = [self.et deckAESCBC:self.et.prvKey];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"address"] = _et.address;
    NSString * vnsNum = @"0"; //金额
    if (signType == VNSSignType_Vusd_CdpAssetManagemente || signType == VNSSignType_Vusd_RepayVUSD_Frobt || signType == VNSSignType_Vusd_GenerateVUSD_Segmentation_Yes ) {
 
        params[@"managemente"] = @"VNS"; //vns       //资产名称
        params[@"toVns"] = model.vnsNum;
        if (signType == VNSSignType_Vusd_GenerateVUSD_Segmentation_Yes || signType == VNSSignType_Vusd_RepayVUSD_Frobt) {
            params[@"toVns"] = @"0";
        }
        params[@"toVusd"] = model.vusdNum;
        to = @"ec0b8d49fa29f9e675823d0ee464df16bcf044d1";
    }
    else if (signType == VNSSignType_Vusd_transferVUSD || signType == VNSSignType_Vusd_shutDownVUSD_frobt) //关闭
    {
        params[@"managemente"] = @"VNS"; //vns       //资产名称
        params[@"toVns"] = model.transferVusdDic[@"vns"];
        params[@"toVusd"] = model.transferVusdDic[@"vusd"];
        params[@"transferAddrs"] = model.transferVusdAddreess;
        to = @"ec0b8d49fa29f9e675823d0ee464df16bcf044d1";
    }
    else if (signType == VNSSignType_Vusd_DepositVNS_frobt || signType == VNSSignType_Vusd_RetrieveVNS) //存入frobt 取回frobt
    {
        params[@"managemente"] = @"VNS"; //vns       //资产名称
        params[@"toVns"] = model.vnsNum;
        params[@"toVusd"] = @"0";
        to = @"ec0b8d49fa29f9e675823d0ee464df16bcf044d1";
    }
    else if (signType == VNSSignType_Vusd_DepositVNS){ //存入
        vnsNum = model.vnsNum;
        to = @"0cb55fe67051eb5afe57fb3b670108074f85643e";
    }
    else if (signType == VNSSignType_Vusd_create)
    {
        vnsNum = model.vnsNum;
        to = @"0cb55fe67051eb5afe57fb3b670108074f85643e";
    }
    else if (signType == VNSSignType_Vusd_shutDownVUSD_Exit)
    {
        params[@"toVns"] = model.vusdAllBalance;
        to = @"0cb55fe67051eb5afe57fb3b670108074f85643e";
    }
    else if (signType == VNSSignType_Vusd_shutDownVUSD_Exit_Gem)
    {
        params[@"toVns"] = self.VNSSignType_Vusd_shutDownVUSD_Exit_Gem;
        to = @"0cb55fe67051eb5afe57fb3b670108074f85643e";
    }
    else if (signType == VNSSignType_Vusd_RetrieveVNS_exit)
    {
        to = @"0cb55fe67051eb5afe57fb3b670108074f85643e";
        params[@"toVns"] = model.vnsNum;
    }
    else if (signType == VNSSignType_Vusd_GenerateVUSD )
    {
        to = @"cc147bdbf6f86ad4a1c6f12aa7e4fefcb145bc68";
        params[@"toVns"] = model.vusdBalance;
    }
    else if (signType == VNSSignType_Vusd_RepayVUSD_Approve)
    {
        to = @"4183bbd377fca70c5cfe8529ba3ddaf4ea1d009f";
        params[@"address"] = @"cc147bdbf6f86ad4a1c6f12aa7e4fefcb145bc68";
    }
    else if (signType == VNSSignType_Vusd_RepayVUSD_Join)
    {
        to = @"cc147bdbf6f86ad4a1c6f12aa7e4fefcb145bc68";
        params[@"toVusd"] = model.vusdBalance;
    }
    else if (signType == VNSSignType_Vusd_shutDownVUSD_Join)
    {
        to = @"cc147bdbf6f86ad4a1c6f12aa7e4fefcb145bc68";
        params[@"toVusd"] = model.vusdBalance;
    }
    else if (signType == VNSSignType_Vusd_GenerateVUSD_Segmentation_No || signType == VNSSignType_Vusd_create_Segmentation_No )
    {
        to = @"ec0b8d49fa29f9e675823d0ee464df16bcf044d1";
        params[@"address"] = @"cc147bdbf6f86ad4a1c6f12aa7e4fefcb145bc68";
    }
    else if (signType == VNSSignType_Vusd_shutDownVUSD_Approve) //approve
    {
        to = @"4183bbd377fca70c5cfe8529ba3ddaf4ea1d009f";
        params[@"address"] = @"cc147bdbf6f86ad4a1c6f12aa7e4fefcb145bc68";
    }
    else if (signType == VNSSignType_Vusd_Bonus_Approve) //approve
    {
        to = @"cdcad0eb1364ad13892996c899a6baa5179c4318";
        params[@"address"] = @"f98db8d89a9c947bcca54dedb7509d743868d743";
        params[@"toVns"] = @"0";
    }
    else if (signType == VNSSignType_Vusd_Bonus_Approve_FuYi) //approve
    {
        to = @"cdcad0eb1364ad13892996c899a6baa5179c4318";
        params[@"address"] = @"f98db8d89a9c947bcca54dedb7509d743868d743";
        params[@"toVns"] = @"1";
    }
    else if (signType == VNSSignType_Vusd_Bonus_Grep)
    {
        to = @"56700c91e35cf1a071b43356cb96945e13673e5c";
        params[@"managemente"] = @"VNS"; //vns       //资产名称
        params[@"ret"] = model.transferVusdDic[@"ret"];
    }
    else if (signType == VNSSignType_Vusd_transferVUSD_Hope)
    {
        to = @"ec0b8d49fa29f9e675823d0ee464df16bcf044d1";
        params[@"address"] =  model.transferVusdAddreess;
    }
    else if (signType == VNSSignType_TOKEN_Vusd)
    {
        params[@"toVusd"] = model.vusdNum;
        to = @"4183bbd377fca70c5cfe8529ba3ddaf4ea1d009f";
        params[@"address"] = [model.toAddress stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    }
    else if (signType == VNSSignType_VNS)
    {
        vnsNum = model.vnsNum;
        to = [model.toAddress stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    }
    NSString * signStr = [CoinIDHelper vnsHotSignTransWithNonce:self.nonce gasPrice:gasNumbel.stringValue gasLimit:self.estimateGas to:to value:vnsNum data:@"" chainID:self.version VNSSignType:signType contract:to decimal:18 prvStr:prvKey params:params helperComplation:nil];
    
    if (signStr) {
       
        [YChainBussiness requerstVNSData:signStr complationBack:^(id  _Nonnull data, NSInteger code) {
            
            if (data && code == 200) {
                self.nonce = [NSString stringWithFormat:@"%d",[self.nonce intValue] +1];
                if (signType  == VNSSignType_Vusd_create) {
                    [self startVnsSign:model signType:VNSSignType_Vusd_CdpAssetManagemente complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_CdpAssetManagemente)
                {
                    if (self.segmentation == 0) { //首次分割 hop
                       [self startVnsSign:model signType:VNSSignType_Vusd_create_Segmentation_No complationBack:complationBack];
                    }
                    else
                    {
                        [self startVnsSign:model signType:VNSSignType_Vusd_GenerateVUSD complationBack:complationBack];
                    }
                    
                }
                else if (signType == VNSSignType_Vusd_create_Segmentation_No)
                {
                    [self startVnsSign:model signType:VNSSignType_Vusd_GenerateVUSD complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_DepositVNS)
                {
                    [self startVnsSign:model signType:VNSSignType_Vusd_DepositVNS_frobt complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_RetrieveVNS)
                {
                    [self startVnsSign:model signType:VNSSignType_Vusd_RetrieveVNS_exit complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_RepayVUSD_Approve)
                {
//                    if (self.repayStatus == 1) {
//                         model.vusdNum = self.vusdValueJoin;
//                    }
                    [self startVnsSign:model signType:VNSSignType_Vusd_RepayVUSD_Join complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_RepayVUSD_Join)
                {
                    [self startVnsSign:model signType:VNSSignType_Vusd_RepayVUSD_Frobt complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_RepayVUSD_Frobt)
                {
                    if (self.repayStatus == 1) {
                         [self startVnsSign:model signType:VNSSignType_Vusd_Bonus_Approve complationBack:complationBack];
                    }
                    else
                    {
                        if (complationBack) {
                            complationBack(data);
                            return ;
                        }
                    }
                }
                else if (signType == VNSSignType_Vusd_Bonus_Approve_FuYi)
                {
                    [self startVnsSign:model signType:VNSSignType_Vusd_Bonus_Grep complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_Bonus_Approve)
                {
                    [self startVnsSign:model signType:VNSSignType_Vusd_Bonus_Approve_FuYi complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_GenerateVUSD_Segmentation_No)
                {
                    [self startVnsSign:model signType:VNSSignType_Vusd_GenerateVUSD_Segmentation_Yes complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_GenerateVUSD_Segmentation_Yes){
                    [self startVnsSign:model signType:VNSSignType_Vusd_GenerateVUSD complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_shutDownVUSD_Approve)//关闭
                {
                    if (self.reslutComparison == YES) { //大于余额
                        [self startVnsSign:model signType:VNSSignType_Vusd_shutDownVUSD_Join complationBack:complationBack];
                    }
                    else
                    {
                        [self startVnsSign:model signType:VNSSignType_Vusd_shutDownVUSD_frobt complationBack:complationBack];
                    }
                
                }
                else if (signType == VNSSignType_Vusd_shutDownVUSD_Join){
                    [self startVnsSign:model signType:VNSSignType_Vusd_shutDownVUSD_frobt complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_shutDownVUSD_frobt){
                    [self startVnsSign:model signType:VNSSignType_Vusd_shutDownVUSD_Exit complationBack:complationBack];
                }
                else if (signType == VNSSignType_Vusd_shutDownVUSD_Exit && self.VNSSignType_Vusd_shutDownVUSD_Exit_Gem != nil){
                    [self startVnsSign:model signType:VNSSignType_Vusd_shutDownVUSD_Exit_Gem complationBack:complationBack];
                }
                else
                {
                    if (complationBack) {
                        complationBack(data);
                    }
                }
            }
            else//失败
            {
                [self failureNativeCallJSViewUpdate:@""];
            }
        }];
    }
}


#pragma mark - 获取gas price
-(void)requestVNSAddresssInfo:(NSString*)address contract:(NSString*)contract complationBack:(void(^)(void))complationBack {
    
    //查询gas price nonce
    [YChainBussiness requestVNSAddresssInfo:address to:nil contract:contract data:nil complationBack:^(id  _Nonnull data, NSInteger code) {
        
        if (code == 200) {
            
            for (ETHTransferParticularsModel * mdoel in data) {
                //
                if ([mdoel.name isEqualToString:@"gasPrice"]) {
                    
                    self.gasprice = @"50";
                }
                else if ([mdoel.name isEqualToString:@"estimateGas"] || [mdoel.name isEqualToString:@"tokenEstimateGas"] ){
                    
                    self.estimateGas = @"8000000";
                }
                else if ([mdoel.name isEqualToString:@"transaction"]){
                    
                    self.nonce = [YCommonMethods getNumberFromHex:mdoel.data.result] ;
                }
                else if ([mdoel.name isEqualToString:@"version"]){
                    
                    self.version = @"2018" ;
                }
            }
            
            if (complationBack) {
                complationBack();
            }
        }
    }];
    
}

#pragma mark - 根据num 判断签名类型
-(VNSSignType)configVNSSignType:(VDAIPopModel*)model{
    
    VNSSignType signType = VNSSignType_VNS ;

    if (model.num == VDAIRequestCode_Vusd_create) {

        signType = VNSSignType_Vusd_create ;
    }
    if (model.num == VDAIRequestCode_Vusd_CdpAssetManagemente) {

        signType = VNSSignType_Vusd_CdpAssetManagemente ;
    }
    if (model.num == VDAIRequestCode_Vusd_DepositVNS) {

        signType = VNSSignType_Vusd_DepositVNS ;
    }
    if (model.num == VDAIRequestCode_Vusd_RetrieveVNS) {

        signType = VNSSignType_Vusd_RetrieveVNS ;
    }
    if (model.num == VDAIRequestCode_Vusd_RepayVUSD) {
        
        signType = VNSSignType_Vusd_RepayVUSD_Frobt ;
    }
    if (model.num == VDAIRequestCode_Vusd_GenerateVUSD) {
        
        signType = VNSSignType_Vusd_GenerateVUSD ;
    }
    if (model.num == VDAIRequestCode_Vusd_transferVUSD) {
        
        signType = VNSSignType_Vusd_transferVUSD ;
    }
    if (model.num == VDAIRequestCode_Vusd_shutDownVUSD) {
        
        signType = VNSSignType_Vusd_shutDownVUSD_frobt ;
    }
    if (model.num == VDAIRequestCode_Vusd_AgreeTransfer) {
        
        signType = VNSSignType_Vusd_transferVUSD_Hope ;
    }
    if (model.num == VDAIRequestCode_Vns_Transfer) {
        
        signType = model.isToken?VNSSignType_TOKEN_Vusd:VNSSignType_VNS ;
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
                    [strongObject nativeCallJSUpdateAddressPermissions:strongObject.et.address];
                }];
            }
            else if (btnState == -1){
                
                NSLog(@"requestUpdateAddressPermissions");
            }
        } type:VDATYPE_Vuds datas:result];
    }];
}
//获取地址判断是否注册
-(void)nativeCallJSGetAddressPermissions:(id)params{
    
    NSString * address = params ;
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"获取成功！" forKey:@"msg" ];
    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary] ;
    [dataDic    setObject:@[address] forKey:@"addressList"];
    [infoDic setObject:dataDic forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"returnGetVdaiAddressResult('%@')",trans];
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
//创建vusd是否成功
-(void)nativeCallJSViewUpdate:(id)params{
    
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"获取成功！" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"cresteVdaiResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
//存入vns
-(void)DepositVnsnativeCallJSViewUpdate:(id)params{
    
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"存入成功" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"depositVnsResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
//取回vns
-(void)retrieveVnsnativeCallJSViewUpdate:(id)params{
    
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"取回成功" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"retrieveVnsResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
//偿还Vusd
-(void)repayVusdNativeCallJSViewUpdate:(id)params{
    
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"偿还成功" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"repayVnsResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
//生成Vusd
-(void)generateVusdNativeCallJSViewUpdate:(id)params{
    
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"偿还成功" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"generateVnsResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
//转移Vusd
-(void)transferVusdNativeCallJSViewUpdate:(id)params{
    
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"转移成功" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"transferVusdResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
//接受Vusd
-(void)receiveTransferVusdNativeCallJSViewUpdate:(id)params{
    
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"接收成功" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"receiveTransferVusdResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
//取消Vusd
-(void)cancelVusdNativeCallJSViewUpdate:(id)params{
    
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"关闭成功" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"cancelVusdResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
//点对点转账
-(void)transfersendResultCallJSViewUpdate:(id)params{
    
    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@200 forKey:@"status" ];
    [infoDic setObject:@"发起成功" forKey:@"msg" ];
    [infoDic setObject:params forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"transfersendResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
-(void)failureNativeCallJSViewUpdate:(id)params{

    if (!params) {
        return ;
    }
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@400 forKey:@"status" ];
    [infoDic setObject:@"操作失败" forKey:@"msg" ];
    NSString * trans = [infoDic mj_JSONString] ;
    NSString * jsonStr = [NSString stringWithFormat:@"faliureResult('%@')",trans];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}
-(void)nativeCallJSViewSubUpdate:(id)params{
    
    NSString * jsonStr = [NSString stringWithFormat:@"sonResult('%@')",@"3"];
    [self evaluateJavaScriptWithFunctionNameString:jsonStr];
}

-(void)evaluateJavaScriptWithFunctionNameString:(NSString*)function{
    
    NSLog(@"function方法名 %@",function);
    [self.webView evaluateJavaScript:function completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
        NSLog(@"error  %@",error);
    }];
}

@end
