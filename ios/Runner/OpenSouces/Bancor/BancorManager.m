//
//  BancorManager.m
//  CoinID
//
//  Created by MWTECH on 2019/10/9.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "BancorManager.h"
#import "YHtmlNativeEntity.h"
#import "YRequireAddressView.h"
#import "YChainBussiness.h"
#import "ETHTransferParticularsModel.h"
#import <MJExtension/MJExtension.h>
#import "WalletObject.h"
#import "Enum.h"
#import "CoinIDHelper.h"
#import "CoinIDHelper+VNSSign.h"
#import "ChannelDapp.h"
#import "YCommonMethods.h"
#import "UIViewController+HUD.h"
#import "RequestMethod.h"
#define kLeftText @"kLeftText"
#define kContent @"kContent"

@interface BancorManager ()

@property (nonatomic , strong) NSMutableArray *vnsAdrs;
@property (copy , nonatomic) NSString *fromAddress;//付款地址
@property (copy , nonatomic) NSString *estimateGas ;
@property (copy , nonatomic) NSString *nonce ;
@property (copy , nonatomic) NSString *version ;
@property (assign , nonatomic) CGFloat ethAmount;
@property (assign , nonatomic) CGFloat minersFee;//矿工费
@property (strong ,nonatomic) NSMutableArray *btcUnSpenList;
@property (nonatomic , assign ) double gasB;
@property (nonatomic , assign ) double gasP;
@property (nonatomic , assign ) double gasRes;
@property (nonatomic , assign ) double gasD;
@property (nonatomic , assign ) double gasD_18;
@property (copy , nonatomic) NSString *gasprice ;

@property (nonatomic,weak) UIViewController * containerVC; //弱引用
@property (nonatomic,strong) YHtmlNativeEntity * htmlModel ;
@property (nonatomic,strong) NSDecimalNumber * canCrossValue ;

@property (nonatomic,strong)WalletObject  * et ;
@property (nonatomic,assign) double  balNum ;

@end


@implementation BancorManager

+(instancetype)shareManagerWithContainerVC:(UIViewController*)vc defalutObject:(id)walletObject {

    BancorManager * bancorManager = [[BancorManager alloc] init ];
    bancorManager.containerVC = vc ;
    bancorManager.et = walletObject;
    return bancorManager ;
}

-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    NSLog(@"prompt  %@",prompt);
   
    NSDecimalNumberHandler *roundBanker = [NSDecimalNumberHandler       decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                                       scale:0
                                                                                            raiseOnExactness:NO
                                                                                             raiseOnOverflow:NO
                                                                                            raiseOnUnderflow:NO
                                                                                         raiseOnDivideByZero:YES];
    NSDictionary *originDic = [prompt mj_JSONObject] ;
    YHtmlNativeEntity * htmlModelN = [YHtmlNativeEntity mj_objectWithKeyValues:originDic];
    //交易类型
    NSString * type = YLOCALIZED_UserVC(@"ETHtransactionInfoView_type");
    NSString * from = YLOCALIZED_UserVC(@"ETHtransactionInfoView_Receiving");
    NSString * to = YLOCALIZED_UserVC(@"bancormanager_contractaddress");
    NSString * value = YLOCALIZED_UserVC(@"ETHtransactionInfoView_Amount");
    NSString * gasfee = YLOCALIZED_UserVC(@"ethtransferdetailvc_gasfree");
    NSString * typecontent = [NSString stringWithFormat:@"%@%@",YLOCALIZED_UserVC(@"bancormaner_exchange"),htmlModelN.data.info.symbols];
    
    NSString * rightTo = [@"0x" stringByAppendingFormat:@"%@",htmlModelN.data.info.bancorConverterAddress] ;
    NSString * rightFrom = htmlModelN.data.info.payAddress  ;
    NSString * symbol = htmlModelN.data.info.symbols ;
    NSString * amount = [htmlModelN.data.info.amount stringByAppendingFormat:@" %@",symbol];
        
    if ([htmlModelN.requester isEqualToString:@"bancor"]) {
        
        if (htmlModelN.requestType  == 1 || htmlModelN.requestType == 3) {
            
            WEAK(self)
            [self requestVNSAddresssInfo:rightFrom contract:rightTo complationBack:^{
                
                STRONG(weakObject)
                NSDecimalNumber * gasNumber = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%.1f",self.gasRes]];
                NSDecimalNumber * gasValue = [gasNumber decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithString:@"1000000000"] withBehavior:roundBanker];
                gasValue = [gasValue decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:self.estimateGas]];
                gasValue = [gasValue decimalNumberByMultiplyingByPowerOf10:-18];

                NSMutableArray * arrs = [NSMutableArray array];
                [arrs addObject:@{kLeftText :type ,kContent:typecontent}];
                [arrs addObject:@{kLeftText :from ,kContent:rightFrom}];
                [arrs addObject:@{kLeftText :to ,kContent:rightTo}];
                [arrs addObject:@{kLeftText :value ,kContent:amount}];
                [arrs addObject:@{kLeftText :gasfee ,kContent:gasValue.stringValue}];
                
                YRequireSignView * signView = [YRequireSignView showWithAcitonBlock:^(NSInteger actionType) {
                    
                    if (actionType == 1) {
                        
                        [strongObject configVNSSign:strongObject.et htmlModel:htmlModelN completionHandler:completionHandler];
                        
                    }else {
                        
                        completionHandler(nil);
                    }
                    
                } type:VDATYPE_Bancor];
                signView.datas = arrs ;
                
            }];
            
        }
        else if (htmlModelN.requestType == 2)
        {

            [self fetchDIDAddress:completionHandler];

        }
        else{
            //获取did
            [self fetchDIDAddress:completionHandler];
        }
    }
    else
    {
        [UIViewController dismiss];
        completionHandler(nil);
    }
}

