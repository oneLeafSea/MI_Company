//
//  ApnsMgr.m
//  IM
//
//  Created by 郭志伟 on 15-3-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "ApnsMgr.h"
#import "JRSession.h"

@implementation ApnsMgr

+ (void)registerWithIOSToken:(NSString *)iosToken
                         uid:(NSString *)uid
                       Token:(NSString *)token
                   signature:(NSString *)signature
                         key:(NSString *)key
                          iv:(NSString *)iv
                         url:(NSString *)url
                  completion:(void(^)(BOOL finished))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"test"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:@"QID_IM_GET_USER_INFO" token:token key:key iv:iv];
    [param.params setObject:uid forKey:@"uname"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            completion(YES);
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO);
            
        } cancel:^(JRReqest *request) {
            completion(NO);
        }];
    });
}

@end
