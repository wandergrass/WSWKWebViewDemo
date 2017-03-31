//
//  WSWebView.m
//  Demo
//
//  Created by guojianfeng on 17/3/30.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "WSWebView.h"

@interface WSWebView ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, weak) id<WSWebProtocol>manaWebProtocol;
@end

@implementation WSWebView
- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<WSWebProtocol>)delegate
    scriptMessageHandlerNames:(NSArray *)handlerNames{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 10;
    config.processPool = [WKCookieSyncManager sharedInstance].processPool;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    }
    config.userContentController = [[WKUserContentController alloc] init];
    
    self = [super initWithFrame:frame configuration:config];
    if (self) {
        // Initialization code
        self.manaWebProtocol = delegate;
        self.navigationDelegate = self;
        self.UIDelegate = self;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            self.customUserAgent = self.userAgent;
        }
        //遍历绑定JS对象
        [handlerNames enumerateObjectsUsingBlock:^(NSString  *name, NSUInteger idx, BOOL * _Nonnull stop) {
            [config.userContentController addScriptMessageHandler:self name:name];
        }];
//
        // 添加KVO监听
        [self addObserver:self
               forKeyPath:@"loading"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        [self addObserver:self
               forKeyPath:@"title"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        [self addObserver:self
               forKeyPath:@"estimatedProgress"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
    return self;
}

#pragma mark - private method
- (NSString *)dictionaryToJson:(NSDictionary *)dic{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (BOOL)nativeCallbackWithJsParam:(NSDictionary *)jsParam{
    //    NSString *jsonString = nil;
    //    NSError *error;
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsParam
    //                                                       options:NSJSONWritingPrettyPrinted
    //                                                         error:&error];
    //    if ([jsonData length] > 0 && error == nil){
    //        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //    }
    //    NSData *eData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    //    NSString *base64Str = @"";
    //    //    NSString *base64Str = [NWUtility encodeBASE64:eData];
    //    [self toCallFunctionName:@"MWJSBridge.nativeCallback" arguments:base64Str];
    return YES;
}

- (void)toCallFunctionName:(NSString *)functionName arguments:(NSString *)argumentStr{
    argumentStr = argumentStr?argumentStr:@"";
    [self evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",functionName,argumentStr]
           completionHandler:^(id _Nullable re, NSError * _Nullable error) {}];
}

#pragma mark - public method
- (BOOL)toCallWithEmitMessageName:(NSString *)emitMessageName data:(NSDictionary *)data{
    NSMutableDictionary *jsParam = @{}.mutableCopy;
    jsParam[@"emitMessageName"] = emitMessageName;
    jsParam[@"data"] = data?data:[NSNull null];
    return [self nativeCallbackWithJsParam:jsParam];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"loading");
    } else if ([keyPath isEqualToString:@"title"]) {
        if ([_manaWebProtocol respondsToSelector:@selector(JSBridgeWithWebTitle:)]) {
            [_manaWebProtocol JSBridgeWithWebTitle:self.title];
        }
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"progress: %f", self.estimatedProgress);
    }
    // 加载完成
    if (!self.loading) {
    }
}
#pragma mark - WKNavigationDelegate
// 请求开始前，会先调用此代理方法
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    if ([_manaWebProtocol respondsToSelector:@selector(JSBridgeWithNavigationAction:decisionHandler:)]) {
//        [_manaWebProtocol JSBridgeWithNavigationAction:navigationAction decisionHandler:decisionHandler];
//    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
//    }
}

// 在响应完成时，会回调此方法
// 如果设置为不允许响应，web内容就不会传过来
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 开始导航跳转时会回调
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}

// 接收到重定向时会回调
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}

// 导航失败时会回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

// 页面内容到达main frame时回调
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}

// 导航完成时，会回调（也就是页面载入完成了）
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self toCallWithEmitMessageName:@"bridge_ready" data:nil];
    if ([_manaWebProtocol respondsToSelector:@selector(JSBridgeLoadedFinish)]) {
        [_manaWebProtocol JSBridgeLoadedFinish];
    }
    NSString *jsString = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"trans" withExtension:@"js"]
                                                  encoding:NSUTF8StringEncoding error:nil];
    
    [self evaluateJavaScript:jsString completionHandler:^(id _Nullable value, NSError * _Nullable error) {
        NSLog(@"%@", value);
    }];
}

// 导航失败时会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if ([_manaWebProtocol respondsToSelector:@selector(JSBridgeLoadedFinish)]) {
        [_manaWebProtocol JSBridgeLoadedFinish];
    }
    NSLog(@"%@",error);
}

// 对于HTTPS的都会触发此代理，如果不要求验证，传默认就行
// 如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
//    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
//}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#ifdef  __IPHONE_9_0
// 9.0才能使用，web内容处理中断时会触发
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"%s", __FUNCTION__);
}
#endif

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if ([_manaWebProtocol respondsToSelector:@selector(JSBridgeWithAlertMessage:completionHandler:)]) {
        [_manaWebProtocol JSBridgeWithAlertMessage:message completionHandler:completionHandler];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    if ([_manaWebProtocol respondsToSelector:@selector(JSBridgeWithAlertMessage:resultCompletionHandler:)]) {
        [_manaWebProtocol JSBridgeWithAlertMessage:message resultCompletionHandler:completionHandler];
    }
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    if ([_manaWebProtocol respondsToSelector:@selector(JSBridgeWithAlertTextInputPanelWithPrompt:defaultText:completionHandler:)]) {
        [_manaWebProtocol JSBridgeWithAlertTextInputPanelWithPrompt:prompt defaultText:defaultText completionHandler:completionHandler];
    }
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([_manaWebProtocol respondsToSelector:@selector(JSBridgeWithMessageName:databody:)]) {
        [_manaWebProtocol JSBridgeWithMessageName:message.name databody:message.body];
    }
}

#pragma mark  getter
- (NSString *)userAgent{
    NSString *userAgent = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];//项目版本标识
    NSMutableDictionary * dict = @{}.mutableCopy;
    
    dict[@"apppname"] = @"manalove";
    dict[@"version"] = appVersion;
    dict[@"apiver"] = @(1.0);
    dict[@"platform"] = @"iOS";
    
    NSString * str = [self dictionaryToJson:dict];
    
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#pragma clang diagnostic pop
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        //此处是自己项目中的参数配置
//        userAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@"platformParams=%@",str]];
    }
    return userAgent;
}
@end

@implementation WKCookieSyncManager

+ (instancetype)sharedInstance{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (WKProcessPool *)processPool{
    if (!_processPool) {
        _processPool = [[WKProcessPool alloc] init];
    }
    return _processPool;
}
@end