-(void)configVNSSign:(WalletObject*)et htmlModel:(YHtmlNativeEntity*)htmlModel  completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    _htmlModel = htmlModel ;
    
    NSString * alertstring = YLOCALIZED_UserVC(@"uservc_pleaseinputpwd") ;
    NSDecimalNumberHandler *roundBanker = [NSDecimalNumberHandler       decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                                         scale:0
                                                                                              raiseOnExactness:NO
                                                                                               raiseOnOverflow:NO
                                                                                              raiseOnUnderflow:NO
                                                                                           raiseOnDivideByZero:YES];
    
    NSString * bancorConverter = htmlModel.data.info.bancorConverterAddress ;
    NSString * vnserToken = htmlModel.data.info.etherTokenAddress ;
    NSString * smartToken = htmlModel.data.info.smartTokenAddress ;
    
    NSString * value = htmlModel.data.info.amount ;
    NSString * symbol = htmlModel.data.info.symbols ;
    
    NSDecimalNumber * gasNumber = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%.1f",self.gasRes]];
    NSDecimalNumber * gasValue = [gasNumber decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithString:@"1000000000"] withBehavior:roundBanker];
    
    NSDecimalNumber * gas = [gasValue decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:self.estimateGas]];
    gas = [gas decimalNumberByMultiplyingByPowerOf10:-18];
    self.minersFee = gas.doubleValue ;
    self.fromAddress = et.address ;
    self.vnsAdrs = @[et.address].mutableCopy ;
   
    BOOL istokenConvert = ![symbol isEqualToString:@"VNS"] ;

    //班科主币判断主币余额
    if (!istokenConvert && value.doubleValue > self.balNum) {
        
        NSString * sign =  [self InsufficientBalance];
        completionHandler(sign);
        return ;
    }
    
    NSString * merchantName = htmlModel.data.info.merchantName ; //cat
    NSString * connectorName = htmlModel.data.info.connectorName ;// bancor 连接器
    
    VNSSignType signtype = htmlModel.data.info.istoken ? VNSSignType_TOKEN : VNSSignType_VNS ;
    signtype = (VNSSignType)htmlModel.data.info.signtype ;
    
    if ([symbol isEqualToString:connectorName]) {
            
        //buy
        signtype = VNSSignType_BANCORBUY ;
    }else{
        
        //sell
        signtype = VNSSignType_BANCORSELL ;
    }
    
    BOOL canAllowance = YES ;
    if ([merchantName isEqualToString:@"VNS"] || [symbol isEqualToString:@"VNS"]) {
       
        canAllowance = NO ;
    }
    WEAK(self)
    [et verifyWalletModelPinPasswordTitleStatus:alertstring message:nil placeHolder:alertstring showInVc:self.containerVC complationBlock:^(NSInteger status) {
        STRONG(weakObject)
        if (status == YVerifyPasswordState_Ok) {
            
            if (canAllowance) {
                
                NSDictionary * infos = @{@"addressToken":bancorConverter};
                NSMutableDictionary * params = [NSMutableDictionary dictionary] ;
                NSString * dataStr = [YCommonMethods convertDataToHexStr:[CoinIDHelper convertWithETHDataList:VNSSignType_Allowance coinType:MCoinType_VNS to:self.fromAddress value:0 decimal:0 realMoney:nil params:infos]];
                NSString * data = [NSString stringWithFormat:@"0x%@",dataStr];
                params[@"id"] = @"1";
                params[@"jsonrpc"] = @"2.0";
                params[@"method"] = @"vns_call";
                params[@"params"] = @[@{@"data":data,@"to":[@"0x" stringByAppendingString:vnserToken]},@"latest"];
                    
                [RequestMethod requestMainChainTransaction:YRequest_POST coinType:MCoinType_VNS didParam:params didUrl:VNSChainRequestURL didSuccess:^(id response) {
                    if (response) {
                        
                        NSString * result = response[@"result"];
                        NSString * canCrossValue = [YCommonMethods getNumberFromHex:result];
                        NSDecimalNumber * canCrossNumber = [NSDecimalNumber decimalNumberWithString:canCrossValue];
                        NSDecimalNumber * canCross  = [canCrossNumber  decimalNumberByMultiplyingByPowerOf10:-18];
                        strongObject.canCrossValue = canCross ;
                        NSLog(@"canCrossValue %@",canCross.stringValue);
                        if (strongObject.canCrossValue.doubleValue > 0) {
                            
                            NSDictionary * params = @{@"bancorConverter":bancorConverter,
                                                      @"vnserToken":vnserToken,
                                                      @"smartToken":smartToken,
                                                      @"istokenConvert":@(istokenConvert)
                            };
                            
                            [strongObject startVnsSign:et htmlModel:htmlModel signType:signtype params:params completionHandler:completionHandler];
                            
                        }else{
                           
                            NSDictionary * params = @{@"addressToken":bancorConverter,
                                                    };
                            //approve
                            [strongObject startVnsSign:et htmlModel:htmlModel signType:VNSSignType_Approve params:params completionHandler:^(NSString * _Nullable pushstr) {
                                
                                
                                NSDictionary * newParams = @{@"bancorConverter":bancorConverter,
                                                          @"vnserToken":vnserToken,
                                                          @"smartToken":smartToken,
                                                          @"istokenConvert":@(istokenConvert)
                                };
                                strongObject.nonce = [NSString stringWithFormat:@"%ld",self.nonce.integerValue + 1];
                                [strongObject startVnsSign:et htmlModel:htmlModel signType:signtype params:newParams completionHandler:completionHandler];
                            }];
                        }
                    }
                } didFailed:^(id error) {
                    
                    completionHandler([self bancorTransFailere]);
                    [UIViewController showErrorWithStatus:YLOCALIZED_UserVC(@"transferopratevc_transferfailere")];
                }];
                
                
            }else {
             
                NSDictionary * params = @{@"bancorConverter":bancorConverter,
                                          @"vnserToken":vnserToken,
                                          @"smartToken":smartToken,
                                          @"istokenConvert":@(istokenConvert)
                };
                
                [strongObject startVnsSign:et htmlModel:htmlModel signType:signtype params:params completionHandler:completionHandler];
            }
        }
        else if (status == YVerifyPasswordState_Wrong){
            
            [UIViewController showErrorWithStatus:YLOCALIZED_UserVC(@"transferopratevc_pwdiswrong")];
            completionHandler(nil);
        }
        else if (status == YVerifyPasswordState_Cancle){
            
            //401取消交易
            completionHandler([self cancleBancorTrans]);
        }
    }];
}


