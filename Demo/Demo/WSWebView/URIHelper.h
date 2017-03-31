//
//  URIHelper.h
//  MNDataBank
//
//  Created by liu nian on 2017/2/23.
//  Copyright © 2017年 Shanghai Chengtai Information Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URIHelper : NSObject
+ (NSString *)fuckWithBaseURL:(NSString *)baseUrl queryParameters:(NSDictionary*)params;
+ (NSString *)fetchFullInvitationLinkWithCode:(NSString *)invitationCode;

@end
