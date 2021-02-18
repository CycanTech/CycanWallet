//
//  CoinIDHelper+DotSign.m
//  Runner
//
//  Created by MWT on 2021/1/26.
//

#import "CoinIDHelper+DotSign.h"
#import "CoinIDTool.h"
#import "CoinIDLIBInterface.h"
#import "WalletObject.h"
#import "YCommonMethods.h"
@implementation CoinIDHelper (DotSign)

+(id)importDOTWallet:(ImportObject * )object {
    
    int leadType = object.mLeadType ;
    NSString * content = object.content ;
    int index = object.index ;
    NSString * PIN = object.pin ;
    WalletObject * wallet = [[WalletObject alloc] init];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string prvKeyStrs = "";
    string pubKeyStrs = "";
    if (leadType == MLeadWalletType_StandardMemo ||leadType == MLeadWalletType_Memo) {
        NSArray * contentArr = [content componentsSeparatedByString:@" "];
        u16 * memoIndexBuf = [CoinIDHelper fetchMemoIndex:content];
        if (memoIndexBuf == NULL) {
            return wallet;
        }
        string prvPubKey = CoinID_genPolkaDotKeyPairByPath(memoIndexBuf, (int)contentArr.count, "");
        if(prvPubKey.length() != 128 + 64){
            return wallet;
        }
        prvKeyStrs = prvPubKey.substr(0,128);
        pubKeyStrs = prvPubKey.substr(128,64);
        free(memoIndexBuf);
    }
    else if(leadType == MLeadWalletType_PrvKey){
        
        prvKeyStrs = [content UTF8String];
        pubKeyStrs = CoinID_getPolkaPubByPriv(prvKeyStrs);
    }else {
        
        string password = [PIN UTF8String];
        string value = [content UTF8String];
        string prvPubKey = CoinID_polkadot_ipt_keystore(password, value);
        if(prvPubKey.length() != 128 + 64){
            return wallet;
        }
        prvKeyStrs = prvPubKey.substr(0,128);
        pubKeyStrs = prvPubKey.substr(128,64);
    }
    if(prvKeyStrs.length() == 0){
        return wallet;
    }
    string address = CoinID_getPolkaDotAddress(0, pubKeyStrs);
    wallet.coinType = MCoinType_DOT;
    wallet.address = [NSString stringWithCString:address.c_str() encoding:4];
    wallet.prvKey = [NSString stringWithCString:prvKeyStrs.c_str() encoding:4];
    wallet.pubKey = [NSString stringWithCString:pubKeyStrs.c_str() encoding:4];
    return wallet;
}
@end
