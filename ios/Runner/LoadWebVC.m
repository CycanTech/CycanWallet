//
//  LoadWebVC.m
//  CoinID
//
//  Created by 新明华区块链技术（深圳）有限公司 on 2018/10/29.
//  Copyright © 2018年 新明华区块链技术（深圳）有限公司. All rights reserved.
//

#import "LoadWebVC.h"
#import <WebKit/WebKit.h>
#import "Enum.h"
#import "UIFont+Size.h"
#import "YCommonMethods.h"
#import "UIView+Additions.h"
#import "BancorManager.h"
#import "VDNSManager.h"
#import "ChannelDapp.h"
#import "WalletObject.h"
#import "VDAIManager.h"

@interface LoadWebVC ()<WKNavigationDelegate,WKUIDelegate,UIActionSheetDelegate>

//@property (strong, nonatomic) FengXiang *  shareview ; //分享页面
@property (strong ,nonatomic) UIProgressView *progressView;
@property (strong ,nonatomic) WKWebView *wkWebView;
@property (nonatomic, strong, readwrite)UIView   *backgroundView;

@property (nonatomic,strong) BancorManager * bancorManager ;
@property (nonatomic,strong) VDNSManager * vDnsmanager ;
@property (nonatomic,strong) UIButton * arrow_Left  ;
@property (nonatomic,strong) VDAIManager * daiManager ;


@end

@implementation LoadWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavItems];

    //进度条初始化
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0,0 , KSCREEN_WIDTH, 2)];
    self.progressView.backgroundColor = [UIColor lightGrayColor];
    self.progressView.progressTintColor = [UIColor colorWithRed:0 green:145/255 blue:1 alpha:1];
    
    //设置进度条的高度
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.progressView];
    NSString *urlString = self.url;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.timeoutInterval = 15.0f;
    [self.wkWebView loadRequest:request];
    if (_urlType == URLLoadType_Bancor) {
        WEAK(self)
        [[ChannelDapp sharedInstance] getDid:^(id  _Nullable result) {
            STRONG(weakObject)
            WalletObject * object = result;
            strongObject.bancorManager =[BancorManager shareManagerWithContainerVC:strongObject defalutObject:object];
            strongObject.wkWebView.UIDelegate = strongObject.bancorManager ;
        }];
    }else if (_urlType == URLLoadType_VUSD){
        
        WEAK(self)
        [[ChannelDapp sharedInstance] getDid:^(id  _Nullable result) {
            STRONG(weakObject)
            WalletObject * object = result;
            strongObject.daiManager = [VDAIManager shareManagerWithContainerVC:strongObject webView:strongObject.wkWebView defalutObject:object];
            strongObject.wkWebView.UIDelegate = strongObject.daiManager ;
        }];
    }
    
 
}
- (void)addNavItems
{
    UIImageView * backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    backView.image = [UIImage imageNamed:@"webkuang"];
    UIButton * referBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [referBtn setImage:[UIImage imageNamed:@"webRefresh"] forState:UIControlStateNormal];
    referBtn.frame = CGRectMake(0, 0, 45 , 30);
    [referBtn addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:referBtn];
    
    UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"webclose"] forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(45, 0, 45 , 30);
    [closeBtn addTarget:self action:@selector(itemClicked) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:closeBtn];

    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:backView];
    
    UIButton * arrow_Left = [UIButton buttonWithType:UIButtonTypeCustom];
