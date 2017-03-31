//
//  WSWebViewController.h
//  Demo
//
//  Created by guojianfeng on 17/3/30.
//  Copyright © 2017年 guojianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSWebViewController : UIViewController
@property (nonatomic, strong) NSURL *requestURL;

- (instancetype)initWithURLString:(NSString *)URLString;
- (void)reloadWithURLString:(NSString *)URLString;
@end
