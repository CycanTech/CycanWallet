//
//  CoinIDHelper.m
//  CoinID
//
//  Created by MWTECH on 2018/10/23.
//  Copyright © 2018年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "CoinIDHelper.h"
#import "CoinIDLIBInterface.h"
#import "CoinIDHelper+BTCSign.h"
#import "CoinIDHelper+BTMSign.h"
#import "CoinIDHelper+ETHSign.h"
#import "CoinIDHelper+LTCSign.h"
#import "CoinIDHelper+VNSSign.h"
#import "CoinIDHelper+EOSSign.h"
#import "CoinIDHelper+USDTSign.h"
#import "CoinIDHelper+DotSign.h"
#import "CoinIDTool.h"
#import "WalletObject.h"
#import "YCommonMethods.h"

@implementation CoinIDHelper


+(NSArray<NSString*>*)createWalletMemo:(MMemoCount )memoCount
                   memoType:(MMemoType )memoType{
    
    NSArray * localRemberWorld = [CoinIDTool fetchLocalRemberWorld:memoType];
    //获得索引数据
    NSArray * indexArrs = [CoinIDTool fetchRemberIndex:memoCount];
    NSMutableArray * memos = [NSMutableArray array ] ;
    for (int i = 0 ; i < indexArrs.count; i ++ ) {
        int tempdaa = [indexArrs[i] intValue];
        NSString * memo = localRemberWorld[tempdaa];
        [memos addObject:memo];
    }
    NSLog(@"生成的助记词 %@",[memos componentsJoinedByString:@","]);
    return memos ;
}

+(unsigned short*)fetchMemoIndex:(NSString*)memos{
    
    __block BOOL isok = NO ;
    BOOL isChar = NO;
    NSString * path = @"";
    memos = [memos stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSArray * contentArr = [memos componentsSeparatedByString:@" "];
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    for (int  i = 0 ; i < contentArr.count; i ++) {
        
        NSString * smallKey = [contentArr objectAtIndex:i] ;
        if (smallKey.length == 0) {
            continue ;
        }
        [arr addObject:smallKey];
    }
    if (arr.count == 12 || arr.count == 18 || arr.count == 24) {
        
        //判断词库
        isok = YES ;
        NSString * newRemberKey  = [arr firstObject];
        isChar = [CoinIDTool isChar:newRemberKey];
        if (isChar) {
            path = [[NSBundle mainBundle] pathForResource:@"english" ofType:@"txt"];
        }else{
            path = [[NSBundle mainBundle] pathForResource:@"chinese_simplified" ofType:@"txt"];
        }
        NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray * arrData = [content componentsSeparatedByString:@"\n"];
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            NSString * objstring = obj ;
            if (![arrData containsObject:objstring]) {
                isok = NO;
                *stop = NO;
            }
        }];
        //获取索引
        if (isok) {
            u16 * memoIndexBuf = (u16*)malloc(24);
            for (int i = 0 ; i < arr.count; i ++ ) {
                NSString * objstring = arr[i] ;
                NSInteger index = [arrData indexOfObject:objstring];
                memoIndexBuf[i] = index ;
            }
            return memoIndexBuf;
        }
    }
    return NULL;
}

+(BOOL)checkMemoValid:(NSString*)memos {
    
    __block BOOL isok = NO ;
    BOOL isChar = NO;
    NSString * path = @"";
    memos = [memos stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSArray * contentArr = [memos componentsSeparatedByString:@" "];
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    for (int  i = 0 ; i < contentArr.count; i ++) {
        
        NSString * smallKey = [contentArr objectAtIndex:i] ;
        if (smallKey.length == 0) {
            continue ;
        }
        [arr addObject:smallKey];
    }
    if (arr.count == 12 || arr.count == 18 || arr.count == 24) {
        
        //判断词库
        isok = YES ;
        NSString * newRemberKey  = [arr firstObject];
        isChar = [CoinIDTool isChar:newRemberKey];
        if (isChar) {
            path = [[NSBundle mainBundle] pathForResource:@"english" ofType:@"txt"];
        }else{
            path = [[NSBundle mainBundle] pathForResource:@"chinese_simplified" ofType:@"txt"];
        }
        NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSArray * arrData = [content componentsSeparatedByString:@"\n"];
        NSMutableString * string = [NSMutableString string];
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            NSString * objstring = obj ;
            if (![arrData containsObject:objstring]) {
                isok = NO;
                *stop = NO;
            }
        }];
        if (isok) {
            u16 memoIndexBuf[24] = {};
            //获取索引
            for (int i = 0 ; i < arr.count; i ++ ) {
                NSString * objstring = arr[i] ;
                NSInteger index = [arrData indexOfObject:objstring];
                memoIndexBuf[i] = index ;
            }
            u8 result = CoinID_checkMemoValid(memoIndexBuf, arr.count);
            if ((int)result != 1) {
                isok = NO ;
            }
        }
    }
    NSLog(@"助记词校验结果 %@",isok == YES ? @"通过":@"失败");
    return isok ;
}

+(NSArray *)importWalletFrom:(ImportObject *) object {

    NSMutableArray * datas = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * arrDatas = [NSMutableArray arrayWithCapacity:0];
    int coinType = object.mCoinType ;
    int leadType = object.mLeadType ;
    NSString * content = object.content ;
    int index = object.index ;
    NSString * PIN = object.pin ;
    NSLog(@"content %@ PIN %@ coinType %d leadType %d",content,PIN,coinType,leadType);
    if (coinType == MCoinType_All||coinType == MCoinType_BTC) {
        
        [datas addObject:[self importBTCWallet:object]];
    }
    if (coinType == MCoinType_All||coinType == MCoinType_ETH) {
        
        [datas addObject:[self importETHWallet:object]];
    }
    if (coinType == MCoinType_All||coinType == MCoinType_DOT) {
        
        [datas addObject:[self importDOTWallet:object]];
    }
    if (coinType == MCoinType_All||coinType == MCoinType_BSC) {
        
        [datas addObject: [self importBSCWallet:object]];
    }
    NSString * masterPubKey = @"";
    if (leadType == MLeadWalletType_Memo || leadType == MLeadWalletType_StandardMemo) {
        masterPubKey=  [CoinIDTool CoinID_getMasterPubKey];
    }
    for (WalletObject * wallet in datas) {
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        NSString * prvKey = wallet.prvKey;
        NSString * subPrvKey = wallet.subPrvKey;
        prvKey = [CoinIDTool CoinID_EncByAES128CBC:prvKey pin:PIN];
        subPrvKey = [CoinIDTool CoinID_EncByAES128CBC:subPrvKey pin:PIN];
        dic[@"address"] = wallet.address;
        dic[@"prvKey"] = prvKey ;
        dic[@"pubKey"] = wallet.pubKey;
        dic[@"coinType"] = @(wallet.coinType);
        dic[@"subPrvKey"] = subPrvKey;
        dic[@"subPubKey"] = wallet.subPubKey ? wallet.subPubKey :@"";
        dic[@"masterPubKey"] = masterPubKey;
        [arrDatas addObject:dic];
    }
    return arrDatas ;
}