#pragma mark - 开始签名
-(void)startVnsSign:(WalletObject*)et htmlModel:(YHtmlNativeEntity*)htmlModel signType:(VNSSignType)signType params:(id)params completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    
    NSDecimalNumberHandler *roundBanker = [NSDecimalNumberHandler       decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                                                                                       scale:0
                                                                                            raiseOnExactness:NO
                                                                                             raiseOnOverflow:NO
                                                                                            raiseOnUnderflow:NO
                                                                                         raiseOnDivideByZero:YES];
        
    NSString * bancorConverter = htmlModel.data.info.bancorConverterAddress ;
    NSString * nonce = self.nonce ;
    NSString * gaslimit = self.estimateGas ;
    NSString * to = bancorConverter ;
    NSString * value = htmlModel.data.info.amount ;
    NSString * chainID = self.version ;
    NSString * contract = htmlModel.data.info.contract ;
    contract = bancorConverter ;
    NSInteger decimal = [htmlModel.data.info.decimals integerValue] ;
    NSDecimalNumber * gasNumber = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%.1f",self.gasRes]];
    NSDecimalNumber * gasValue = [gasNumber decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithString:@"1000000000"] withBehavior:roundBanker];
    
    NSDecimalNumber * gas = [gasValue decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:self.estimateGas]];
    gas = [gas decimalNumberByMultiplyingByPowerOf10:-18];
    self.minersFee = gas.doubleValue ;
    self.fromAddress = et.address ;
    self.vnsAdrs = @[et.address].mutableCopy ;
    
    if (signType == VNSSignType_Approve) {
        
        to = htmlModel.data.info.etherTokenAddress ;
        value = @"0";
        contract = to ;
    }
    
    NSString * privatekey = [et deckAESCBC:et.prvKey];
    WEAK(self)
    [CoinIDHelper vnsHotSignTransWithNonce:nonce  gasPrice:gasValue.stringValue gasLimit:gaslimit to:to value:value  data:@"" chainID:chainID VNSSignType:signType contract:contract decimal:decimal prvStr:privatekey params:params  helperComplation:^(id data, BOOL status) {
        
        if (status && data) {
            
            NSLog(@"签名成功");
            [weakObject requerstVNSData:data completionHandler:completionHandler];
        }
        else {
            NSLog(@"签名失败");
            completionHandler([weakObject bancorTransFailere]);
        }
    }];
    
}




