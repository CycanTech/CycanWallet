//
//  CoinIDHelper+BTCSign.m
//  CoinID
//
//  Created by MWTECH on 2019/4/15.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "CoinIDHelper+BTCSign.h"
#import "CoinIDTool.h"
#import "CoinIDLIBInterface.h"
#import "WalletObject.h"

@implementation CoinIDHelper (BTCSign)


+(id)importBTCWallet:(ImportObject * )object {

    int leadType = object.mLeadType ;
    NSString * content = object.content ;
    int index = object.index ;
    NSString * PIN = object.pin ;
    WalletObject * wallet = [[WalletObject alloc] init];
    int segwit = 0 ;
    u8 * prvKeyAndPubKey ;
    if (leadType == MLeadWalletType_Memo) {
        
        NSData * memoData = [CoinIDTool convertDataWithMasterStrings:content];
        CoinID_SetMaster((unsigned char *)[memoData bytes], memoData.length);
        bool success = CoinID_DeriveBTCKeyRoot();
        if (!success) {
            return wallet;
        }
        CoinID_DeriveBTCKeyAccount(index);
        prvKeyAndPubKey  = CoinID_DeriveBTCKey(index);
    }
    else if (leadType == MLeadWalletType_PrvKey){
        
        NSData * data = [content dataUsingEncoding:NSASCIIStringEncoding];
        u8 * priChar =  (u8*)[data bytes];
        prvKeyAndPubKey  = CoinID_ImportBTCPrvKeyByWIF(priChar, data.length) ;
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
    }else{
       
        [CoinIDTool CoinID_SetMasterStandard:content];
        prvKeyAndPubKey = [CoinIDTool CoinID_deriveKeyByPath:@"44'/0'/0'/0/0"];
    }
    
    if (prvKeyAndPubKey == NULL){
        return wallet;
    }
    u8 * priKey = (u8*)malloc(32);
    memcpy(priKey, prvKeyAndPubKey, 32);
    
    u8 * publickey = (u8*)malloc(65);
    memcpy(publickey, prvKeyAndPubKey + 32, 65);
    
    //前缀，主网为 0，测试网为 111
    u8 * exportPubkey ;
    if (segwit == 0) {
        exportPubkey  = CoinID_genBTCAddress(0, publickey, 33, 0);
    }else {
        exportPubkey  = CoinID_genBTCAddress(5, publickey, 33, 3);
    }
    u8 * exportPrikey = CoinID_ExportBTCPrvKeyByWIF(priKey);
    NSString *  pubString = [CoinIDTool formtterWithChar:exportPubkey];
    NSString *  prvString =  [CoinIDTool formtterWithChar:exportPrikey];
    wallet.coinType = MCoinType_BTC;
    wallet.address = pubString;
    wallet.prvKey = prvString ;
    wallet.pubKey = [CoinIDTool beginHexString:65 data:publickey] ;
    return wallet;
}




@end
