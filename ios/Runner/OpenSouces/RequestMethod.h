//
//  RequestMethod.h
//  CoinID
//
//  Created by 新明华区块链技术（深圳）有限公司 on 2018/7/5.
//  Copyright © 2018年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enum.h"
typedef void  (^RequestMet)(id obj ,  NSError  *err);
typedef NS_ENUM(NSInteger,YRequest) {
    
    YRequest_GET,  //get
    
    YRequest_POST, //post
};
typedef void (^RequestSuccessBlock)(id response);

typedef void (^RequestFailureBlock) (id error);

@interface RequestMethod : NSObject<NSURLSessionDataDelegate>

@property (copy ,nonatomic) RequestMet RequestMet;
/**
 网络监控
 */
+(void)startMonitoring;


/**
 获取单利对象

 @return 对象
 */
+(instancetype)shareManager ;


/**
 清除请求

 @ key 
 */
+(void)cancleRequestDataTask :(id)key ;


+(BOOL )isNetWorkValid;

/**
 新接口请求

 @param yRequest 请求方式
 @param param 参数
 @param url url
 @param didSuccessBlock 回调参数
 @param didFailereBlock 回调参数
 */
+(void)requestNewAction:(YRequest)yRequest
                            didParam:(id)param
                              didUrl:(NSString*)url
                          didSuccess:(RequestSuccessBlock)didSuccessBlock
                           didFailed:(RequestFailureBlock)didFailereBlock;




/**
 像链上请求交易

 @param yRequest 请求方式
 @param coinType 币的类型
 @param param 参数类型
 @param url 请求地址
 @param didSuccessBlock 返回数据
 @param didFailereBlock 失败提示
 */
+(void)requestMainChainTransaction:(YRequest)yRequest
                         coinType :(MCoinType)coinType
                          didParam:(id)param
                            didUrl:(NSString *)url
                        didSuccess:(RequestSuccessBlock)didSuccessBlock
                         didFailed:(RequestFailureBlock)didFailereBlock;


/// 取消某个url 的请求
+ (void)cancelHTTPRequest:(NSString *)baseURL pathUrl:(NSString*)pathUrl ;

+(void)downloadURL:(NSString *) downloadURL progress:(void (^)(NSProgress *downloadProgress))progress destination:(void (^)(NSURL *targetPath))destination failure:(void(^)(NSError *error))faliure ;


@end