- (NSString *)InsufficientBalance
{
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@402 forKey:@"status" ];
    [infoDic setObject:@"余额不足" forKey:@"msg" ];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:[NSString stringWithFormat:@"%f",self.minersFee]forKey:@"minersFee"];
    [dataDic setObject:self.fromAddress forKey:@"fromAddress"];
    [dataDic setObject:self.htmlModel.data.info.symbols forKey:@"symbols"];
    [dataDic setObject:[NSString  stringWithFormat:@"%ld",(long)self.htmlModel.data.chainType] forKey:@"chainType"];
    [infoDic setObject:dataDic forKey:@"data"];
    
    NSString * trans = [infoDic mj_JSONString] ;
    return trans;
    
}

- (NSString *)bancorTransFailere
{
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@400 forKey:@"status" ];
    [infoDic setObject:@"交易失败" forKey:@"msg" ];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:[NSString stringWithFormat:@"%f",self.minersFee]forKey:@"minersFee"];
    [dataDic setObject:self.fromAddress forKey:@"fromAddress"];
    [dataDic setObject:self.htmlModel.data.info.symbols forKey:@"symbols"];
    [dataDic setObject:[NSString  stringWithFormat:@"%ld",(long)self.htmlModel.data.chainType] forKey:@"chainType"];
    [infoDic setObject:dataDic forKey:@"data"];
    
    NSString * trans = [infoDic mj_JSONString] ;
    return trans;
    
}
- (NSString *)cancleBancorTrans{
    
    NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
    [infoDic setObject:@401 forKey:@"status" ];
    [infoDic setObject:@"取消交易" forKey:@"msg" ];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    [dataDic setObject:[NSString stringWithFormat:@"%f",self.minersFee]forKey:@"minersFee"];
    [dataDic setObject:self.fromAddress forKey:@"fromAddress"];
    [dataDic setObject:self.htmlModel.data.info.symbols forKey:@"symbols"];
    [dataDic setObject:[NSString  stringWithFormat:@"%ld",(long)self.htmlModel.data.chainType] forKey:@"chainType"];
    [infoDic setObject:dataDic forKey:@"data"];
    NSString * trans = [infoDic mj_JSONString] ;
    return trans;
    
}


