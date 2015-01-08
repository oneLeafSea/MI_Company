//
//  RosterAddRequest.m
//  IM
//
//  Created by 郭志伟 on 14-12-17.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RosterItemAddRequest.h"
#import "MessageConstants.h"
#import "LogLevel.h"

@interface RosterItemAddRequest()


@end

@implementation RosterItemAddRequest

- (instancetype)init {
    if (self = [super init]) {
        self.type = IM_ROSTER_ITEM_ADD_REQUEST;
    }
    return self;
}



- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                     groupId:(NSString *)gid
                      reqmsg:(NSString *)reqmsg
                    selfName:(NSString *)selfName{
    if (self = [self init]) {
        _from = from;
        _gid = gid;
        _to = to;
        _reqmsg = reqmsg;
        _selfName = selfName;
        _status = RosterItemAddReqStatusUnkown;
    }
    return self;
}

- (instancetype) initWithData:(NSData *)data {
    if (self = [self init]) {
        NSDictionary *dict = [self dictFromJsonData:data];
        DDLogInfo(@"<-- %@", dict);
        _from = [dict objectForKey:@"from"];
        _to = [dict objectForKey:@"to"];
        self.qid = [dict objectForKey:@"msgid"];
        NSString *msg = [dict objectForKey:@"msg"];

        NSDictionary *msgDict = [self dictFromJsonData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
        _reqmsg = [msgDict objectForKey:@"req_msg"];
        _gid = [msgDict objectForKey:@"req_gid"];
        _selfName = [msgDict objectForKey:@"req_name"];
    }
    return self;
}


- (NSData *)pkgData {
    NSDictionary *rard = @{
                          @"msgid" : self.qid,
                          @"from"  : self.from,
                          @"to"    : self.to,
                          };
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:rard];
    [mutableDict setValue:self.msg forKey:@"msg"];
    DDLogInfo(@"--> %@", mutableDict);
    NSData *data = [self jsonDataFromDict:mutableDict];
    return data;
}

- (NSString *)msg {
    NSDictionary *msg = @{
                          @"req_gid"  : self.gid,
                          @"req_name" : self.selfName,
                          @"req_msg"    : self.reqmsg
                          };
    NSString *str = [[NSString alloc] initWithData:[self jsonDataFromDict:msg] encoding:NSUTF8StringEncoding];
    return str;
}

- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                       msgid:(NSString *)msgid
                         msg:(NSString *)msg
                      status:(NSNumber *)status{
    if (self = [self init]) {
        _from = [from copy];
        _to = [to copy];
        _status = [status unsignedIntValue];
        self.qid = msgid;
        NSDictionary *dict = [self dictFromJsonData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
        _gid = [[dict objectForKey:@"req_gid"] copy];
        _selfName = [[dict objectForKey:@"req_name"] copy];
        _reqmsg = [[dict objectForKey:@"req_msg"] copy];
    }
    return self;
}

@end
