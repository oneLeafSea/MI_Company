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

@property(copy) NSString *from;
@property(copy) NSString *to;
@property(copy) NSString *gid;
@property(copy) NSString *reqmsg;


@end

@implementation RosterItemAddRequest

- (instancetype)init {
    if (self = [super init]) {
        self.type = MSG_ROSTER_ITEM_ADD_REQUEST;
    }
    return self;
}



- (instancetype)initWithFrom:(NSString *)from
                          to:(NSString *)to
                     groupId:(NSString *)gid
                      reqmsg:(NSString *)reqmsg {
    if (self = [self init]) {
        self.from = from;
        self.gid = gid;
        self.to = to;
        self.reqmsg = reqmsg;
    }
    return self;
}

- (instancetype) initWithData:(NSData *)data {
    if (self = [self init]) {
        NSDictionary *dict = [self dictFromJsonData:data];
        DDLogInfo(@"<-- %@", dict);
        self.from = [dict objectForKey:@"from"];
        self.to = [dict objectForKey:@"to"];
        self.qid = [dict objectForKey:@"qid"];
        NSDictionary *params = [dict objectForKey:@"params"];
        self.reqmsg = [params objectForKey:@"reqmsg"];
        self.gid = [params objectForKey:@"gid"];
    }
    return self;
}


- (NSData *)pkgData {
    NSDictionary *rard = @{
                          @"qid" : self.qid,
                          @"from": self.from,
                          @"to"  : self.to,
                          };
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithDictionary:rard];
    NSDictionary *param = @{
                            @"reqmsg" : self.reqmsg,
                            @"gid"    : self.gid
                            };
    [mutableDict setValue:param forKey:@"params"];
    DDLogInfo(@"--> %@", mutableDict);
    NSData *data = [self jsonDataFromDict:mutableDict];
    return data;
}

@end
