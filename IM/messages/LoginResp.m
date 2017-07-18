//
//  LoginResp.m
//  WH
//
//  Created by guozw on 14-10-15.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "LoginResp.h"
#import "LogLevel.h"

@implementation LoginResp


- (BOOL)parseData:(UInt32)type data:(NSData *)data {
    self.type = type;
    _respData = [self dictFromJsonData:data];
    DDLogInfo(@"<-- %@", _respData);
    
    NSDictionary *services = [self.respData objectForKey:@"services"];
    NSString *SVC_HTTP = [services valueForKey:@"SVC_HTTP"];
    
    NSString *newUrl = [NSString stringWithFormat:@"%@/im/file/download/head", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_FILE_DOWN_AVATAR"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/file/download/jyq", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_FILE_DOWN_LARGE"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/rpc/", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_IM"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/file/upload/2", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_FILE_UPLOAD"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/file/upload/2", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_FILE_UPLOAD2"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/file/upload/jyq/2", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_PYQ_UPLOAD"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/file/upload/jyq/2", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_PYQ_UPLOAD2"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/file/download/", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_FILE_DOWN"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/file/download/qgg", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_FILE_DOWN_QGG"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/file/download/jyq/thumbnail", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_FILE_DOWN_THUMB"];
    
    newUrl = [NSString stringWithFormat:@"%@/data/rpc", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_RDS"];
    
    newUrl = [NSString stringWithFormat:@"%@/im/file/download/", SVC_HTTP];
    [services setValue:newUrl forKey:@"SVC_MSG_IMG_THUMB"];
    
    self.qid = [_respData objectForKey:@"qid"];
    return YES;
}

@end
