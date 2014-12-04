//
//  JRSession.m
//  WH
//
//  Created by guozw on 14-10-20.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "JRSession.h"
#import "AFJSONRPCClient.h"
#import "JRResponseFactory.h"


@interface JRSession() {
    AFJSONRPCClient *m_client;
    BOOL            m_cancel;
}
@end


@implementation JRSession

- (instancetype) initWithUrl:(NSURL *)url {
    if (self = [self init]) {
        m_client = [AFJSONRPCClient clientWithEndpointURL:url];
    }
    return self;
}

- (void) request:(JRReqest *)req
         success:(void(^)(JRReqest *request, JRResponse * resp))success
         failure:(void(^)(JRReqest *request, NSError *error))failure
          cancel:(void(^)(JRReqest *request))cancel {
    m_cancel = NO;
    [m_client invokeMethod:[req.method method] withParameters:[req.param package] requestId:req.requestID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (m_cancel) {
            cancel(req);
            return;
        }
        
        NSDictionary *dictRespObj = responseObject;
        NSError *err = nil;
        JRResponse *resp = [JRResponseFactory parseResponseObject:dictRespObj key:req.key iv:req.iv error:&err];
        
        if (err) {
            failure(req, err);
            return;
        }
        success(req, resp);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (m_cancel) {
            cancel(req);
            return;
        }
        failure(req ,error);
    }];
}

- (void)cancel {
    m_cancel = YES;
}


@end
