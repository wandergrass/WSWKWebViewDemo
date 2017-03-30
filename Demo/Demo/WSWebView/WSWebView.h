//
//  WSWebView.h
//  Demo
//
//  Created by guojianfeng on 17/3/30.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WSWebProtocol;
@interface WSWebView : WKWebView
- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<WSWebProtocol>)delegate
    scriptMessageHandlerNames:(NSArray *)handlerNames;
@end

@interface WKCookieSyncManager : NSObject
@property (nonatomic, strong) WKProcessPool *processPool;
+ (instancetype)sharedInstance;
@end

@protocol WSWebProtocol<NSObject>
@required
/*!
 @brief JS注入完毕，可以给H5交互
 */
- (void)JSBridgeLoadedFinish;

@optional

- (void)JSBridgeWithWebTitle:(NSString *)webTitle;
/*!
 @brief在JS端调用alert函数时，会触发此代理方法
 
 @param functionName    业务模块名
 @param body            回调实体
 */
- (void)JSBridgeWithMessageName:(NSString *)functionName databody:(id)body;


/**
 页面跳转是截获到的URL事件进行设置交互
 
 @param navigationAction 交互动作
 @param decisionHandler 是否允许进行跳转
 */
- (void)JSBridgeWithNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
/*!
 @brief在JS端调用alert函数时，会触发此代理方法。JS端调用alert时所传的数据
 可以通过message拿到在原生得到结果后，需要回调JS，是通过completionHandler回调
 
 @param message           alert信息
 @param completionHandler 回调方法:参数
 */
- (void)JSBridgeWithAlertMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler;

/*!
 @brief JS端调用confirm函数时，会触发此方法通过message可以拿到JS端所传的数据
 在iOS端显示原生alert得到YES/NO后,通过completionHandler回调给JS端
 
 @param message                 alert信息
 @param resultCompletionHandler 回调方法:有参数
 */
- (void)JSBridgeWithAlertMessage:(NSString *)message resultCompletionHandler:(void (^)(BOOL result))resultCompletionHandler;
/*!
 @brief JS端调用prompt函数时，会触发此方法,要求输入一段文本,在原生输入得到文本内容后，通过completionHandler回调给JS
 
 @param prompt            函数
 @param defaultText       默认文本显示
 @param completionHandler 回调方法:有参数返回
 */
- (void)JSBridgeWithAlertTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText completionHandler:(void (^)(NSString * __nullable result))completionHandler;

@end

NS_ASSUME_NONNULL_END
