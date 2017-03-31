//
//  ViewController.m
//  Demo
//
//  Created by guojianfeng on 17/3/30.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import "ViewController.h"
#import "WSWebViewController.h"

@interface ViewController ()<WSWebProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"webController" style:UIBarButtonItemStylePlain target:self action:@selector(pushToWebController)];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];
}

#pragma mark - Event
- (void)pushToWebController{
    WSWebViewController *vc = [[WSWebViewController alloc] initWithURLString:@"https://www.baidu.com/"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - WSWebProtocoldelegate

- (void)JSBridgeLoadedFinish{
    NSLog(@"加载完成处理");
}

#pragma mark - get
- (WSWebView *)webView{
    if (!_webView) {
        _webView = [[WSWebView alloc] initWithFrame:self.view.frame delegate:self scriptMessageHandlerNames:@[]];
        _webView.backgroundColor = [UIColor whiteColor];
        [_webView setOpaque:NO];
        [self.view addSubview:_webView];
        [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
            NSLog(@"%@", result);
        }];
    }
    return _webView;
}

@end