-(void)fetchDIDAddress:(void (^)(NSString * _Nullable))completionHandler{
    
    WEAK(self)
    [[ChannelDapp sharedInstance] datas:MCoinType_VNS result:^(id  _Nullable result) {
        
        STRONG(weakObject)
        [YRequireAddressView showWithAcitonBlock:^(NSInteger btnState) {
            
            NSMutableArray *adss = [NSMutableArray array];
            NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
            __block NSInteger status = 401  ;
            if (btnState == 1) {
                
                [[ChannelDapp sharedInstance] getDid:^(id  _Nullable result) {
                    
                    WalletObject * object = result;
                    strongObject.et = object;
                    [adss addObject:object.address];
                    NSMutableDictionary * dataDic = [NSMutableDictionary dictionary] ;
                    status = 200 ;
                    [infoDic setObject:@"获取成功！" forKey:@"msg" ];
                    [dataDic    setObject:adss forKey:@"vnsAddress"];
                    [infoDic setObject:dataDic forKey:@"data"];
                    [infoDic setObject:@(status) forKey:@"status" ];
                    NSString * trans = [infoDic mj_JSONString] ;
                    if (completionHandler) {
                        completionHandler(trans);
                    }
                }];
            }
            else if (btnState == -1){
                [infoDic setObject:@(status) forKey:@"status" ];
                NSString * trans = [infoDic mj_JSONString] ;
                if (completionHandler) {
                    completionHandler(trans);
                }
                NSLog(@"requestUpdateAddressPermissions");
            }
        } type:VDATYPE_Bancor datas:result];
    }];
}


