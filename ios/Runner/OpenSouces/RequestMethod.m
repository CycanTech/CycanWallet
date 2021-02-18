//
//  RequestMethod.m
//  CoinID
//
//  Created by 新明华区块链技术（深圳）有限公司 on 2018/7/5.
//  Copyright © 2018年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "RequestMethod.h"
#import "AFNetworking.h"
#import "YCommonMethods.h"

@interface RequestMethod ()

@property (nonatomic,strong) AFHTTPSessionManager * engine ;
@property (nonatomic,strong) NSMutableDictionary  * dataTaskDic ;

@property (nonatomic,assign) AFNetworkReachabilityStatus networkStatus ;

@end

@implementation RequestMethod


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
              didFailed:(RequestFailureBlock)didFailereBlock{
    
    NSDictionary * headers = [YCommonMethods addHeaderBaseParams] ;
    if (yRequest == YRequest_GET) {

        AFHTTPSessionManager * manager = [RequestMethod shareManager].engine ;
        NSURLSessionDataTask * task  = [manager GET:url parameters:param headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //包含status 时验证错误码
            if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject allKeys] containsObject:@"status"] ) {
                
                NSInteger status = [[responseObject objectForKey:@"status"] integerValue];
                if (status == 200) {
                    
                    if ([[responseObject allKeys ] containsObject:@"data"]) {
                        
                        id data = [responseObject objectForKey:@"data"];
                        if (didSuccessBlock) {
                            didSuccessBlock(data);
                        }
                    }
                    else {
                        
                        if (didSuccessBlock) {
                            didSuccessBlock(responseObject);
                        }
                    }
                }
                else{
                    
                    if (didFailereBlock) {
                        
                        didFailereBlock(@"请求失败");
                    }
                }
            }else{
                
                if (didSuccessBlock) {
                    didSuccessBlock(responseObject);
                }
            }
            NSLog( @"成功%@",responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (didFailereBlock) {
                
                didFailereBlock(error);
            }
            NSLog( @"错误%@",error);
        }];
    
    }
    
    else if (yRequest == YRequest_POST){
        
        AFHTTPSessionManager * manager = [RequestMethod shareManager].engine ;
        if ([url containsString:@"api.omniexplorer.info"]) {
            
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            
        }else{
            
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
        }
        //post请求
        NSURLSessionDataTask * task  = [manager POST:url parameters:param headers:headers progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            //包含status 时验证错误码
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                if ([[responseObject allKeys] containsObject:@"status"]) {
                    
                    id  status = [responseObject objectForKey:@"status"];
                    if ([status isKindOfClass:[NSString class]]) {
                        
                        if (didSuccessBlock) {
                            didSuccessBlock(responseObject);
                        }
                        
                    }else{
                        
                        if ([status  integerValue]== 200) {
                            
                            id data = [responseObject objectForKey:@"data"];
                          
                            if (didSuccessBlock) {
                                didSuccessBlock(data);
                            }
                          
                            
                        }else{
                            
                            if (didFailereBlock) {
                                
                                didFailereBlock(@"请求失败");
                            }
                        }
                    }
                }
                
                else{
                    
                    if (didSuccessBlock) {
                        didSuccessBlock(responseObject);
                    }
                }
                
            }else{
                
                if (didSuccessBlock) {
                    didSuccessBlock(responseObject);
                }
            }
            NSLog( @"成功%@",responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (error.code == -999) {
                NSLog(@"已取消");
            }else{
                if (didFailereBlock) {
                    
                    didFailereBlock(error);
                }
            }
            NSLog( @"错误%@",error);
        }];
        
        [RequestMethod shareManager].dataTaskDic[url] = task ;
        
    }
}



/**
 向链上请求交易
 
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
                         didFailed:(RequestFailureBlock)didFailereBlock{
    if (!url) {
        return ;
    }
    [RequestMethod requestNewAction:yRequest didParam:param didUrl:url didSuccess:didSuccessBlock didFailed:didFailereBlock ];
    
}


+ (void)cancelHTTPRequest:(NSString *)baseURL pathUrl:(NSString*)pathUrl{
    
    NSString * url = [NSString stringWithFormat:@"%@%@",baseURL,pathUrl];
    
    NSURLSessionDataTask * task = [[RequestMethod shareManager].dataTaskDic objectForKey:url];
    if (task) {
        [task cancel];
    }
}


/**
 获取单利对象
 
 @return 对象
 */
+(instancetype)shareManager {
    
    static RequestMethod * manager ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RequestMethod alloc] init];
        
    });
    
    return manager ;
}


/**
 网络监控
 */
+(void)startMonitoring{
    
    AFNetworkReachabilityManager * manage = [AFNetworkReachabilityManager sharedManager];
    [manage startMonitoring];
    [manage setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
       
        NSLog(@"网络情况  %ld", status );
        [RequestMethod shareManager].networkStatus = status ;
    }];
    
}

+(BOOL )isNetWorkValid {
   
    AFNetworkReachabilityStatus status = [RequestMethod shareManager].networkStatus ;
    if (status == AFNetworkReachabilityStatusUnknown ||status == AFNetworkReachabilityStatusNotReachable ) {
        
        return NO ;
    }
    return YES ;
}

/**
 公用一个manager

 @return 
 */
-(AFHTTPSessionManager *)engine{
    
    if (!_engine) {
        
        _engine = [AFHTTPSessionManager manager];
        _engine.responseSerializer = [AFJSONResponseSerializer serializer];
        _engine.requestSerializer =  [AFJSONRequestSerializer serializer];
        _engine.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                             @"application/xml",
                                                             @"application/json",
                                                             @"text/html",
                                                             @"text/json",
                                                             @"text/xml",
                                                             @"text/javascript",
                                                             @"image/*",
                                                             @"application/json-rpc",
                                                             @"text/plain", nil];
        [_engine.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        _engine.requestSerializer.timeoutInterval = 15 ;
        NSDictionary * dic = [YCommonMethods addHeaderBaseParams] ;
        for (NSString * keys in dic.allKeys) {
            
            [_engine.requestSerializer setValue:[dic objectForKey:keys] forHTTPHeaderField:keys];
        }
        
    }
    return _engine;
}

-(NSMutableDictionary *)dataTaskDic{
    
    if (!_dataTaskDic) {
       
        _dataTaskDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
    }
    return  _dataTaskDic ;
}

+(void)downloadURL:(NSString *) downloadURL progress:(void (^)(NSProgress *downloadProgress))progress destination:(void (^)(NSURL *targetPath))destination failure:(void(^)(NSError *error))faliure{
    
    AFHTTPSessionManager *manage  = [AFHTTPSessionManager manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: downloadURL]];
    NSURLSessionDownloadTask *downloadTask = [manage downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {//进度
        
        if (downloadProgress && progress) {
            progress(downloadProgress);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        //拼接文件全路径
        NSString *fullpath = [caches stringByAppendingPathComponent:response.suggestedFilename];
        NSURL *filePathUrl = [NSURL fileURLWithPath:fullpath];
       
        [[NSFileManager defaultManager] removeItemAtPath:fullpath error:nil];
        
        return filePathUrl;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {

        if (error) {
            faliure(error);
        }
        if(filePath){
            
            destination(filePath);
        }
    }];
    [downloadTask resume];
}

@end
