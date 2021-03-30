//
//  CoinIDHelper+ETHSign.m
//  CoinID
//
//  Created by MWTECH on 2019/4/15.
//  Copyright © 2019 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "CoinIDHelper+ETHSign.h"
#import "CoinIDTool.h"
#import "CoinIDLIBInterface.h"
#import "WalletObject.h"
@implementation CoinIDHelper (ETHSign)


+(id)importETHWallet:(ImportObject * )object {
    
    int leadType = object.mLeadType ;
    NSString * content = object.content ;
    int index = object.index ;
    NSString * PIN = object.pin ;
    WalletObject * wallet = [[WalletObject alloc] init];
    u8 * prvKeyAndPubKey ;
    if (leadType == MLeadWalletType_Memo) {
        NSData * memoData = [CoinIDTool convertDataWithMasterStrings:content];
        CoinID_SetMaster((unsigned char *)[memoData bytes], memoData.length);
        bool success = CoinID_DeriveETHKeyRoot();
        if (!success) {
            return wallet;
        }
        CoinID_DeriveETHKeyAccount(index);
        prvKeyAndPubKey  = CoinID_DeriveETHKey(index);
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
        prvKeyAndPubKey = [CoinIDTool CoinID_deriveKeyByPath:@"44'/60'/0'/0/0"];
    }
    if (prvKeyAndPubKey == NULL) {
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
    wallet.coinType = MCoinType_ETH;
    wallet.address = pubString;
    wallet.prvKey = prvString ;
    wallet.pubKey = [CoinIDTool beginHexString:64 data:publickey] ;
    return wallet;
}

+(id)importBSCWallet:(ImportObject * )object{
    
    int leadType = object.mLeadType ;
    NSString * content = object.content ;
    int index = object.index ;
    NSString * PIN = object.pin ;
    WalletObject * wallet = [[WalletObject alloc] init];
    u8 * prvKeyAndPubKey ;
    if (leadType == MLeadWalletType_Memo) {
        NSData * memoData = [CoinIDTool convertDataWithMasterStrings:content];
        CoinID_SetMaster((unsigned char *)[memoData bytes], memoData.length);
        bool success = CoinID_DeriveETHKeyRoot();
        if (!success) {
            return wallet;
        }
        CoinID_DeriveETHKeyAccount(index);
        prvKeyAndPubKey  = CoinID_DeriveETHKey(index);
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
        prvKeyAndPubKey = [CoinIDTool CoinID_deriveKeyByPath:@"44'/714'/0'/0/0"];
    }
    if (prvKeyAndPubKey == NULL) {
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
    wallet.coinType = MCoinType_BSC;
    wallet.address = pubString;
    wallet.prvKey = prvString ;
    wallet.pubKey = [CoinIDTool beginHexString:64 data:publickey] ;
    return wallet;
    
}

@end