//-(void)openOldViewSign:(void (^)(NSString * _Nullable))completionHandler htmlModelN:(YHtmlNativeEntity * )htmlModelN{
//
//    if (htmlModelN.requestType == 1) {
//
//        self.eheView = [[LoadWebView alloc ] initWithFrame:CGRectMake(0, Y_SCREEN_HEIGHT, Y_SCREEN_WIDTH , 200)];
//
//    }
//    else
//    {
//        self.eheView = [[LoadWebView alloc ] initWithFrame:CGRectMake(0, Y_SCREEN_HEIGHT, Y_SCREEN_WIDTH , 450)];
//    }
//
//    self.eheView.htmlModel = htmlModelN ;
//    [self.eheView showInWindow];
//
//    WEAK
//    self.eheView.sureClickAction = ^(CGFloat sureBtn, YHtmlNativeEntity * htmlModel, int transactionType, NSString * from, NSArray * vnsAdrs, NSString * version, NSString *gasprice, NSString * estimateGas, NSString * nonce)
//    {
//
//        STRONG
//        self.minersFee = sureBtn;
//        self.fromAddress = from;
//        self.nonce = nonce;
//        self.gasprice = gasprice;
//        self.estimateGas = estimateGas;
//        self.vnsAdrs = [NSMutableArray arrayWithArray:vnsAdrs];
//        if (transactionType == -1) {//放弃支付
//
//            [UIView animateWithDuration:0.3 animations:^{
//
//                self.eheView.backgroundView.alpha = 0;
//                self.eheView.frame = CGRectMake(0, Y_SCREEN_HEIGHT, Y_SCREEN_WIDTH, 0);
//
//            } completion:^(BOOL finished) {
//
//                [self.eheView.backgroundView removeFromSuperview];
//                [self.eheView removeFromSuperview];
//            }];
//
//            completionHandler(nil);
//
//        }
//        else if(transactionType == 0) { // 余额不足
//
//            NSString * trans = [self InsufficientBalance];
//            [self.eheView hide];
//            completionHandler(trans);
//        }
//        else
//        {
//            [self.eheView hide];
//
//            NSString * alertstring = YLOCALIZED_UserVC(@"uservc_pleaseinputpwd") ;
//
//            YWalletEntity * et = [YDataManager fetchWalletModelFromName:from] ;
//            htmlModel.data.info.et = et ;
//
//            if (et.YwalletFromType == YWalletFromType_ColdWallet) {
//
//                YColdOperating state = [YBleWalletManager shareManager].coldOperating ;
//
//                if (htmlModel.data.chainType == YHtmlChainType_VNS ){
//                    if (state == YColdOperating_DonePin) {
//
//                        NSString * fee = [YCommonMethods deleteBlankAndEnter: [NSString stringWithFormat:@"%f ETH",sureBtn]];
//                        NSString * symbol = htmlModel.data.info.symbols ;
//                        VNSSignType signtype = htmlModel.data.info.istoken ? VNSSignType_TOKEN : VNSSignType_VNS ;
//                        signtype = htmlModel.data.info.signtype ;
//                        NSString * bancorConverter = htmlModel.data.info.bancorConverterAddress ;
//                        NSString * vnserToken = htmlModel.data.info.etherTokenAddress ;
//                        NSString * smartToken = htmlModel.data.info.smartTokenAddress ;
//
//                        [CoinIDHelper vnsColdWalletSignTransWithNonce:[ [[CoinIDHelper numberHexString:self.nonce] stringValue] stringByReplacingOccurrencesOfString:@"0x" withString:@""]
//                                                             gasPrice:[self.gasprice  stringByReplacingOccurrencesOfString:@"0x" withString:@""] gasLimit:[[CoinIDHelper numberHexString:self.estimateGas] stringValue]
//                                                                   to:[ htmlModelN.data.info.to stringByReplacingOccurrencesOfString:@"0x" withString:@""]
//                                                                value:htmlModel.data.info.amount
//                                                                 data:@""
//                                                              chainID:self.version
//                                                          VNSSignType:signtype
//                                                             contract:[htmlModelN.data.info.contract stringByReplacingOccurrencesOfString:@"0x" withString:@""]
//                                                              decimal:[htmlModel.data.info.decimals integerValue]
//                                                                  fee:fee
//                                                               symbol:symbol
//                                                      bancorConverter:bancorConverter
//                                                           vnserToken:vnserToken
//                                                           smartToken:smartToken
//                                                               params:nil
//                                                     helperComplation:^(id data, BOOL status) {
//
//                            if (status) {
//
//                                NSLog(@"签名成功");
//                                [self requerstVNSData:(NSString *)data completionHandler:completionHandler];
//
//                            }
//                            else
//                            {
//                                NSLog(@"签名失败");
//                                completionHandler(nil);
//                            }
//                        }];
//
//                    }
//                    else
//                    {
//                        [_containerVC unlockPINEnity:et complation:^(YColdOperating operating) {
//
//                            if (operating == YColdOperating_DonePin) { //解锁成功
//
//                                NSString * fee = [YCommonMethods deleteBlankAndEnter: [NSString stringWithFormat:@"%f ETH",sureBtn]];
//                                NSString * symbol = htmlModel.data.info.symbols ;
//                                VNSSignType signtype = htmlModel.data.info.istoken ? VNSSignType_TOKEN : VNSSignType_VNS ;
//                                signtype = htmlModel.data.info.signtype ;
//                                NSString * bancorConverter = htmlModel.data.info.bancorConverterAddress ;
//                                NSString * vnserToken = htmlModel.data.info.etherTokenAddress ;
//                                NSString * smartToken = htmlModel.data.info.smartTokenAddress ;
//
//                                [CoinIDHelper vnsColdWalletSignTransWithNonce:[ [[CoinIDHelper numberHexString:self.nonce] stringValue] stringByReplacingOccurrencesOfString:@"0x" withString:@""]
//                                                                     gasPrice:[self.gasprice  stringByReplacingOccurrencesOfString:@"0x" withString:@""] gasLimit:[[CoinIDHelper numberHexString:self.estimateGas] stringValue]
//                                                                           to:[ htmlModelN.data.info.to stringByReplacingOccurrencesOfString:@"0x" withString:@""]
//                                                                        value:htmlModel.data.info.amount
//                                                                         data:@""
//                                                                      chainID:self.version
//                                                                  VNSSignType:signtype
//                                                                     contract:[htmlModelN.data.info.contract stringByReplacingOccurrencesOfString:@"0x" withString:@""]
//                                                                      decimal:[htmlModel.data.info.decimals integerValue]
//                                                                          fee:fee
//                                                                       symbol:symbol
//                                                              bancorConverter:bancorConverter
//                                                                   vnserToken:vnserToken
//                                                                   smartToken:smartToken
//                                                                       params:nil
//                                                             helperComplation:^(id data, BOOL status) {
//
//                                    if (status) {
//
//                                        NSLog(@"签名成功");
//                                        [self requerstVNSData:(NSString *)data completionHandler:completionHandler];
//
//                                    }
//                                    else
//                                    {
//                                        NSLog(@"签名失败");
//                                        completionHandler(nil);
//                                    }
//                                }];
//
//
//                            }
//                            else
//                            {
//
//                                if (operating == YColdOperating_None) {
//
//                                    //[UIViewController showInfoWithStatus:@"蓝牙链接失败"];
//
//                                }
//
//                                completionHandler(nil);
//                            }
//
//                        }];
//                    }
//                }
//                else
//                {
//                    completionHandler(nil);
//                }
//
//            }
//            else
//            {
//
//                [et verifyWalletModelPinPasswordTitleStatus:alertstring message:nil placeHolder:alertstring showInVc:self.containerVC complationBlock:^(NSInteger status) {
//
//                    if (status == YVerifyPasswordState_Ok) {
//
//                        if (htmlModel.data.chainType == YHtmlChainType_VNS ){
//
//                            self.version = @"2018" ;
//                            NSString * privatekey = [htmlModel.data.info.et deckAESCBC:htmlModel.data.info.et.leadPrivate_owner];
//                            VNSSignType signtype = htmlModel.data.info.istoken ? VNSSignType_TOKEN : VNSSignType_VNS ;
//                            signtype = htmlModel.data.info.signtype ;
//                            NSString * bancorConverter = htmlModel.data.info.bancorConverterAddress ;
//                            NSString * vnserToken = htmlModel.data.info.etherTokenAddress ;
//                            NSString * smartToken = htmlModel.data.info.smartTokenAddress ;
//
//                            NSDictionary * params = @{@"bancorConverter":bancorConverter,@"vnserToken":vnserToken,@"smartToken":smartToken};
//
//
//                            [CoinIDHelper vnsHotSignTransWithNonce:[[CoinIDHelper numberHexString:self.nonce] stringValue] gasPrice:self.gasprice gasLimit:[[CoinIDHelper numberHexString:self.estimateGas] stringValue] to:htmlModel.data.info.to value:htmlModel.data.info.amount  data:@"" chainID:self.version VNSSignType:signtype contract:htmlModel.data.info.contract decimal:[htmlModel.data.info.decimals integerValue] prvStr:privatekey
//                                                            params:params
//                                                  helperComplation:^(id data, BOOL status) {
//
//                                if (status) {
//                                    NSLog(@"签名成功");
//                                    [self requerstVNSData:data completionHandler:completionHandler];
//
//                                }
//                                else
//                                {
//                                    NSLog(@"签名失败");
//                                    completionHandler(nil);
//                                }
//
//                            }];
//
//                        }
//                        else
//                        {
//                            completionHandler(nil);
//                        }
//
//                    }
//
//                    else if (status == YVerifyPasswordState_Wrong)
//                    {
//
//                        [UIViewController showErrorWithStatus:YLOCALIZED_UserVC(@"transferopratevc_pwdiswrong")];
//                        completionHandler(nil);
//
//                    }
//                    else if (status == YVerifyPasswordState_Cancle)//等待支付
//                    {
//                        //                                NSString * trans = [self waitForPayment] ;
//                        completionHandler(nil);
//                    }
//
//                }];
//
//            }
//
//        }
//
//    };
//
//}

