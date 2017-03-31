//
//  WSWebViewController.m
//  Demo
//
//  Created by guojianfeng on 17/3/30.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "WSWebViewController.h"
#import "WSWebView.h"
#import "URIHelper.h"

#define kTestURL    @"https://www.baidu.com/"
@interface WSWebViewController ()<WSWebProtocol>
@property (nonatomic, strong) WSWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *backButtonItem;
@property (nonatomic, strong) UIBarButtonItem *closeButtonItem;
@end

@implementation WSWebViewController
- (instancetype)initWithURLString:(NSString *)URLString{
    self = [super init];
    if (self) {
        if (false) {
            URLString = kTestURL;
        }
        self.requestURL = [self packageWithURLString:URLString];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
    [self loadRequestURL:self.requestURL];
}

#pragma mark  public
- (void)reloadWithURLString:(NSString *)URLString{
    NSString *handleUrl = [URIHelper fuckWithBaseURL:URLString queryParameters:nil] ;
    self.requestURL = [NSURL URLWithString:handleUrl];
    [self loadRequestURL:self.requestURL];
}

#pragma mark  private
- (NSURL *)packageWithURLString:(NSString *)URLString{
    NSString *handleUrl = [URIHelper fuckWithBaseURL:URLString queryParameters:nil];
    NSLog(@"handleUrl = %@",handleUrl);
    return [NSURL URLWithString:handleUrl];
}

- (void)loadRequestURL:(NSURL *)URL{
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
}

- (void)updateUI{
    if (self.webView.canGoBack) {
        self.navigationItem.leftBarButtonItems = @[self.backButtonItem, self.closeButtonItem];
    }else{
        self.navigationItem.leftBarButtonItem = self.backButtonItem;;
    }
}

- (void)updateNavigationBarWithDictionary:(NSDictionary *)dic{
    if (dic) {
        NSString *pageTitle = dic[@"pageTitle"];
        NSString *btnTitle = @"";
        NSString *buttonColor = @"";
        NSString *buttonClickFunction = @"";
        
        if ([[dic allKeys] containsObject:@"buttonTilte"] && dic[@"buttonTilte"]) {
            btnTitle = dic[@"buttonTilte"];
            
        }else if([[dic allKeys] containsObject:@"buttonColor"] && dic[@"buttonColor"]){
            buttonColor = dic[@"buttonColor"];
        }else if ([[dic allKeys] containsObject:@"buttonClickFunction"] && dic[@"buttonClickFunction"])
            buttonClickFunction = dic[@"buttonClickFunction"];
        
        if (pageTitle && ![pageTitle isEqualToString:@""]) {
            self.title = pageTitle;
        }
    }
}

#pragma mark  evnent
- (void)backItemClickEvent:(id)sender{
    if (_webView.canGoBack) {
        [self.view endEditing:YES];
        [_webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeBtnClickEvent{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark  MNWebProtocol
- (void)JSBridgeLoadedFinish{
    [self updateUI];
}

- (void)JSBridgeWithWebTitle:(NSString *)webTitle{
    self.title = webTitle;
}

- (void)JSBridgeWithMessageName:(NSString *)functionName databody:(id)body{
    NSLog(@"function:%@ body:%@",functionName, body);
}

- (void)JSBridgeWithNavigationAction:(WKNavigationAction *)navigationAction
                     decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
}

- (void)JSBridgeWithAlertMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)JSBridgeWithAlertMessage:(NSString *)message resultCompletionHandler:(void (^)(BOOL result))resultCompletionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        resultCompletionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        resultCompletionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
}

- (void)JSBridgeWithAlertTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
}

#pragma mark  getter
- (WSWebView *)webView{
    if (!_webView) {
        _webView = [[WSWebView alloc] initWithFrame:self.view.bounds delegate:self scriptMessageHandlerNames:[self scriptMessageHandlers]];
        _webView.backgroundColor = [UIColor whiteColor];
        [_webView setOpaque:NO];
        [self.view addSubview:_webView];
        [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
            NSLog(@"%@", result);
        }];
    }
    return _webView;
}

- (UIBarButtonItem *)backButtonItem{
    if (!_backButtonItem) {
        _backButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"group"]
                                                                  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(backItemClickEvent:)];
    }
    return _backButtonItem;
}

- (UIBarButtonItem *)closeButtonItem{
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeBtnClickEvent)];
        [_closeButtonItem setTintColor:[UIColor blackColor]];
    }
    return _closeButtonItem;
}

- (NSArray *)scriptMessageHandlers{
    return @[@"getNavigationBarInfo"];
}
@end
