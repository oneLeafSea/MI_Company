//
//  detailMgr.m
//  IM
//
//  Created by 郭志伟 on 15-3-6.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "DetailMgr.h"
#import "JRSession.h"
#import "JRListResponse.h"
#import "detailQid.h"


@implementation DetailMgr

- (void)getDetailWithUid:(NSString *)uid
                   Token:(NSString *)token
               signature:(NSString *)signature
                     key:(NSString *)key
                      iv:(NSString *)iv
                     url:(NSString *)url
              completion:(void(^)(BOOL finished, Detail *d))completion {
    __block JRSession *session = [[JRSession alloc] initWithUrl:[NSURL URLWithString:url]];
    JRReqMethod *m = [[JRReqMethod alloc] initWithService:@"SVC_IM"];
    JRReqParam *param = [[JRReqParam alloc] initWithQid:QID_IM_GET_USER_INFO token:token key:key iv:iv];
    [param.params setObject:uid forKey:@"uname"];
    __block JRReqest *req = [[JRReqest alloc] initWithMethod:m  param:param];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [session request:req success:^(JRReqest *request, JRResponse *resp) {
            if ([resp isKindOfClass:[JRListResponse class]]) {
                JRListResponse *listResp = (JRListResponse *)resp;
                Detail *d = [[Detail alloc] initWithResp:listResp];
                if (d) {
                    completion(YES, d);
                } else {
                    completion(NO, nil);
                }
                
            } else {
                completion(NO, nil);
            }
            
        } failure:^(JRReqest *request, NSError *error) {
            completion(NO, nil);
            
        } cancel:^(JRReqest *request) {
            completion(NO, nil);
        }];
    });
}

@end