+(NSString*)fetchRandomString : (NSInteger) numbers {
    
    NSMutableString * randomNub = [NSMutableString string];
    for (int i = 0; i < numbers; i++) {
        
        unsigned char   a = (arc4random() % 255) + [[NSDate date] timeIntervalSince1970];
        [randomNub appendFormat:@"%02x",a];
    }
    if (randomNub.length > numbers * 2 ) {
        randomNub  = [randomNub substringToIndex:numbers * 2].mutableCopy;
    }
    return randomNub ;
}

+(NSString*)fetch_ExportKeyStore:(NSString*)pwd priKey:(NSString*)priKey coinType:(int)coinType {

    NSString * ksJson = @"";
    if(coinType == MCoinType_DOT){
        
        string password = [pwd UTF8String];
        string prv = [priKey UTF8String];
        string pub = CoinID_getPolkaPubByPriv(prv);
        string json  = CoinID_polkadot_ept_keystore(password, prv, 42, pub);
        ksJson = [NSString stringWithCString:json.c_str() encoding:4];
    }else{
        
        u8 * password =(u8*) [pwd UTF8String];
        u8 * salt  = (u8*)[[CoinIDHelper fetchRandomString:32] UTF8String] ;
        u8 * iv  = (u8*)[[CoinIDHelper fetchRandomString:16] UTF8String] ;
        u8 * uuid  = (u8*)[[CoinIDHelper fetchRandomString:16] UTF8String] ;
        u8 * privateKey ;
        if (coinType == MCoinType_BTC || coinType == MCoinType_LTC || coinType == MCoinType_USDT) {
            NSData * data = [priKey dataUsingEncoding:NSASCIIStringEncoding];
            u8 * priChar =  (u8*)[data bytes];
            u8 * prvKeyAndPubKey  = CoinID_ImportBTCPrvKeyByWIF(priChar, data.length) ;
            if (prvKeyAndPubKey == NULL) {
                return @"" ;
            }
            privateKey = (u8*)malloc(32);
            memcpy(privateKey, prvKeyAndPubKey, 32);
            
        }
        else if (coinType == MCoinType_EOS || coinType == MCoinType_GPS){
            
            NSData * data = [priKey dataUsingEncoding:NSASCIIStringEncoding];
            u8 * priChar =  (u8*)[data bytes];
            u8 * ownerbyte = CoinID_ImportEOSPrvKey(priChar, data.length);
            privateKey = (u8*)malloc(32);
            memcpy(privateKey, ownerbyte, 32);
        }
        else{
            
            privateKey = [CoinIDTool hexToBytes:priKey];
        }
        u8 * json =  CoinID_exportKeyStore(privateKey, 32 , 0 , password , pwd.length , salt, iv, uuid);
        int tranLen = (int)strlen((char*)json) ;
        ksJson = [[NSString alloc] initWithBytes:json length:tranLen encoding:1];
    }
    NSLog(@"keyStore %@",ksJson);
    return ksJson ;
}

+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

+  (NSString *)getHexByDecimal:(BigNumber *)tempStr{

    //10进制转换16进制（支持无穷大数）
//    tempStr = [BigNumber bigNumberWithDecimalString:@"1208925819614629174706175"]; ;
    
    BigNumber * cacheString = tempStr ;
    BigNumber * tempValue = [BigNumber bigNumberWithInteger:16] ;
    NSString * nLetterValue;
    NSString * str = @"";
    BigNumber * tempData = [BigNumber bigNumberWithInteger:0];
   
    for (int i = 0; i < cacheString.decimalString.length; i++) {
        tempData = [tempStr mod:tempValue];
        tempStr = [tempStr div:tempValue];
        switch (tempData.integerValue) {
            case 10:
                nLetterValue = @"A";
                break;
            case 11:
                nLetterValue = @"B";
                break;
            case 12:
                nLetterValue = @"C";
                break;
            case 13:
                nLetterValue = @"D";
                break;
            case 14:
                nLetterValue = @"E";
                break;
            case 15:
                nLetterValue = @"F";
                break;
            default:
                nLetterValue = tempData.decimalString ;
        }
        str = [nLetterValue stringByAppendingString:str];
        if ([tempStr isEqualTo:[BigNumber bigNumberWithInteger: 0]]) {
            break;
        }
    }
    
//    BigNumber * sumBig = [BigNumber constantZero];
//    NSDecimalNumber * deciOne = [NSDecimalNumber decimalNumberWithString:@"16"];
//    for (int i = 0 ; i < str.length; i ++ ) {
//
//        NSString * shortString = [str substringWithRange:NSMakeRange(str.length - i - 1, 1)];
//        if ([shortString isEqualToString:@"A"]) {
//            shortString = @"10";
//        }else if ([shortString isEqualToString:@"B"]){
//             shortString = @"11";
//        }else if ([shortString isEqualToString:@"C"]){
//             shortString = @"12";
//        }else if ([shortString isEqualToString:@"D"]){
//             shortString = @"13";
//        }else if ([shortString isEqualToString:@"E"]){
//             shortString = @"14";
//        }else if ([shortString isEqualToString:@"F"]){
//             shortString = @"15";
//        }
//        NSDecimalNumber * rasNumber  = [deciOne decimalNumberByRaisingToPower:i];
//        BigNumber * resultNumber = [[BigNumber bigNumberWithDecimalString:shortString] mul:[BigNumber bigNumberWithDecimalString:rasNumber.stringValue]];
//        sumBig = [sumBig add:resultNumber];
//    }
//    NSLog(@"sumbig %@",sumBig.decimalString);
    
    return str;
}

+ (NSMutableData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < str.length; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}