//    [arrow_Left setImage:[UIImage imageNamed:@"arrow_left"] forState:UIControlStateNormal];
    arrow_Left.frame = CGRectMake(0, 0, 40 , 40);
    [arrow_Left addTarget:self action:@selector(goback1) forControlEvents:UIControlEventTouchUpInside];
    [arrow_Left setTitleColor:[YCommonMethods colorWithHexString:@"#4A4A4A"] forState:UIControlStateNormal];
    arrow_Left.titleLabel.font = [UIFont fontWithNameV2:@"PingFangSC-Semibold" size:18];
    self.arrow_Left = arrow_Left ;
    UIBarButtonItem * space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:arrow_Left];
    
    UIButton * arrow_image = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * image = [UIImage imageNamed:@"arrow_left"];
    [arrow_image setImage:image forState:UIControlStateNormal];
    arrow_image.frame = CGRectMake(0, 0, image.width , 40);
    [arrow_image addTarget:self action:@selector(goback1) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftImage = [[UIBarButtonItem alloc] initWithCustomView:arrow_image];
    self.navigationItem.leftBarButtonItems = @[space ,leftImage,leftItem ] ;
    self.navigationItem.rightBarButtonItem = right ;
    
}
- (void)goback1{
    
    if ([self.wkWebView canGoBack]) {
        [self goBackAction];
    } else {
        
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

-(void)itemClicked{
    
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - 收藏和分享 复制
- (void)itemClicked:(UIBarButtonItem*)item
{
    if (item.tag == 9002) {//刷新
        
        [self refreshAction];
    }
    else
    {
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

#pragma clang diagnostic pop
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    //对外链、拨号和跳转appstore做特殊处理
    decisionHandler(WKNavigationActionPolicyAllow);//崩在这里
    
}


- (WKWebView *)wkWebView {
    
    if (!_wkWebView) {
        //进行配置控制器
        NSString *jScript = @"var script = document.createElement('meta');"
        "script.name = 'viewport';"
        "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
        "document.getElementsByTagName('head')[0].appendChild(script);";
        
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController* userContentController = [WKUserContentController new];
        [userContentController addUserScript:wkUScript];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        //实例化对象
        
        configuration.userContentController = userContentController;
        //    configuration.preferences.javaScriptEnabled = YES;
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 0.0;
        preferences.javaScriptEnabled = YES;
        configuration.preferences = preferences;
        
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, self.view.frame.size.height) configuration:configuration];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        [self.view addSubview:_wkWebView];
        
    }
    return _wkWebView;
}
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
    
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成 %@",webView.URL.absoluteString);
    //加载完成后隐藏progressView
    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    if (_urlType == URLLoadType_DomainName) {
        
        if ([webView.URL.absoluteString isEqualToString:self.url]) {
            WEAK(self)
            [[ChannelDapp sharedInstance] getDid:^(id  _Nullable result) {
                STRONG(weakObject)
                WalletObject * object = result;
                if (strongObject.vDnsmanager) {
                    strongObject.vDnsmanager = nil;
                }
                strongObject.vDnsmanager = [VDNSManager shareManagerWithContainerVC:strongObject webView:strongObject.wkWebView defalutObject:object];
                strongObject.wkWebView.UIDelegate = strongObject.vDnsmanager ;
            }];
        }
    }
    
    __weak typeof(self) weakself = self;
    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString* _Nullable obj, NSError * _Nullable error) {
        
        if (obj) {
            
            obj = [obj stringByReplacingOccurrencesOfString:@"交易" withString:@"帮客"];
            if (obj.length > 15 ) {
                
                obj = [obj substringToIndex:15];
                obj = [obj stringByAppendingString:@"..."];
            }
            [weakself.arrow_Left setTitle:obj forState:UIControlStateNormal];
            [weakself.arrow_Left sizeToFit];
        }
    }];
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"加载失败 %@",error.localizedDescription);
    self.progressView.hidden = YES;
    [self handleError:error];
}


- (void)goBackAction {
    
    if ([self.wkWebView canGoBack]) {
        [self.wkWebView goBack];
    }
    
}

- (void)goForwardAction {
    
    if ([self.wkWebView canGoForward]) {
        [self.wkWebView goForward];
    }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    if (error.code==NSURLErrorCancelled) {
        return;
    }
    [self handleError:error];
}


- (void)handleError:(NSError *)error
{
    
    [self.wkWebView stopLoading];
    [self goback1];
}

- (void)refreshAction {
    [self.wkWebView reload];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

//接收到确认面板
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
    NSLog(@"收到收到收到了");
}


#pragma mark - js native
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
    NSLog(@"prompt  %@",prompt);
   
    completionHandler(nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
