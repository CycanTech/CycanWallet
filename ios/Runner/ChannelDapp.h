//
//  ChannelDapp.h
//  Runner
//
//  Created by MWT on 28/12/2020.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "Enum.h"

typedef void (^DappResult)(id _Nullable result);

NS_ASSUME_NONNULL_BEGIN

@interface ChannelDapp : NSObject<FlutterPlugin>

+(instancetype)sharedInstance ;

-(void)datas:(MCoinType)coinType result:(DappResult)result ;

-(void)updateDIDChoose:(NSString*)walletID;

-(void)getDid:(DappResult)results ;

-(void)lock:(NSString*)walletID pin:(NSString * )pin result:(DappResult)result ;

@end

NS_ASSUME_NONNULL_END
