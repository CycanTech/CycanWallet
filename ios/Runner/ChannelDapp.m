//
//  ChannelDapp.m
//  Runner
//
//  Created by MWT on 28/12/2020.
//

#import "ChannelDapp.h"
#import "LoadWebVC.h"
#import <MJExtension/MJExtension.h>
#import "WalletObject.h"

@interface ChannelDapp ()

@property (nonatomic,strong)  FlutterMethodChannel* channel;


@end

@implementation ChannelDapp


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.coinidwallet.dapps"
                                     binaryMessenger:[registrar messenger]];
    ChannelDapp* instance = [ChannelDapp sharedInstance];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

+(instancetype)sharedInstance{
    static  ChannelDapp* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ChannelDapp alloc] init];
    });
    return instance;
}

-(void)datas:(MCoinType)coinType result:(DappResult)result{
    
    NSDictionary * dic = @{@"coinType":@(coinType)};
    [_channel invokeMethod:@"datas" arguments:dic result:result];
}

-(void)updateDIDChoose:(NSString*)walletID{
    
    NSDictionary * dic = @{@"walletID":walletID};
    [_channel invokeMethod:@"updateDid" arguments:dic];
}

-(void)lock:(NSString*)walletID pin:(NSString * )pin result:(DappResult)result{
    
    NSDictionary * dic = @{@"walletID":walletID,@"pin":pin};
    [_channel invokeMethod:@"lock" arguments:dic result:result];
}

-(void)getDid:(DappResult)results{
    
    [_channel invokeMethod:@"getDid" arguments:nil result:^(id  _Nullable result) {
        
        WalletObject * object = [WalletObject mj_objectWithKeyValues:result];
        if (results) {
            results(object);
        }
    }];
}


- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result{
    
    if ([call.method isEqualToString:@"pushWeb"]) {
        
        NSDictionary * arguments = call.arguments;
        NSString * url = arguments[@"url"];
        URLLoadType type = (URLLoadType)[arguments[@"urlType"] integerValue];
        LoadWebVC * vc = [[LoadWebVC alloc] init];
        vc.url = url;
        vc.urlType = type;
        UINavigationController * nav = [[UINavigationController alloc ] initWithRootViewController:vc];
        UIViewController * root = [UIApplication sharedApplication].keyWindow.rootViewController ;
        while (root.presentedViewController) {
            root = root.presentedViewController;
        }
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [root presentViewController:nav animated:YES completion:nil];
        
    }else{
        
        result(FlutterMethodNotImplemented);
    }
    
    
}


@end