+ (u8*) hexToBytes:(NSString*)string {
    
    u8 * hexprikey = (u8 *)malloc((int)[string length] / 2 + 1);
    bzero(hexprikey, [string length] / 2 + 1);
    if (string.length  == 0 ) {
        return hexprikey;
    }
    for (int i = 0; i < [string length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [string substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        hexprikey[i / 2] = (char)anInt;
    }
    
    return hexprikey ;
}

+(NSData*)convertWithETHDataList:(VNSSignType)signType
                        coinType:(MCoinType)coinType
                              to:(NSString*)to
                           value:(NSString*)value
                         decimal:(NSInteger)decimal
                       realMoney:(NSDecimalNumber**)realMoney
                          params:(id)params {
    
    NSMutableData * dataList = [NSMutableData data];
    
    if (signType == VNSSignType_TOKEN) {
        
        u8  allChar[68];
        memset((void *)allChar,0,68);
        
        u8 function[] = {0xa9,0x05,0x9c,0xbb};
        u8 addressChar[32];
        memset((void *)addressChar,0,32);
        u8 moneyChar[32];
        memset((void *)moneyChar,0,32);
        
        u8 * newTo = [CoinIDTool hexToBytes:to] ;
        int offset = (int)(32 - to.length / 2 ) ;
        memcpy(addressChar + offset, newTo , to.length / 2);
        
        NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:value];
        NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:decimal];
        NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
        *realMoney = payMoney ;
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoney.stringValue];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset2 = (int)(32 - newValueData.length) ;
        memcpy(moneyChar + offset2, newValue , newValueData.length);//金额的拼接
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, addressChar, 32);
        memcpy(allChar + 36, moneyChar, 32);
        
        return [NSData dataWithBytes:allChar length:68];
    }
    else if (signType == VNSSignType_VNS){
        
        return nil ;
    }
    else if (signType == VNSSignType_BANCORBUY || signType == VNSSignType_BANCORSELL) {
        
        NSString * vnserToken = params[@"vnserToken"];
        NSString * smartToken = params[@"smartToken"];
        
        u8  allChar[228];
        memset((void *)allChar,0,228);
        u8 function[] = {0xf0,0x84,0x3b,0xa9};
        u8 sixValue[] = {0x60};
        u8 moneyChar[32];
        memset((void *)moneyChar,0,32);
        
        NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:value];
        NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:decimal];
        NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
        *realMoney = payMoney ;
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoney.stringValue];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset2 = (int)(32 - newValueData.length) ;
        memcpy(moneyChar + offset2, newValue , newValueData.length);
        
        u8 minreturn[] = {0x01};
        u8 threeVlaue[] = {0x03};
        u8 vnstokenAddress[32];
        memset((void *)vnstokenAddress,0,32);
        
        u8 smartokenAddress[32];
        memset((void *)smartokenAddress,0,32);
        
        u8 * etherToken = [CoinIDHelper hexToBytes:vnserToken] ;
        int offset = (int)(32 - vnserToken.length/2) ;
        memcpy(vnstokenAddress + offset, etherToken , vnserToken.length /2);
        
        u8 * smarttoken = [CoinIDHelper hexToBytes:smartToken] ;
        int offset3 = (int)(32 - smartToken.length/2) ;
        memcpy(smartokenAddress + offset3, smarttoken , smartToken.length/2);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4 + 31, sixValue, 1); //32  + 4
        memcpy(allChar + 36, moneyChar, 32);  // 36 + 32
        memcpy(allChar + 68 + 31 , minreturn, 1); //68 + 31  1
        memcpy(allChar + 68 + 32 + 31, threeVlaue, 1); // 68 + 32 + 31  1
        
        //如果是购买，就是vnserToken，SmartToken，SmartToken，如果是卖出，就是SmartToken，SmartToken，VnserToken
        if (signType == VNSSignType_BANCORBUY){
            memcpy(allChar + 68 + 32 + 32, vnstokenAddress, 32);
            memcpy(allChar + 68 + 32 + 32 + 32, smartokenAddress, 32);
            memcpy(allChar + 68 + 32 + 32 + 32 + 32 , smartokenAddress, 32);
        }else{
            memcpy(allChar + 68 + 32 + 32, smartokenAddress, 32);
            memcpy(allChar + 68 + 32 + 32 + 32, smartokenAddress, 32);
            memcpy(allChar + 68 + 32 + 32 + 32 + 32 , vnstokenAddress, 32);
        }
        
        return [NSData dataWithBytes:allChar length:228];
        
    }
    else if (signType == VNSSignType_CrossChainGPSAuthorization){
    u8  allChar[68];
    memset((void *)allChar,0,68);
    
    u8 function[] = {0x09,0x5e,0xa7,0xb3}; //方法
    u8 addressChar[32]; //合约地址
    memset((void *)addressChar,0,32);
    
    u8 moneyChar[32];  //金额
    memset((void *)moneyChar,0,32);
    
    
    NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:value];
    NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
    NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:decimal];
    NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
    *realMoney = payMoney ;
    BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoney.stringValue];
    NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
    hexMoney  = @"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
    NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
    u8 * newValue = (u8*)[newValueData bytes];
    int offset2 = (int)(32 - newValueData.length) ;
    
    NSString *addressToken = @"d27d1ebd08d8ec75970b348f62f75991446376a8";
    u8 * addresstoken = [CoinIDHelper hexToBytes:addressToken] ;
    int offset3 = (int)(32 - addressToken.length/2) ;
    memcpy(addressChar + offset3, addresstoken , addressToken.length/2);
    
    
    memcpy(moneyChar + offset2, newValue , newValueData.length);//拼接
    
    memcpy(allChar, function, 4);
    memcpy(allChar + 4, addressChar, 32);
    memcpy(allChar + 36, moneyChar, 32);
    
    return [NSData dataWithBytes:allChar length:68];
}
    else if (signType == VNSSignType_CrossChainGPS){
  
        u8  allChar[164];
        memset((void *)allChar,0,164);
        
        u8 function[] = {0xa5,0xf5,0x0f,0x50};
        
        u8 chainId[32];
        memset((void *)chainId,0,32);
        u8 addressChar[32];
        memset((void *)addressChar,0,32);
        u8 tokenid[32];
        memset((void *)tokenid,0,32);
        u8 valueu8[32];
        memset((void *)valueu8,0,32);
        u8 note[32];
        memset((void *)note,0,32);
        
        NSData * chainiddata = [@"GPS006" dataUsingEncoding:NSASCIIStringEncoding];//GPS001. 暂时固定
        //1:要存储的目标数据 2:要复制的数据源 3:要复制的字节数
        memcpy(chainId, [chainiddata bytes], chainiddata.length);
        
        NSData *addressToken = [to dataUsingEncoding:NSASCIIStringEncoding];//GPS链上的账户 临时的
        memcpy(addressChar, [addressToken bytes], addressToken.length);
        
        NSString * tokenstr = params[@"tokenid"];
        
        //        u8 tokenstrdta[32] = {0x42,0x4d,0x57};//tokenid
        u8* tokenstrdta = [CoinIDHelper hexToBytes:tokenstr];
        
        memcpy(tokenid, tokenstrdta, tokenstr.length/2);
        
        NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:value];//跨链的金额
        NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:decimal];
        NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
        *realMoney = payMoney ;
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoney.stringValue];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset2 = (int)(32 - newValueData.length) ;
        memcpy(valueu8 + offset2, newValue , newValueData.length);
        
        NSString * notestr = params[@"note"];//备注 memo
        NSData * notedata = [notestr dataUsingEncoding:NSASCIIStringEncoding];
        memcpy(note, [notedata bytes], notedata.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, chainId, 32);
        memcpy(allChar + 36, addressChar, 32);
        memcpy(allChar + 36 + 32 , tokenid, 32);
        memcpy(allChar + 36 + 32*2 , valueu8, 32);
        memcpy(allChar + 36 + 32*3, note, 32);
        
        return [NSData dataWithBytes:allChar length:164];
}
    else if (signType == VNSSignType_CrossChainAllowance){
        
        u8  allChar[68];
        memset((void *)allChar,0,68);
        
        u8 function[] = {0xdd,0x62,0xed,0x3e}; //方法
        u8 addressChar[32];
        memset((void *)addressChar,0,32);
        
        u8 contract[32];
        memset((void *)contract,0,32);
        
        u8 * addresstoken = [CoinIDHelper hexToBytes:to] ;
        int offset3 = (int)(32 - to.length/2) ;
        memcpy(addressChar + offset3, addresstoken , to.length/2);
        
        
        
        NSString *contractStr = @"d27d1ebd08d8ec75970b348f62f75991446376a8";
        u8 * contractU8 = [CoinIDHelper hexToBytes:contractStr] ;
        int offset2 = (int)(32 - contractStr.length/2) ;
        memcpy(contract + offset2, contractU8 , contractStr.length/2);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, addressChar, 32);
        memcpy(allChar + 36, contract, 32);
        return [NSData dataWithBytes:allChar length:68];
        
        
    }
    else if (signType == VNSSignType_Vdns_PayTopLevel){
        
        
        NSString * year = params[@"year"];
        NSString * vdns = params[@"vdns"];
        
        //vdns注册一级域名
        u8  allChar[132];
        memset((void *)allChar,0,132);
        u8 function[] = {0x55,0x51,0xa3,0xb8};
        memcpy(allChar, function, 4);
        allChar[35] = 0x40 ;
        
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:year];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset2 = (int)(68 - newValueData.length) ;
        memcpy(allChar + offset2, newValue , newValueData.length);
        
        u8 * vDomain = (u8*)[[vdns dataUsingEncoding:1] bytes] ;
        allChar[99] = vdns.length ;
        memcpy(allChar + 100, vDomain, vdns.length );
        
        NSData * data = [NSData dataWithBytes:allChar length:132];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        return data ;
    }
    else if (signType == VNSSignType_Vdns_Renew){
        
        NSString * year = params[@"year"];
        NSString * vdns = params[@"vdns"];
        
        //vdns续费
        u8  allChar[132];
        memset((void *)allChar,0,132);
        u8 function[] = {0x86,0x7f,0x32,0x47};
        memcpy(allChar, function, 4);
        allChar[35] = 0x40 ;
        
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:year];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset2 = (int)(68 - newValueData.length) ;
        memcpy(allChar + offset2, newValue , newValueData.length);
        
        u8 * vDomain = (u8*)[[vdns dataUsingEncoding:1] bytes] ;
        allChar[99] = vdns.length ;
        memcpy(allChar + 100, vDomain, vdns.length );
        
        NSData * data = [NSData dataWithBytes:allChar length:132];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        return data ;
    }
    else if (signType == VNSSignType_Vdns_PaySubLevel){
        
        NSString * vdns = params[@"vdns"];          //BTC.aaaaa.vns
        NSString * vadType = params[@"vadType"];    //btc
        NSString * addr = params[@"addr"];          //1CK6KHY6M
        NSArray * params = @[vdns,addr,vadType];
        
        NSInteger allNum = 0 ;
        for (int i = 0 ; i < params.count ; i ++ ) {
           
            NSString * obj = params[i];
            NSInteger dataNum = obj.length / 32 + ((obj.length % 32) > 1 ? 1 : 0 );
            allNum += 32 * dataNum ;
        }
        
        NSInteger allLen = params.count * 2 * 32 + allNum + 4 ;
        //vdns注册二级域名
        u8  allChar[allLen];
        memset((void *)allChar,0,allLen);
        u8 function[] = {0x89,0xfe,0xfd,0x96};
        memcpy(allChar, function, 4);
   
        NSInteger endPoint = params.count * 32 ;
        for (int i = 0 ; i < params.count ; i ++ ) {
            
            BigNumber * realLen  = [BigNumber bigNumberWithInteger:endPoint];
            NSString * hexLen  = [CoinIDHelper getHexByDecimal:realLen] ;
            NSData * newLen = [CoinIDHelper convertHexStrToData:hexLen] ;
            u8 * newValue = (u8*)[newLen bytes];
            int offset = (int)(32 * i + 36 - newLen.length) ;
            memcpy(allChar + offset , newValue, newLen.length);
                        
//            allChar[32 * i + 35 ] = endPoint ;
            
            NSString * obj = params[i];
            u8 * vData  = (u8*)[[obj dataUsingEncoding:1] bytes] ;
            NSInteger lenX = endPoint + 32 + 3 ;
            allChar[lenX] = obj.length ;
            
            NSInteger dataNum = obj.length / 32 + ((obj.length % 32) > 1 ? 1 : 0 );
            u8 * data = (u8*) malloc(dataNum * 32);
            memset((void *)data,0,dataNum* 32);
            memcpy(data, vData, obj.length);
            memcpy(allChar + lenX + 1, data, dataNum * 32 );
            endPoint += dataNum * 32 + 32 ;
        }
        
        NSData * data = [NSData dataWithBytes:allChar length:allLen];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        return data ;
    }
    else if (signType == VNSSignType_Vdns_SetController){
        
        NSString * address = params[@"address"];
        NSString * vdns = params[@"vdns"];
        
        //vdns更新持有者
        u8  allChar[132];
        memset((void *)allChar,0,132);
        u8 function[] = {0x87,0xb8,0x0b,0xa0};
        memcpy(allChar, function, 4);
        allChar[35] = 0x40 ;
        
        u8 * vAddress = (u8*)[CoinIDHelper hexToBytes:address];
        int offset2 = (int)(68 - address.length /2 ) ;
        memcpy(allChar + offset2, vAddress , address.length / 2 );
        
        u8 * vDomain = (u8*)[[vdns dataUsingEncoding:1] bytes] ;
        allChar[99] = vdns.length ;
        memcpy(allChar + 100, vDomain, vdns.length );
        
        NSData * data = [NSData dataWithBytes:allChar length:132];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        return data ;
    }
    else if(signType == VNSSignType_Vdns_DelSubLevel){
        
        NSString * vdns = params[@"vdns"];
        
        //vdns删除二级域名
        u8  allChar[100];
        memset((void *)allChar,0,100);
        u8 function[] = {0x98,0xbb,0x61,0x91};
        memcpy(allChar, function, 4);
        allChar[35] = 0x20 ;
        
        u8 * vDomain = (u8*)[[vdns dataUsingEncoding:1] bytes] ;
        allChar[67] = vdns.length ;
        memcpy(allChar + 68, vDomain, vdns.length );
        
        NSData * data = [NSData dataWithBytes:allChar length:100];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        return data ;
    }
    
    else if (signType == VNSSignType_Approve){
        
        
        NSString *addressToken = params[@"addressToken"];
        
        u8  allChar[68];
        memset((void *)allChar,0,68);
        
        u8 function[] = {0x09,0x5e,0xa7,0xb3}; //方法
        u8 addressChar[32]; //合约地址
        memset((void *)addressChar,0,32);
        
        u8 moneyChar[32];  //金额
        memset((void *)moneyChar,0,32);
        
        
        NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:value];
        NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:decimal];
        NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
        *realMoney = payMoney ;
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoney.stringValue];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        hexMoney  = @"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset2 = (int)(32 - newValueData.length) ;
        
        u8 * addresstoken = [CoinIDHelper hexToBytes:addressToken] ;
        int offset3 = (int)(32 - addressToken.length/2) ;
        memcpy(addressChar + offset3, addresstoken , addressToken.length/2);
        
        
        memcpy(moneyChar + offset2, newValue , newValueData.length);//拼接
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, addressChar, 32);
        memcpy(allChar + 36, moneyChar, 32);
        
        return [NSData dataWithBytes:allChar length:68];
    }
    else if (signType == VNSSignType_Allowance){
        
        NSString *contractStr = params[@"addressToken"];
        
        u8  allChar[68];
        memset((void *)allChar,0,68);
        
        u8 function[] = {0xdd,0x62,0xed,0x3e}; //方法
        u8 addressChar[32];
        memset((void *)addressChar,0,32);
        
        u8 contract[32];
        memset((void *)contract,0,32);
        
        u8 * addresstoken = [CoinIDHelper hexToBytes:to] ;
        int offset3 = (int)(32 - to.length/2) ;
        memcpy(addressChar + offset3, addresstoken , to.length/2);
        
        u8 * contractU8 = [CoinIDHelper hexToBytes:contractStr] ;
        int offset2 = (int)(32 - contractStr.length/2) ;
        memcpy(contract + offset2, contractU8 , contractStr.length/2);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, addressChar, 32);
        memcpy(allChar + 36, contract, 32);
        return [NSData dataWithBytes:allChar length:68];
    }
    else if (signType == VNSSignType_Vusd_create || signType == VNSSignType_Vusd_DepositVNS)//创建CDP
    {
        
        u8 function[] = {0x28,0xff,0xe6,0xc8};
        u8 allChar[36];
        memset((void *)allChar,0,36);  //重置成0
        memcpy(allChar, function, 4);
        
        NSString * address = params[@"address"];
        u8 *contract = [CoinIDHelper hexToBytes:address];
        int offset2 = (int)(36 - address.length /2 ) ;
        memcpy(allChar + offset2, contract , address.length / 2 );
        
        NSData * data = [NSData dataWithBytes:allChar length:36];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_CdpAssetManagemente || signType == VNSSignType_Vusd_RepayVUSD_Frobt || signType == VNSSignType_Vusd_GenerateVUSD_Segmentation_Yes || signType == VNSSignType_Vusd_DepositVNS_frobt || signType == VNSSignType_Vusd_RetrieveVNS)
    {
        
        u8 allChar[196];
        memset((void *)allChar,0,196);  //重置成0
        
        u8 function[] = {0x62,0x21,0x2f,0x22};
        
        u8 vdnsManage [32];
        memset((void *)vdnsManage,0,32);
        
        u8 addresss1 [32];
        memset((void *)addresss1,0,32);
        
        u8 addresss2 [32];
        memset((void *)addresss2,0,32);
        
        u8 addresss3 [32];
        memset((void *)addresss3,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        u8 toValue [32];
        memset((void *)toValue,0,32);
        
        //资产名称
        NSString * vdns = params[@"managemente"]; //vns
        NSData * uuidData = [vdns dataUsingEncoding:NSASCIIStringEncoding];
        memcpy(vdnsManage, [uuidData bytes] , uuidData.length);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss1+offset2, contractU, addressU.length/2);
        memcpy(addresss2+offset2, contractU, addressU.length/2);
        memcpy(addresss3+offset2, contractU, addressU.length/2);
        
        //vns的值
        NSString *fromVns = params[@"toVns"];
        NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:fromVns];
        NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:decimal];
        NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoney.stringValue];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;//10进制转换16进制（支持无穷大数）、
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset4 = (int)(32 - newValueData.length) ;
        memcpy(fromValue +offset4, newValue, newValueData.length);
        
        if (signType == VNSSignType_Vusd_RetrieveVNS) {
            
            NSString *new10 = [YCommonMethods getNumberFromHex:[CoinIDHelper reverseCode:fromValue]];
            BigNumber *big = [BigNumber bigNumberWithDecimalString:new10];
            BigNumber * bigT = [big add:[BigNumber constantOne]];
            NSString * bigStr  = [CoinIDHelper getHexByDecimal:bigT] ;
            NSData * newValueDataVusd = [CoinIDHelper convertHexStrToData:bigStr] ;
            u8 * newValueVusd = (u8*)[newValueDataVusd bytes];
            memcpy(fromValue, newValueVusd , newValueDataVusd.length);
            
        }
        
        //vusd的值
        NSString *toVusd = params[@"toVusd"];
        int  power = 18;
        NSDecimalNumber * transValueVusd = [NSDecimalNumber decimalNumberWithString:toVusd];
        NSDecimalNumber * decimalOneVusd = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumber * decimalRuleVusd  = [decimalOneVusd decimalNumberByMultiplyingByPowerOf10:power];
        NSDecimalNumber * payMoneyVusd = [transValueVusd decimalNumberByMultiplyingBy:decimalRuleVusd];
        BigNumber * realValueVusd  = [BigNumber bigNumberWithDecimalString:payMoneyVusd.stringValue];
        NSString * hexMoneyVusd  = [CoinIDHelper getHexByDecimal:realValueVusd] ;
        NSData * newValueDataVusd = [CoinIDHelper convertHexStrToData:hexMoneyVusd] ;
        u8 * newValueVusd = (u8*)[newValueDataVusd bytes];
        int offset5 = (int)(32 - newValueDataVusd.length) ;
        memcpy(toValue +offset5, newValueVusd, newValueDataVusd.length);
        
        if (signType == VNSSignType_Vusd_RepayVUSD_Frobt) {
            
            NSString *new10 = [YCommonMethods getNumberFromHex:[CoinIDHelper reverseCode:toValue]];
            BigNumber *big = [BigNumber bigNumberWithDecimalString:new10];
            BigNumber * bigT = [big add:[BigNumber constantOne]];
            NSString * bigStr  = [CoinIDHelper getHexByDecimal:bigT] ;
            NSData * newValueDataVusd = [CoinIDHelper convertHexStrToData:bigStr] ;
            u8 * newValueVusd = (u8*)[newValueDataVusd bytes];
            memcpy(toValue, newValueVusd , newValueDataVusd.length);
        }
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, vdnsManage, 32);
        memcpy(allChar + 4 + 32, addresss1, 32);
        memcpy(allChar + 4 +32 *2, addresss2, 32);
        memcpy(allChar + 4 +32*3, addresss3, 32);
        memcpy(allChar + 4 +32*4, fromValue, 32);
        memcpy(allChar + 4 +32*5, toValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:196];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_shutDownVUSD_frobt)
    {
        
        u8 allChar[196];
        memset((void *)allChar,0,196);  //重置成0
        
        u8 function[] = {0x62,0x21,0x2f,0x22};
        
        u8 vdnsManage [32];
        memset((void *)vdnsManage,0,32);
        
        u8 addresss1 [32];
        memset((void *)addresss1,0,32);
        
        u8 addresss2 [32];
        memset((void *)addresss2,0,32);
        
        u8 addresss3 [32];
        memset((void *)addresss3,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        u8 toValue [32];
        memset((void *)toValue,0,32);
        
        u8 toVusdValue [32];
        memset((void *)toVusdValue,0,32);
        
        //资产名称
        NSString * vdns = params[@"managemente"]; //vns
        NSData * uuidData = [vdns dataUsingEncoding:NSASCIIStringEncoding];
        memcpy(vdnsManage, [uuidData bytes] , uuidData.length);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss1+offset2, contractU, addressU.length/2);
        memcpy(addresss2+offset2, contractU, addressU.length/2);
        memcpy(addresss3+offset2, contractU, addressU.length/2);
        
        //vns的值
        NSString *fromVns = params[@"toVns"];
        NSData * newValueData = [CoinIDHelper convertHexStrToData:fromVns] ;
        u8 * newValue = (u8*)[newValueData bytes];
        memcpy(fromValue, newValue, newValueData.length);
        
        NSString *newVNS10 = [YCommonMethods getNumberFromHex:[CoinIDHelper reverseCode:fromValue]];
        BigNumber *bigVns = [BigNumber bigNumberWithDecimalString:newVNS10];
        BigNumber * bigTVns = [bigVns add:[BigNumber constantOne]];
        NSString * bigStrVNS  = [CoinIDHelper getHexByDecimal:bigTVns] ;
        NSData * newValueDataVns_new = [CoinIDHelper convertHexStrToData:bigStrVNS] ;
        u8 * newValueVns_new= (u8*)[newValueDataVns_new bytes];
        memcpy(fromValue, newValueVns_new , newValueDataVns_new.length);
        
        //vusd的值
        BigNumber *tenStr = [BigNumber bigNumberWithDecimalString:params[@"toVusd"]];
        NSString *toVusd = [CoinIDHelper getHexByDecimal:tenStr];
        NSData * newValueDataVusd = [CoinIDHelper convertHexStrToData:toVusd] ;
        u8 * newValueVusd = (u8*)[newValueDataVusd bytes];
        int offset5 = (int)(32 - newValueDataVusd.length) ;
        memcpy(toValue + offset5, newValueVusd, newValueDataVusd.length);
        
        NSString *new10 = [YCommonMethods getNumberFromHex:[CoinIDHelper reverseCode:toValue]];
        BigNumber *big = [BigNumber bigNumberWithDecimalString:new10];
        BigNumber * bigT = [big add:[BigNumber constantOne]];
        NSString * bigStr  = [CoinIDHelper getHexByDecimal:bigT] ;
        NSData * newValueDataVusd_new = [CoinIDHelper convertHexStrToData:bigStr] ;
        u8 * newValueVusd_new = (u8*)[newValueDataVusd_new bytes];
        //        offset5 = (int)(32 - newValueDataVusd_new.length) ;
        memcpy(toValue, newValueVusd_new , newValueDataVusd_new.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, vdnsManage, 32);
        memcpy(allChar + 4 + 32, addresss1, 32);
        memcpy(allChar + 4 +32 *2, addresss2, 32);
        memcpy(allChar + 4 +32*3, addresss3, 32);
        memcpy(allChar + 4 +32*4, fromValue, 32);
        memcpy(allChar + 4 +32*5, toValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:196];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_transferVUSD )//转移vusd
    {
        
        u8 allChar[164];
        memset((void *)allChar,0,164);  //重置成0
        
        u8 function[] = {0x53,0x4a,0x1d,0xe7};
        
        u8 vdnsManage [32];
        memset((void *)vdnsManage,0,32);
        
        u8 addresss1 [32];
        memset((void *)addresss1,0,32);
        
        u8 addresss2 [32];
        memset((void *)addresss2,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        u8 toValue [32];
        memset((void *)toValue,0,32);
        
        
        //资产名称
        NSString * vdns = params[@"managemente"]; //vns
        NSData * uuidData = [vdns dataUsingEncoding:NSASCIIStringEncoding];
        memcpy(vdnsManage, [uuidData bytes] , uuidData.length);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss1+offset2, contractU, addressU.length/2);
        
        NSString *addressT = params[@"transferAddrs"];
        u8 *contractT = [CoinIDHelper hexToBytes:addressT];
        int offset3 = (int)(32 - addressT.length/2) ;
        memcpy(addresss2+offset3, contractT, addressT.length/2);
        
        //vns的值
        NSString *fromVns = params[@"toVns"];
        NSData * newValueData = [CoinIDHelper convertHexStrToData:fromVns] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset4 = (int)(32 - newValueData.length) ;
        memcpy(fromValue +offset4, newValue, newValueData.length);
        
        //vusd的值 45
        NSString *toVusd = params[@"toVusd"];
        NSData * newValueDataVusd = [CoinIDHelper convertHexStrToData:toVusd] ;
        u8 * newValueVusd = (u8*)[newValueDataVusd bytes];
        int offset5 = (int)(32 - newValueDataVusd.length) ;
        memcpy(toValue +offset5, newValueVusd, newValueDataVusd.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, vdnsManage, 32);
        memcpy(allChar + 4 + 32, addresss1, 32);
        memcpy(allChar + 4 +32 *2, addresss2, 32);
        memcpy(allChar + 4 +32*3, fromValue, 32);
        memcpy(allChar + 4 +32*4, toValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:164];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_RetrieveVNS_exit || signType == VNSSignType_Vusd_GenerateVUSD)//取回VNS 生成VUSD
    {
        
        u8 allChar[68];
        memset((void *)allChar,0,68);  //重置成0
        
        u8 function[] = {0xef,0x69,0x3b,0xed};
        
        u8 addresss1 [32];
        memset((void *)addresss1,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss1+offset2, contractU, addressU.length/2);
        
        NSString *fromVns = params[@"toVns"];
        NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:fromVns];
        NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:decimal];
        NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoney.stringValue];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset4 = (int)(32 - newValueData.length) ;
        memcpy(fromValue +offset4, newValue, newValueData.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4 , addresss1, 32);
        memcpy(allChar + 4 +32, fromValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:68];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_shutDownVUSD_Exit)// 关闭vusd
    {
        
        u8 allChar[68];
        memset((void *)allChar,0,68);  //重置成0
        
        u8 function[] = {0xef,0x69,0x3b,0xed};
        
        u8 addresss1 [32];
        memset((void *)addresss1,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss1+offset2, contractU, addressU.length/2);
        
        NSString *fromVns = params[@"toVns"];
        NSData * newValueData = [CoinIDHelper convertHexStrToData:fromVns] ;
        u8 * newValue = (u8*)[newValueData bytes];
        memcpy(fromValue , newValue, newValueData.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4 , addresss1, 32);
        memcpy(allChar + 4 +32, fromValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:68];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_shutDownVUSD_Exit_Gem)// 关闭vusd
    {
        
        u8 allChar[68];
        memset((void *)allChar,0,68);  //重置成0
        
        u8 function[] = {0xef,0x69,0x3b,0xed};
        
        u8 addresss1 [32];
        memset((void *)addresss1,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss1+offset2, contractU, addressU.length/2);
        
        NSString *fromVns = params[@"toVns"];
        NSData * newValueData = [CoinIDHelper convertHexStrToData:fromVns] ;
        u8 * newValue = (u8*)[newValueData bytes];
        memcpy(fromValue , newValue, newValueData.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4 , addresss1, 32);
        memcpy(allChar + 4 +32, fromValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:68];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_RepayVUSD_Approve || signType == VNSSignType_Vusd_shutDownVUSD_Approve || signType == VNSSignType_Vusd_Bonus_Approve )
    { //偿还vusd不足 首次关闭vusd
        u8 allChar[68];
        memset((void *)allChar,0,68);  //重置成0
        
        u8 function[] = {0x09,0x5e,0xa7,0xb3};
        
        u8 addresss [32];
        memset((void *)addresss,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss+offset2, contractU, addressU.length/2);
        
        NSString *fuVns = @"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
        NSData * fuVnsData =  [CoinIDHelper convertHexStrToData:fuVns] ;
        memcpy(fromValue, [fuVnsData bytes] , fuVnsData.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, addresss, 32);
        memcpy(allChar + 4 + 32, fromValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:68];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if ( signType == VNSSignType_Vusd_Bonus_Approve || signType == VNSSignType_Vusd_Bonus_Approve_FuYi)
    {
        u8 allChar[68];
        memset((void *)allChar,0,68);  //重置成0
        
        u8 function[] = {0x09,0x5e,0xa7,0xb3};
        
        u8 addresss [32];
        memset((void *)addresss,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss+offset2, contractU, addressU.length/2);
        
        NSString *fromVns = params[@"toVns"];
        NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:fromVns];
        NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:decimal];
        NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoney.stringValue];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset4 = (int)(32 - newValueData.length) ;
        memcpy(fromValue +offset4, newValue, newValueData.length);
        
        if (signType == VNSSignType_Vusd_Bonus_Approve_FuYi) {
            
            NSString *new10 = [YCommonMethods getNumberFromHex:[CoinIDHelper reverseCode:fromValue]];
            BigNumber *big = [BigNumber bigNumberWithDecimalString:new10];
            BigNumber * bigT = [big add:[BigNumber constantOne]];
            NSString * bigStr  = [CoinIDHelper getHexByDecimal:bigT] ;
            NSData * newValueDataVusd = [CoinIDHelper convertHexStrToData:bigStr] ;
            u8 * newValueVusd = (u8*)[newValueDataVusd bytes];
            memcpy(fromValue, newValueVusd , newValueDataVusd.length);
        }
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, addresss, 32);
        memcpy(allChar + 4 + 32, fromValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:68];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_Bonus_Grep )
    {
        u8 allChar[100];
        memset((void *)allChar,0,100);  //重置成0
        
        u8 function[] = {0x5e,0x2d,0x87,0x68};
        
        u8 vdnsManage [32];
        memset((void *)vdnsManage,0,32);
        
        u8 addresss [32];
        memset((void *)addresss,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        //资产名称
        NSString * vdns = params[@"managemente"]; //vns
        NSData * uuidData = [vdns dataUsingEncoding:NSASCIIStringEncoding];
        memcpy(vdnsManage, [uuidData bytes] , uuidData.length);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss+offset2, contractU, addressU.length/2);
        
        NSString *fromVns = params[@"ret"];
        NSData * newValueData = [CoinIDHelper convertHexStrToData:fromVns] ;
        u8 * newValue = (u8*)[newValueData bytes];
        memcpy(fromValue , newValue, newValueData.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, vdnsManage, 32);
        memcpy(allChar + 4 + 32, addresss, 32);
        memcpy(allChar + 4 + 32 +32, fromValue, 32);
        
        
        NSData * data = [NSData dataWithBytes:allChar length:100];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_RepayVUSD_Join)
    {//偿还vusd足够
        u8 allChar[68];
        memset((void *)allChar,0,68);  //重置成0
        
        u8 function[] = {0x3b,0x4d,0xa6,0x9f};
        
        u8 addresss [32];
        memset((void *)addresss,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss+offset2, contractU, addressU.length/2);
        
        NSString *fromVns = params[@"toVusd"];
        NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:fromVns];
        NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
        
        NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:decimal];
        NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
        NSString *payMoneyStr =  payMoney.stringValue;
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoneyStr];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset4 = (int)(32 - newValueData.length) ;
        memcpy(fromValue +offset4, newValue, newValueData.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, addresss, 32);
        memcpy(allChar + 4 + 32, fromValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:68];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_shutDownVUSD_Join)
    {
        u8 allChar[68];
        memset((void *)allChar,0,68);  //重置成0
        
        u8 function[] = {0x3b,0x4d,0xa6,0x9f};
        
        u8 addresss [32];
        memset((void *)addresss,0,32);
        
        u8 fromValue [32];
        memset((void *)fromValue,0,32);
        
        NSString *addressU = params[@"address"];
        u8 *contractU = [CoinIDHelper hexToBytes:addressU];
        int offset2 = (int)(32 - addressU.length/2) ;
        memcpy(addresss+offset2, contractU, addressU.length/2);
        
        NSString *fromVns = params[@"toVusd"];
        NSDecimalNumber * transValue = [NSDecimalNumber decimalNumberWithString:fromVns];
        NSDecimalNumber * decimalOne = [NSDecimalNumber decimalNumberWithString:@"1"];
        NSDecimalNumber * decimalRule  = [decimalOne decimalNumberByMultiplyingByPowerOf10:-27];
        NSDecimalNumber * payMoney = [transValue decimalNumberByMultiplyingBy:decimalRule];
        NSString *payMoneyStr =  payMoney.stringValue;
        NSRange range = [payMoneyStr rangeOfString:@"."]; //如果有浮点
        NSInteger lenght = range.location;
        if (range.location != NSNotFound) {
            payMoneyStr = [payMoneyStr substringWithRange:NSMakeRange(0, lenght)];
            NSInteger payMoneyInt = [payMoneyStr integerValue] +1;
            payMoneyStr = [NSString stringWithFormat:@"%ld",payMoneyInt];
        }
        
        BigNumber * realValue  = [BigNumber bigNumberWithDecimalString:payMoneyStr];
        NSString * hexMoney  = [CoinIDHelper getHexByDecimal:realValue] ;
        NSData * newValueData = [CoinIDHelper convertHexStrToData:hexMoney] ;
        u8 * newValue = (u8*)[newValueData bytes];
        int offset4 = (int)(32 - newValueData.length) ;
        memcpy(fromValue +offset4, newValue, newValueData.length);
        
        memcpy(allChar, function, 4);
        memcpy(allChar + 4, addresss, 32);
        memcpy(allChar + 4 + 32, fromValue, 32);
        
        NSData * data = [NSData dataWithBytes:allChar length:68];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    else if (signType == VNSSignType_Vusd_GenerateVUSD_Segmentation_No || signType == VNSSignType_Vusd_create_Segmentation_No || signType == VNSSignType_Vusd_transferVUSD_Hope)//看是否同意分割 hope
    {
        NSString * address  = params[@"address"];
        u8 function[] = {0xa3,0xb2,0x2f,0xc4};
        u8 allChar[36];
        memset((void *)allChar,0,36);  //重置成0
        memcpy(allChar, function, 4);
        
        u8 *contract = [CoinIDHelper hexToBytes:address];
        int offset2 = (int)(36 - address.length /2 ) ;
        memcpy(allChar + offset2, contract , address.length / 2 );
        
        NSData * data = [NSData dataWithBytes:allChar length:36];
        NSLog(@"data  %@",[CoinIDHelper convertDataToHexStr:data]);
        
        return data;
    }
    return dataList;
}

+(bool)CoinID_checkETHpushValid:(NSString*)pushStr to:(NSString*)to value:(NSString*)value decimal:(int)decimal isContract:(bool)isContract contraAddr:(NSString*)contraAddr {
    
    string pushData = "";
    string toData = "" ;
    string valueData = "";
    string contraAddrData = "";
    
    if (pushStr) {
        pushData = [pushStr UTF8String];
    }
    if (to) {
        toData = [to UTF8String];
    }
    if (value) {
        valueData = [value UTF8String];
    }
    if (contraAddr) {
       contraAddrData = [contraAddr UTF8String];
    }

    return CoinID_checkETHpushValid(pushData, toData, valueData, decimal, isContract, contraAddrData);
}

+ (NSString *)reverseCode:(u8[] )toValue
{
    NSString *temp = [[NSString alloc] init];
    for (int i = 0; i < 32; i++)
    {
        int panValue = toValue[i];
        temp = [temp stringByAppendingString:[NSString stringWithFormat:@"%02X",0xFF^panValue]];
        
    }
    return temp;
}
@end
