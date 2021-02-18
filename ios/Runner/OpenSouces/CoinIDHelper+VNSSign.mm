//
//  CoinIDHelper+VNSSign.m
//  CoinID
//
//  Created by MWTECH on 2019/4/16.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "CoinIDHelper+VNSSign.h"
#import "CoinIDTool.h"
#import "CoinIDLIBInterface.h"
#import "WalletObject.h"
#import "YCommonMethods.h"
@implementation CoinIDHelper (VNSSign)

+(id)importVNSWallet:(ImportObject * )object {

    int leadType = object.mLeadType ;
    NSString * content = object.content ;
    int index = object.index ;
    NSString * PIN = object.pin ;
    WalletObject * wallet = [[WalletObject alloc] init];
    u8 * prvKeyAndPubKey ;
    if (leadType == MLeadWalletType_Memo) {
        
        NSData * memoData = [CoinIDTool convertDataWithMasterStrings:content];
        CoinID_SetMaster((unsigned char *)[memoData bytes], memoData.length);
        CoinID_DeriveKeyRoot(0x13c);
        CoinID_DeriveKeyAccount(0);
        prvKeyAndPubKey  = CoinID_DeriveKey(0);
    }
    else if (leadType == MLeadWalletType_PrvKey){
       
        if (![CoinIDTool isHexETHPrvKey:content]) {
            return wallet ;
        }
        
        u8 * priChar = [CoinIDTool hexToBytes:content];
        prvKeyAndPubKey  = CoinID_ImportETHPrvKey(priChar) ;
    }
    else if (leadType == MLeadWalletType_KeyStore){
        
        u8 * passChar = (u8*)[PIN UTF8String];
        u8 * contentChar = (u8*)[content UTF8String];
        u8 * outlen = (u8*)malloc(2) ;
        prvKeyAndPubKey  = CoinID_importKeyStore(contentChar, passChar , PIN.length, outlen);
        int tranLength = (outlen[0]<<8)|(outlen[1]) ;
        if (tranLength == 0 ) {
            return wallet;
        }
    }
    else{
       
        [CoinIDTool CoinID_SetMasterStandard:content];
        prvKeyAndPubKey = [CoinIDTool CoinID_deriveKeyByPath:@"44'/316'/0'/0/0"];
    }
    
    if (prvKeyAndPubKey == NULL){
        return wallet;
    }
    u8 * priKey = (u8*)malloc(32);
    memcpy(priKey, prvKeyAndPubKey, 32);
    u8 * publickey = (u8*)malloc(65);
    memcpy(publickey, prvKeyAndPubKey + 33, 64);
    u8 * exportPubkey  = CoinID_ExportETHPubKey(publickey);
    NSString *  pubString = [CoinIDTool formtterWithChar:exportPubkey];
    pubString = [CoinIDTool CoinID_cvtAddrByEIP55:pubString];
    pubString = [@"0x" stringByAppendingString:pubString];
    NSString *  prvString =  [CoinIDTool beginHexString:32 data:priKey];
    wallet.coinType = MCoinType_VNS;
    wallet.address = pubString;
    wallet.prvKey = prvString ;
    wallet.pubKey = [CoinIDTool beginHexString:64 data:publickey] ;
    return wallet;
}




