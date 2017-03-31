//
//  URIHelper.m
//  MNDataBank
//
//  Created by liu nian on 2017/2/23.
//  Copyright © 2017年 Shanghai Chengtai Information Technology Co.,Ltd. All rights reserved.
//

#import "URIHelper.h"

@implementation URIHelper

+ (NSString *)_encodeString:(NSString *)string{
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedUrl;
}


+ (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed{
    // Append base if specified.
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    if (base) {
        [str appendString:base];
    }
    // Append each name-value pair.
    if (params) {
        int i;
        NSArray *names = [params allKeys];
        for (i = 0; i < [names count]; i++) {
            if (i == 0 && prefixed && [str rangeOfString:@"?"].location == NSNotFound) {
                [str appendString:@"?"];
            } else {
                [str appendString:@"&"];
            }
            NSString *name = [names objectAtIndex:i];
            [str appendString:[NSString stringWithFormat:@"%@=%@",
                               name, [self _encodeString:[NSString stringWithFormat:@"%@",[params objectForKey:name]]]]];
        }
    }
    return str;
}

+ (NSString *)fuckWithBaseURL:(NSString *)baseUrl queryParameters:(NSDictionary*)params{
    //相对路径补齐为绝对路径
    NSString *fullPath = baseUrl;
    if ([baseUrl hasPrefix:@"http"] || [baseUrl hasPrefix:@"https://"]) {
        
    }else{
        fullPath = [NSString stringWithFormat:@"%@/%@",@"HtmlHost",@"baseUrl"];
    }
//    NSString *token = [ManaUsrHelper sharedInstance].token;
    NSMutableDictionary *muParams = nil;
    if (params.count) {
        muParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    }else{
        muParams = @{}.mutableCopy;
    }
    
    fullPath = [self _queryStringWithBase:fullPath parameters:muParams prefixed:YES];
    return fullPath;
}

+ (NSString *)fetchFullInvitationLinkWithCode:(NSString *)invitationCode{
    return [NSString stringWithFormat:@"%@public/activity/invitation?invited_code=%@&song=ios",@"HtmlHost",@"baseUrl"];
}

@end