#pragma mark - VNS push到主网
- (void)requerstVNSData:(NSString*)result_bytestring completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
   
    
    NSDictionary * dic =  @{@"id":@"1",@"jsonrpc":@"2.0",@"method":@"vns_sendRawTransaction",@"params":@[result_bytestring]};
    WEAK(self)
    [RequestMethod requestNewAction:YRequest_POST didParam:dic didUrl:VNSChainRequestURL didSuccess:^(id response) {
        
        STRONG(weakObject)
        
        if (response) {
            
            if ([[response allKeys] containsObject:@"error"]) {
                
                NSString  * errDic = [[response objectForKey:@"error"] objectForKey:@"message"];
                
                [UIViewController showErrorWithStatus:errDic];
                
                NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
                [infoDic setObject:@400 forKey:@"status" ];
                [infoDic setObject:@"兑换异常" forKey:@"msg" ];
                NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
                [dataDic setObject:[NSString stringWithFormat:@"%f",strongObject.minersFee] forKey:@"minersFee"];
                [dataDic setObject:strongObject.fromAddress forKey:@"fromAddress"];
                [dataDic  setObject:strongObject.vnsAdrs forKey:@"vnsAddress"];
                [dataDic setObject:strongObject.htmlModel.data.info.symbols forKey:@"symbols"];
                [dataDic setObject:[NSString  stringWithFormat:@"%ld",(long)strongObject.htmlModel.data.chainType] forKey:@"chainType"];
                [infoDic setObject:dataDic forKey:@"data"];
                NSString * trans = [infoDic mj_JSONString] ;
                
                completionHandler(trans);
                
            }
            else if ([[response allKeys] containsObject:@"result"])
            {
                
                NSString * result = response[@"result"];
                
                //返回签名结果
                NSMutableDictionary * infoDic = [NSMutableDictionary dictionary] ;
                [infoDic setObject:@200 forKey:@"status" ];
                [infoDic setObject:@"交易成功" forKey:@"msg" ];
                NSMutableDictionary * dataDic = [NSMutableDictionary dictionary] ;
                [dataDic setObject:[NSString stringWithFormat:@"%f",strongObject.minersFee] forKey:@"minersFee"];
                [dataDic setObject:strongObject.fromAddress forKey:@"fromAddress"];
                [dataDic setObject:result forKey:@"trxid"];
                [dataDic  setObject:strongObject.vnsAdrs forKey:@"vnsAddress"];
                [dataDic setObject:strongObject.htmlModel.data.info.symbols forKey:@"symbols"];
                [dataDic setObject:[NSString  stringWithFormat:@"%ld",(long)strongObject.htmlModel.data.chainType] forKey:@"chainType"];
                [infoDic setObject:dataDic forKey:@"data"];
                NSString * trans = [infoDic mj_JSONString] ;
                
                completionHandler(trans);
                
            }
        }
        
    } didFailed:^(id error) {
        
        completionHandler(nil);
        [UIViewController showErrorWithStatus: YLOCALIZED_UserVC(@"transferopratevc_transferfailere")];
        
    }];
}