+ (NSString*)vnsHotSignTransWithNonce:(NSString*)nonce
                             gasPrice:(NSString*)gasPrice
                             gasLimit:(NSString*)gasLimit
                                   to:(NSString*)to
                                value:(NSString*)value
                                 data:(NSString*)data
                              chainID:(NSString*)chainID
                          VNSSignType:(VNSSignType)VNSSignType
                             contract:(NSString*)contract
                              decimal:(NSInteger)decimal
                               prvStr:(NSString*)prvStr
                               params:(id)params
                     helperComplation:(HelperComplation)helperComplation {
    
    if (decimal == 0 ) {
        decimal = 18 ;
    }
    
    u8 * p_nonce = (u8*)[nonce UTF8String];
    int nonceLen = (int)strlen((char*)p_nonce);
    
    u8 * p_gasPrice = (u8*)[gasPrice UTF8String];
    int gasPriceLen = (int)strlen((char*)p_gasPrice);
    
    u8 * p_gasLimit = (u8*)[gasLimit UTF8String];
    int gasLimitLen = (int)strlen((char*)p_gasLimit);
    
    u8 * p_to = (u8*)[to UTF8String];
    
    NSDecimalNumber * valueNumber = [[NSDecimalNumber alloc] initWithString:value];
    NSDecimalNumber * realMoney = [valueNumber decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithString:@"1000000000000000000"]];
    u8 * p_value = (u8*)[realMoney.stringValue UTF8String];
    int valueLen = (int)strlen((char*)p_value);
    
    NSData * memoData = [data dataUsingEncoding:NSUTF8StringEncoding] ;
    u8 * p_data = (u8*)[memoData bytes ];
    NSInteger dataLen = memoData.length ;
    
    u8 * p_chainID = (u8*)[chainID UTF8String];
    int chainIDLen = (int)strlen((char*)p_chainID);
    
    u8 * prvkey  = [CoinIDTool hexToBytes:prvStr] ;
    u8 * result_byte;
    if (VNSSignType == VNSSignType_TOKEN) {
        
        p_to = (u8*)[contract UTF8String];
        
        NSData * dataList = [CoinIDHelper convertWithETHDataList:VNSSignType_TOKEN coinType:MCoinType_VNS to:to value:value decimal:decimal realMoney:&realMoney params:nil];
        
        result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, 0, 0, (u8*)[dataList bytes], dataList.length, p_chainID, chainIDLen, prvkey);
    }
    else if(VNSSignType == VNSSignType_VNS){
        
        result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, p_value, valueLen, p_data, dataLen, p_chainID, chainIDLen, prvkey);
    }
    else if (VNSSignType == VNSSignType_CrossChainGPS){
        
        gasLimit = @"80000" ;
        p_gasLimit = (u8*)[gasLimit UTF8String];
        p_to = (u8*)[contract UTF8String];
        
        NSString *memo = @"";
        NSString *token = params[@"token"];
        NSString * tokenid  = [YCommonMethods convertDataToHexStr:[token dataUsingEncoding:1]];
        NSDictionary * params = @{@"note":memo,@"tokenid":tokenid};
    NSData * dataList = [CoinIDHelper convertWithETHDataList:VNSSignType_CrossChainGPS coinType:MCoinType_VNS to:to value:value decimal:decimal realMoney:&realMoney params:params];
    result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, 0, 0, (u8*)[dataList bytes], dataList.length, p_chainID, chainIDLen, prvkey);
    
}
    else if (VNSSignType == VNSSignType_CrossChainGPSAuthorization) {
        gasLimit = @"80000" ;
        p_gasLimit = (u8*)[gasLimit UTF8String];
        p_to = (u8*)[contract UTF8String];
        
        NSData * dataList = [CoinIDHelper convertWithETHDataList:VNSSignType coinType:MCoinType_VNS to:to value:value decimal:decimal realMoney:&realMoney params:nil];
        
        result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, 0, 0, (u8*)[dataList bytes], dataList.length, p_chainID, chainIDLen, prvkey);
        
    }
    else if (VNSSignType == VNSSignType_BANCORBUY || VNSSignType == VNSSignType_BANCORSELL){
       
        gasLimit = @"8000000" ;
        p_gasLimit = (u8*)[gasLimit UTF8String];
        gasLimitLen = (int)strlen((char*)p_gasLimit);
        
        NSString * bancorConverter = params[@"bancorConverter"] ;
        NSString * vnserToken = params[@"vnserToken"] ;
        NSString * smartToken = params[@"smartToken"] ;
        BOOL istokenConvert = [params[@"istokenConvert"] boolValue];
        
        contract = bancorConverter ;
        
        if (bancorConverter.length <= 0 || smartToken.length <= 0 ||  vnserToken.length <= 0) {
            if (helperComplation) {
                helperComplation(nil,NO);
            }
            return nil ;
        }
        
        p_to = (u8*)[bancorConverter UTF8String];
        
        NSDictionary * params = @{@"vnserToken":vnserToken,@"smartToken":smartToken};
        
        NSData * dataList = [CoinIDHelper convertWithETHDataList:VNSSignType coinType:MCoinType_VNS to:to value:value decimal:decimal realMoney:&realMoney params:params];
        
        //        如果是购买，就是vnserToken，SmartToken，SmartToken，如果是卖出，就是SmartToken，SmartToken，VnserToken
        if (!istokenConvert){
            
            result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, p_value, valueLen, (u8*)[dataList bytes], dataList.length, p_chainID, chainIDLen, prvkey);
            
        }else{
            
            result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, 0, 0, (u8*)[dataList bytes], dataList.length, p_chainID, chainIDLen, prvkey);
        }
        
}
    else if (VNSSignType == VNSSignType_NewMultisign){
           
        
        p_to = (u8*)[@"0000000000000000000000000000000000000000" UTF8String];
        to = @"0000000000000000000000000000000000000000"  ;
        NSData * dataList = [CoinIDHelper convertWithETHDataList:VNSSignType coinType:MCoinType_VNS to:to value:value decimal:decimal realMoney:&realMoney params:params];
        result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, 0, 0, (u8*)[dataList bytes], dataList.length, p_chainID, chainIDLen, prvkey);
            
    }
    else if (VNSSignType == VNSSignType_JoinOwner){
        
        
        NSData * dataList = [CoinIDHelper convertWithETHDataList:VNSSignType coinType:MCoinType_VNS to:to value:value decimal:decimal realMoney:&realMoney params:params];
        result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, 0, 0, (u8*)[dataList bytes], dataList.length, p_chainID, chainIDLen, prvkey);
    }
    else if (VNSSignType == VNSSignType_MTokenSign || VNSSignType == VNSSignType_MCoinSign || VNSSignType == VNSSignType_MConfirmTrans){
        
        
        NSString * newTo = params[@"to"] ;
        p_to = (u8*)[newTo UTF8String];
        NSMutableDictionary * newParams = [NSMutableDictionary dictionaryWithDictionary:params];
        newParams[@"contract"] = contract ; //代币合约
        NSData * dataList = [CoinIDHelper convertWithETHDataList:VNSSignType coinType:MCoinType_VNS to:to value:value decimal:decimal realMoney:&realMoney params:newParams];
        result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, 0, 0, (u8*)[dataList bytes], dataList.length, p_chainID, chainIDLen, prvkey);
    }
    else {
        //vdns
        gasLimit = @"3000000" ;
        p_gasLimit = (u8*)[gasLimit UTF8String];
        gasLimitLen = (int)strlen((char*)p_gasLimit);
        
        p_to = (u8*)[contract UTF8String];
        to = contract ;
        
        NSData * dataList = [CoinIDHelper convertWithETHDataList:VNSSignType coinType:MCoinType_VNS to:to value:value decimal:decimal realMoney:&realMoney params:params];
        
        result_byte =  CoinID_sigtEthTransaction(p_nonce, nonceLen, p_gasPrice, gasPriceLen, p_gasLimit, gasLimitLen, p_to, p_value, valueLen, (u8*)[dataList bytes], dataList.length, p_chainID, chainIDLen, prvkey);
    }
    NSString * result_bytestring = [CoinIDTool formtterWithChar:result_byte];
    
    bool isContract = VNSSignType == VNSSignType_VNS ? NO : YES ;
    bool isValid = YES ;
   
    if (VNSSignType == VNSSignType_CrossChainGPS ) {
        
//        NSString *token = params[@"token"];
//        isValid = [CoinIDHelper CoinID_checkCrossChainpushValid:@"VNS" pushStr:result_bytestring contraAddr:contract chainName:@"GPS006" tokenid:token account:to amout:value decimal:decimal unit:token isContract:isContract];
    }
    if(
       VNSSignType == VNSSignType_VNS || VNSSignType == VNSSignType_TOKEN ||
       VNSSignType == VNSSignType_BANCORBUY || VNSSignType == VNSSignType_BANCORSELL){
        
        isValid = [CoinIDHelper CoinID_checkETHpushValid:result_bytestring to:to value:value decimal:decimal isContract:isContract contraAddr:contract];//验证
    }
    
    
    if (!isValid) {
        if (helperComplation) {
            helperComplation(nil,NO);
        }
        return nil;
    }
    
    result_bytestring = [@"0x" stringByAppendingString:result_bytestring];
    
    if (helperComplation) {
        helperComplation(result_bytestring,YES);
    }
    return result_bytestring ;
    
}

@end