#pragma mark - 获取gas price
-(void)requestVNSAddresssInfo:(NSString*)address contract:(NSString*)contract complationBack:(void(^)(void))complationBack {
     
    __block double  gasD = pow(10, 9);
    //查询gas price nonce
    WEAK(self)
    [YChainBussiness requestVNSAddresssInfo:address to:nil contract:nil data:nil complationBack:^(id  _Nonnull data, NSInteger code) {
        
        if (code == 200) {
                  
            for (ETHTransferParticularsModel * mdoel in data) {
                //
                if ([mdoel.name isEqualToString:@"gasPrice"]) {
                    
                    weakObject.gasprice = [YCommonMethods getNumberFromHex:mdoel.data.result];
                    weakObject.gasRes = weakObject.gasprice.doubleValue / gasD;
                }
                else if ([mdoel.name isEqualToString:@"estimateGas"] || [mdoel.name isEqualToString:@"tokenEstimateGas"] ){
                    
                    weakObject.estimateGas = [YCommonMethods getNumberFromHex:mdoel.data.result] ;
                    weakObject.estimateGas = @"8000000";
                }
                else if ([mdoel.name isEqualToString:@"transaction"]){
                    
                    weakObject.nonce = [YCommonMethods getNumberFromHex:mdoel.data.result] ;
                }
                else if ([mdoel.name isEqualToString:@"version"]){
                    
                    weakObject.version = @"2018" ;
                }else if ([mdoel.name isEqualToString:@"Balance"]){
                    
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


@end
